import os, parsexml, streams, strformat, strutils

var fName: string

try:
  fName = paramStr 1
except:
  quit fmt"usage: {paramStr 0} <vortaro.xml>"

var s = newFileStream(fName, fmRead)
if s == nil: quit("cannot open the file " & fName)

type
  Form = ref object
    pre: string
    suf: string
    grm: seq[string]

  Vorto = ref object
    root: string
    forms: seq[Form]

proc computeForms(v: Vorto): seq[string] =
  for form in v.forms:
    result.add fmt"{form.pre}{v.root}{form.suf}"

var
  lastRoot: string
  vortoj = newSeq[Vorto]()
  x: XmlParser
  curr: Vorto
  currForm: Form

x.open s, fName
block mainLoop:
  while true:
    x.next

    case x.kind
    of xmlElementOpen:
      case x.elementName
      of "rdk":
        curr = Vorto()
      of "drv":
        currForm = Form()
    of xmlElementEnd:
      case x.elementName
      of "rdk":
        vortoj.add curr
        discard
      of "drv":
        curr.forms.add currForm
    of xmlAttribute:
      case x.attrKey
      of "v":
        curr.root = x.attrValue
      of "grm":
        currForm.grm = x.attrValue.split " "
      of "pre":
        currForm.pre = x.attrValue
      of "suf":
        currForm.suf = x.attrValue
    of xmlEof: break
    of xmlError:
      echo x.errorMsg
    else: discard

x.close

for vorto in vortoj:
  echo vorto.computeForms

echo GC_getStatistics()
