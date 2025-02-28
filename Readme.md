Move Audiobooks from OpenAudible to AudioBookshelf.

## OpenAudible

https://openaudible.org/

- Downloads audiobooks
- Keeps them in a flat folder
- Keeps metadata in a books.json file

## AudioBookshelf

- Requires audiobooks organized in a particular hierarchical folder structure
  to discover books.

https://www.audiobookshelf.org/docs/#book-directory-structure

## apfs

- Clone files when source and destination are in the same apfs volume

## Shelver

- Read metadata from OpenAudible's books.json
- Generate folder structure AudioBookshelf expects
- Copy files to AudioBookshelf's folder structure
	- Uses apfs hardlinks to save space
