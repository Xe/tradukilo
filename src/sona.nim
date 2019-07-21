import json, options, os, rdstdin, streams, strformat, strutils, tables

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

  PhraseKind* {.pure.} = enum
    ## The kind of phrase, used for parsing.
    noun,
    verb,

  Phrase* = ref object
    ## A phrase is a group of words.
    case kind*: PhraseKind
    of PhraseKind.noun:
      noun*: Word
    of PhraseKind.verb:
      preverb*: Word
      verb*: Word

    modifiers*: Option[seq[Word]]

proc isNoun*(w: Word): bool =
  ## Returns true if the Word is a noun.
  result = false

  if WordKind.noun in w.grammar:
    result = true

proc isVerb*(w: Word): bool =
  ## Returns true if the Word is a verb (transitive or intransitive).
  result = false

  if WordKind.intransitiveVerb in w.grammar or WordKind.transitiveVerb in w.grammar:
    result = true

proc isModifier*(w: Word): bool =
  ## Returns true if the word is a modifier (~= adjective).
  result = false

  if WordKind.modifier in w.grammar:
    result = true

proc `$`*(w: Word): string =
  ## Pretty-prints a Word
  if w.category.isSome:
    result = fmt"{w.name}: grammar({w.grammar}), gloss({w.gloss}), category({w.category.get})"
  else:
    result = fmt"{w.name}: grammar({w.grammar}), gloss({w.gloss})"

proc loadDictionary*(s: Stream): TableRef[string, Word] =
  ## Loads the toki pona dictionary into a Table from a Stream.
  var
    nodes = json.parseJson(s)
    words = nodes.to seq[Word]
  result = newTable[string, Word]()

  for word in words:
    result[word.name] = word

const
  tpDictionary = staticRead "../data/tokipona.json"

var
  dict = loadDictionary(newStringStream tpDictionary)
  rawSentence = readLineFromStdin "|toki: "
  splitSentence = rawSentence.split " "
  lastWord: Word

for word in splitSentence:
  if not dict.hasKey word:
    quit fmt"unknown word: {word}"

  let thisWord = dict[word]
  echo fmt"found: {thisWord.name}, noun: {thisWord.isNoun}, verb: {thisWord.isVerb}, mod: {thisWord.isModifier}"

  lastWord = thisWord
