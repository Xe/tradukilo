import json, options, streams, strformat, tables

type
  WordKind* {.pure.} = enum
    ## Word types. These map to English terms, approximately.
    noun = "n",
    intransitiveVerb = "vi",
    transitiveVerb = "vt",
    modifier = "mod",
    interjection = "interj",
    conjunction = "conj",
    separator = "sep",
    preposition = "prep",
    punctuation = "punct",

  Word* = ref object of RootObj
    ## An individual Toki Pona word.
    name*: string
    grammar*: seq[WordKind]
    gloss*: string
    category*: Option[string]

proc isMiSina*(w: Word): bool =
  ## Returns true if the word is "mi" or "sina", as these require special rules
  case w.name
  of "mi", "sina":
    return true

proc isNoun*(w: Word): bool =
  ## Returns true if the Word is a noun.
  result = WordKind.noun in w.grammar

proc isVerb*(w: Word): bool =
  ## Returns true if the Word is a verb (transitive or intransitive).
  result = WordKind.intransitiveVerb in w.grammar or WordKind.transitiveVerb in w.grammar

proc isTransitiveVerb*(w: Word): bool =
  ## Returns true if the Word is a transitive verb.
  result = WordKind.transitiveVerb in w.grammar

proc isIntransitiveVerb*(w: Word): bool =
  ## Returns true if the Word is a intransitive verb.
  result = WordKind.intransitiveVerb in w.grammar

proc isModifier*(w: Word): bool =
  ## Returns true if the word is a modifier (~= adjective).
  result = WordKind.modifier in w.grammar

proc `$`*(w: Word): string =
  ## Pretty-prints a Word.
  if w.category.isSome:
    result = fmt"{w.name}: grammar({w.grammar}), gloss({w.gloss}), category({w.category.get})"
  else:
    result = fmt"{w.name}: grammar({w.grammar}), gloss({w.gloss})"

type GrammaticallyWrong* = ref object of ValueError

proc loadDictionary*(): TableRef[string, Word] =
  ## Loads the toki pona dictionary into a Table from precompiled data.
  const tpDictionary = staticRead "../../data/tokipona.json"
  var
    nodes = parseJson tpDictionary
    words = nodes.to seq[Word]
  result = newTable[string, Word]()

  for word in words:
    result[word.name] = word

