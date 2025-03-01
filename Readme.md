Move Audiobooks from [OpenAudible](https://openaudible.org) to [AudioBookshelf](https://www.audiobookshelf.org).

## Shelver

- Read metadata from OpenAudible's books.json
- Generate [folder structure AudioBookshelf expects](https://www.audiobookshelf.org/docs/#book-directory-structure)
- Copy files to AudioBookshelf's folder structure
	- Favors .m4b files 
	- Uses apfs cloning when source and destination are on the same volume

If you want to keep a library up to date over time, 
it's best to create a configuration file at `~/.config/shelver/config.json`

```
{
"openAudiblePath":"/absolute/path/to/OpenAudible/books.json",
"audioBookshelfPath":"/absolute/path/to/AudioBookshelf/library/AudioBooks/"
}
```

```
USAGE: shelver [<books-json-path>] [--print-structure] [--verbose] [<output-path>] [--dry-run]

ARGUMENTS:
  <books-json-path>       The path to the books.json file
  <output-path>           The path to the AudioBookshelf directory

OPTIONS:
  --print-structure       Print the author, series, title structure to the console
  --verbose               Show verbose output
  --dry-run               Do not copy files or create directories.
  ```

