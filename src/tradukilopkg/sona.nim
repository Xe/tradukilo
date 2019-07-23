import json, options, os, rdstdin, streams, strformat, strutils, tables
import tokipona

var
  dict = loadDictionary()
  rawSentence = readLineFromStdin "|toki: "
  splitSentence = rawSentence.split " "
  lastWord: Option[Word]
  first = true

for word in splitSentence:
  if not dict.hasKey word:
    quit fmt"unknown word: {word}"

  let thisWord = dict[word]
  echo fmt"found: {thisWord}"

  if lastWord.isSome:
    let lw = lastWord.get

    if not lw.isMiSina:
      if lw.isNoun and not lw.isModifier:
        raise GrammaticallyWrong(msg: fmt"invalid noun -> modifier transition: ({thisWord}) to ({lw})")

      if lw.isNoun or lw.isModifier:
        if thisWord.isVerb:
          raise GrammaticallyWrong(msg: fmt"invalid noun -> verb transition: ({thisWord}) to ({lw})")

    echo fmt"last:  {lw}"
    first = false

  lastWord = some thisWord
