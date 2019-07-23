# Package

version       = "0.1.0"
author        = "Christine Dodrill"
description   = "Linguistic tools for Nim"
license       = "0BSD"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["tradukilo", "tradukilopkg/sona"]
binDir        = "bin"


# Dependencies

requires "nim >= 0.20.0"
