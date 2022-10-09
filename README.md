# mila
 Hebrew Vocabulary Trainer

Similar to Anki but specifically for Hebrew

ToDo:


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
  - check multiple entries
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
