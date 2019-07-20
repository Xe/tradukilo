import json, options, os, rdstdin, streams, strformat, strutils, tables

var fName: string

try:
  fName = paramStr 1
except:
  quit fmt"usage: {paramStr 0} <tokipona.json>"

type
  WordKind* = enum
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
    subject,
    verb,
    indirectObject,
    directObject,

  Phrase* = ref object
    case kind*: PhraseKind
    of PhraseKind.subject, PhraseKind.indirectObject, PhraseKind.directObject:
      noun*: Word
    of PhraseKind.verb:
      preverb*: Word
      verb*: Word

    modifiers*: Option[seq[Word]]

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
  of PhraseKind.subject, PhraseKind.indirectObject, PhraseKind.directObject:
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
  sentence = newSeq[Phrase]()
  curr: Phrase
  lastWord: Word

for word in splitSentence:
  if not dict.hasKey word:
    quit fmt"unknown word: {word}"

  let thisWord = dict[word]
  echo fmt"found: {thisWord}"

  for grm in thisWord.grammar:
    echo grm

  lastWord = thisWord
