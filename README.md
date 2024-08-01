![Screenshot_20221202-144458s](https://user-images.githubusercontent.com/59378400/205405480-b388d782-1288-4efa-838a-b7f5986baf1e.jpg)

# deployment

`flutter build web; firebase deploy --only hosting`

# mila
 Hebrew Vocabulary Trainer

Similar to Anki but specifically for Hebrew.

Definitions:
- **primary term** (word) corresponding to the first and second columns in the table are the Hebrew term and translation being learned
- **secondary terms** (words) are zero or many terms which are shown under the primary term and related to it. Usually these are synnyms or terms derived from the same roots

Only the first term is mandatory,

## Rules

Table columns:
1. Hebrew word with (best) or without with nikudim _(mandatory)_
2. English (or any other language) trabslation _(mandatory)_
3. Related Hebrew words, separated by slash `/` _(optional)_
4. Related translation related to Hebrew in previous column, also separated by slash `/` _(optional)_
5. An example sentence in Hebrew _(optional)_
6. Transkation of the example sentence _(optional)_
7. Transliteration of the Hebrew from column 1 _(optional)_

General rules:
- Empty table lines are allowed (discarded).
- Lines with not Hebrew cells in the first column are not treated as empty lines (discarded).

Not allowed:
- Repeating Hebrew (first column) terms. The not vocalized form is compared, therefore some not-so-seldom
words can lead to an error when loading a table
- Comma in the first column. Such a case of synonyms should be implemented using 3rd and 4th coulmn

## ToDo

List:
- prepare new lists
- go through the lists, standardize:
  - better, clear translation
  - vocalization
  - full spelling
  - most used case (evtl. synonyms)
  - synonyms with different translation
  - example sentence
  - no repetitions
  - standard form (infinitive, masc. singular)
  - plural/phrase if not standard
  - attribute if not standard

Tools:
- check for repetitions
- check for max length
- add Ulpan, etc. links in row 7
- add attribute for not standard items in row 8

Not standard attributes:
- nouns:
  - f. plural
  - m. plural
  - plural preferred
  - m. dual
  - f. plural as dual
  - dual
  - f. with m. ending
  - m. with f. ending
  - f. unexpected
  - m. unexpected
  - m. irregular
  - f. irregular
- verbs:
  - no infinitive
  - no past/present/future
  - irregular vocalization
  - irregular conjugation

General:
- use Isar database for serializing vocabulary for each entry:
  - key:String:unvocalized
  - int:level
  - String:vocalized
  - String:translation
- show current dictionary as vocabulary source, resolve numeric level values to text
- sanitize vocabulary:
  - check multiple entries, show an extra view
- copy to clipboard on click
- algorithm using “growth” on each iteration, negative value after being answered
- better colorful progress view:
  - total number: list name to the top
  - hidden in gray (not interested)
  - waiting in black (hourglass_full)
  - in progress in blue (repeat)
  - easy in green (done)
  - done in light green (done_all)
- three-lines menu with entries:
  - settings dialog (only in sources view)
  - button “move item to the end of the list“ (only in vocab view)
  - button “hide item” (only in vocab view)
  - about dialog with open email, GitHub link (all views)
  - download vocabulary (all views)

Settings:
- save settings to database
- edit pool size
- reorder dropdown: “natural” , “random” , “alphabetic aleph-tet” , “alphabetic a-z”, “easy first” , “hard first” , “unseen first”, “hidden first”
- new iteration order “view” with “prev” and “next” buttons

Links:
- automatic:
  - reverso
  - pealim
  - milon
  - academia
tools:
  - Ulpan
  - Mark Niran
  - HebrewToday

Multi-user:
- connect to account
- serialize settings to the cloud
- load custom lists

Problems:
- serialization haser-nikud & words different by vocalization
- learning of word groups



Scrap:
- Mark Niran
- He Academy
 
Links:
- Mark Niran
- Ulpan

Pealim:
- Find used
- List as table
- Fix problems
- Add root to the vocabulary
- Display same root verbs

Roots List:
- Mark Niran
- Pealim
- Facebook

Get Audio + Transkript:
- Nadya
- L’olamut
- Piece of He
- ???
 
Use Audio:
- Extract audio pieces (sentences?)
- Store audio, transcript online
- Add Links
