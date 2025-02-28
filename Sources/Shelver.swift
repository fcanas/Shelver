import ArgumentParser
import ArgumentParser
import Foundation

@main
struct Shelver: ParsableCommand {
	nonisolated(unsafe) static var configuration = CommandConfiguration(
		subcommands: [BuildStructure.self, Summarize.self],
		defaultSubcommand: BuildStructure.self
	)
	
	struct Author {
		let name: String
		let series: [Series]
		let books: [Audiobook]
	}
	struct Series {
		let name: String
		let books: [Audiobook]
	}
	
	static func organize(books: [Audiobook]) -> [Shelver.Author] {
		return Dictionary(grouping: books, by: { $0.author })
			.map { authorName, authorBooks -> Author in
				// Group books by series
				let seriesBooks = authorBooks.filter { $0.seriesName != nil }
				let seriesByName = Dictionary(grouping: seriesBooks, by: { $0.seriesName! })
				let series = seriesByName.map { name, books in
					Series(
						name: name,
						books: books.sorted(by: { ($0.seriesSequence ?? "") < ($1.seriesSequence ?? "") })
					)
				}.sorted(by: { $0.name < $1.name })
				
				// Standalone books
				let standaloneBooks = authorBooks.filter { $0.seriesName == nil }
					.sorted(by: { $0.title < $1.title })
				
				return Author(
					name: authorName,
					series: series,
					books: standaloneBooks
				)
			}
			.sorted(by: { $0.name < $1.name })
	}
	
	static func printx(structured: [Shelver.Author]) {
		for author in structured {
			print("\(author.name)/")
			
			// Print series
			for series in author.series {
				print("  📚 \(series.name)/")
				for book in series.books {
					print("    📖 \(book.title)")
				}
			}
			
			// Print standalone books
			for book in author.books {
				print("  📖 \(book.title)")
			}
		}
	}
}

extension Shelver {
	struct BuildStructure: ParsableCommand {
		nonisolated(unsafe) static var configuration = CommandConfiguration(
			commandName: "build-structure",
			abstract: "Apply an OpenAudible library to an AudioBookshelf library."
		)
		
		@Argument(help: "The path to the books.json file", completion: .file(extensions: ["json"]))
		var booksJsonPath: String
		
		@Flag(help: "Print the structure to the console")
		var printStructure: Bool = false
		
		@Flag(help: "Show verbose output")
		var verbose: Bool = false
		
		@Argument(help: "The path to the AudioBookshelf directory", completion: .directory)
		var outputPath: String
		
		@Flag(help: "Dry run the command")
		var dryRun: Bool = false
		
		private func log(_ message: String) {
			if verbose {
				print(message)
			}
		}
		
		private class Statistics: Codable {
			var directoriesCreated = 0
			var directoriesSkipped = 0
			var filesCopied = 0
			var filesSkipped = 0
			
			func printSummary() {
				print("\nOperation completed:")
				print("  Directories created: \(directoriesCreated)")
				print("  Files copied: \(filesCopied)")
				print("  Directories skipped: \(directoriesSkipped)")
				print("  Files skipped: \(filesSkipped)")
			}
		}
		
		private var stats = Statistics()
		
		func run() throws {
			let data = try Data(contentsOf: URL(fileURLWithPath: booksJsonPath))
			let books = try JSONDecoder().decode([Audiobook].self, from: data)
			
			// Organize according to AudioBookshelf directory structure
			// Author/(Series/)?Book/Book
			let authors = organize(books: books)
			
			if printStructure {
				printx(structured: authors)
			}
			
			let bookSourceDir = URL(fileURLWithPath: booksJsonPath).deletingLastPathComponent().appendingPathComponent("books")
			
			let audioBookshelfDir = URL(fileURLWithPath: outputPath)
			assert(FileManager.default.fileExists(atPath: audioBookshelfDir.path), "AudioBookshelf directory does not exist")
			
			try processStructure(authors: authors, audioBookshelfDir: audioBookshelfDir, bookSourceDir: bookSourceDir)
			
			stats.printSummary()
		}
		
		private func processStructure(authors: [Author], audioBookshelfDir: URL, bookSourceDir: URL) throws {
			for author in authors {
				let authorDir = audioBookshelfDir.appendingPathComponent(author.name)
				if !FileManager.default.fileExists(atPath: authorDir.path) {
					try createDirectory(at: authorDir, dryRun: dryRun)
					stats.directoriesCreated += 1
				} else {
					log("Author directory \(authorDir.path) exists")
					stats.directoriesSkipped += 1
				}
				
				for series in author.series {
					let seriesDir = authorDir.appendingPathComponent(series.name)
					if !FileManager.default.fileExists(atPath: seriesDir.path) {
						try createDirectory(at: seriesDir, dryRun: dryRun)
						stats.directoriesCreated += 1
					} else {
						log("Series directory \(seriesDir.path) exists")
						stats.directoriesSkipped += 1
					}
					
					for book in series.books {
						try shelve(book: book, bookDir: seriesDir, bookSourceDir: bookSourceDir)
					}
				}
				
				for book in author.books {
					try shelve(book: book, bookDir: authorDir, bookSourceDir: bookSourceDir)
				}
			}
		}
		
		private func shelve(book: Audiobook, bookDir: URL, bookSourceDir: URL) throws {
			let sourceFiles = book.files.filter { $0.kind == "audio" && $0.type == "M4B" }
				.map { $0.path }
				.map { bookSourceDir.appendingPathComponent($0) }
			let finalBookDir = bookDir.appendingPathComponent(book.title)
			if !FileManager.default.fileExists(atPath: finalBookDir.path) {
				try createDirectory(at: finalBookDir, dryRun: dryRun)
			}
			for sourceFile in sourceFiles {
				assert(FileManager.default.fileExists(atPath: sourceFile.path), "Source file \(sourceFile.path) does not exist")
				
				let fileUrl = finalBookDir.appendingPathComponent(sourceFile.lastPathComponent)
				if !FileManager.default.fileExists(atPath: fileUrl.path) {
					try copyFile(from: sourceFile, to: fileUrl)
					stats.filesCopied += 1
				} else {
					log("File \(fileUrl.path) exists")
					stats.filesSkipped += 1
				}
			}
		}
		
		private func copyFile(from url: URL, to targetUrl: URL) throws {
			log("Copying file \(url.path) to \(targetUrl.path)")
			if !dryRun {
				try FileManager.default.copyItem(at: url, to: targetUrl)
			}
		}
		
		private func createDirectory(at url: URL, dryRun: Bool) throws {
			log("Creating directory \(url.path)")
			if !dryRun {
				try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
			}
		}
	}
}

extension Shelver {
	struct Summarize: ParsableCommand {
		nonisolated(unsafe) static var configuration = CommandConfiguration(
			commandName: "summarize",
			abstract: "Summarize the contents of a books.json file"
		)
		
		@Argument(help: "The path to the books.json file", completion: .file(extensions: ["json"]))
		var booksJsonPath: String
		
		func run() throws {
			let data = try Data(contentsOf: URL(fileURLWithPath: booksJsonPath))
			let books = try JSONDecoder().decode([Audiobook].self, from: data)
			
			// Build author list
			let authors = organize(books: books)
			
			printx(structured: authors)
		}
	}
}
