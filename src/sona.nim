import json, options, os, rdstdin, streams, strformat, strutils, tables

var fName: string

try:
  fName = paramStr 1
except:
  quit fmt"usage: {paramStr 0} <tokipona.json>"

type
  WordKind* {.pure.} = enum
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
    name*: string
    grammar*: seq[WordKind]
    gloss*: string
    category*: Option[string]

  PhraseKind* {.pure.} = enum
    noun,
    verb,

  Phrase* = ref object
    case kind*: PhraseKind
    of PhraseKind.noun:
      noun*: Word
    of PhraseKind.verb:
      preverb*: Word
      verb*: Word

    modifiers*: Option[seq[Word]]

proc isNoun(w: Word): bool =
  result = false

  if WordKind.noun in w.grammar:
    result = true

proc isVerb(w: Word): bool =
  result = false

  if WordKind.intransitiveVerb in w.grammar or WordKind.transitiveVerb in w.grammar:
    result = true

proc isModifier(w: Word): bool =
  result = false

  if WordKind.modifier in w.grammar:
    result = true

proc `$`*(w: Word): string =
  if w.category.isSome:
    result = fmt"{w.name}: grammar({w.grammar}), gloss({w.gloss}), category({w.category.get})"
  else:
    result = fmt"{w.name}: grammar({w.grammar}), gloss({w.gloss})"

proc `$`*(p: Phrase): string =
  var
    base: string
    modifiers: string

  case p.kind
  of PhraseKind.noun:
    base = p.noun.name
  of PhraseKind.verb:
    base = p.verb.name

  if p.modifiers.isSome:
    var names = newSeq[string]()
    for modif in p.modifiers.get:
      names.add modif.name
    modifiers = fmt"modifiers: {names}"

  result = fmt"({p.kind}) {base} {modifiers}"

var
  nodes = json.parseFile fName
  words = nodes.to(seq[Word])
  dict = initTable[string, Word]()

for word in words:
  dict[word.name] = word

var
  rawSentence = readLineFromStdin "|toki: "
  splitSentence = rawSentence.split " "
  lastWord: Word

for word in splitSentence:
  if not dict.hasKey word:
    quit fmt"unknown word: {word}"

  let thisWord = dict[word]
  echo fmt"found: {thisWord.name}, noun: {thisWord.isNoun}, verb: {thisWord.isVerb}, mod: {thisWord.isModifier}"

  lastWord = thisWord
