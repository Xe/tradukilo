import json, options, os, streams, strformat, strutils

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

  Word* = object of RootObj
    name*: string
    grammar*: seq[WordKind]
    gloss*: string
    category*: Option[string]

var
  nodes = json.parseFile fName
  words = nodes.to(seq[Word])

for word in words:
  echo word
