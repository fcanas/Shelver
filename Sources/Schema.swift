import Foundation

struct Audiobook: Codable {
	let abridged: String?
	let asin: String
	let author: String
	let authorLink: String?
	let ayce: String
	let chapters: [Chapter]
	let copyright: String?
	let description: String
	let downloadLink: String
	let duration: String
	let filename: String
	let files: [AudioFile]
	let genre: String
	let imageUrl: String
	let infoLink: String
	let key: String
	let language: String
	let narratedBy: String
	let productId: String
	let publisher: String
	let purchaseDate: String
	let ratingAverage: String
	let ratingCount: String
	let readStatus: String
	let region: String
	let releaseDate: String
	let seconds: Int
	let seriesLink: String?
	let seriesName: String?
	let seriesSequence: String?
	let summary: String
	let title: String
	let titleShort: String
	let userId: String
	
	enum CodingKeys: String, CodingKey {
		case abridged, asin, author, copyright, description, duration, filename
		case genre, key, language, publisher, region, seconds, summary, title
		case authorLink = "author_link"
		case ayce
		case chapters
		case downloadLink = "download_link"
		case files
		case imageUrl = "image_url"
		case infoLink = "info_link"
		case narratedBy = "narrated_by"
		case productId = "product_id"
		case purchaseDate = "purchase_date"
		case ratingAverage = "rating_average"
		case ratingCount = "rating_count"
		case readStatus = "read_status"
		case releaseDate = "release_date"
		case seriesLink = "series_link"
		case seriesName = "series_name"
		case seriesSequence = "series_sequence"
		case titleShort = "title_short"
		case userId = "user_id"
	}
}

struct Chapter: Codable {
	let lengthMs: Int
	let startOffsetMs: Int
	let startOffsetSec: Int
	let title: String
	
	enum CodingKeys: String, CodingKey {
		case lengthMs = "length_ms"
		case startOffsetMs = "start_offset_ms"
		case startOffsetSec = "start_offset_sec"
		case title
	}
}

struct AudioFile: Codable {
	let kind: String
	let path: String
	let type: String
}

extension Audiobook: Hashable {
}
extension AudioFile: Hashable {
}
extension Chapter: Hashable {
}


