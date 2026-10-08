name = "mizchi/sqlite"

version = "0.3.1"

import {
  "moonbitlang/x@0.4.40",
}

readme = "README.md"

repository = "https://github.com/mizchi/sqlite.mbt"

license = "MIT"

keywords = [ "native", "sqlite", "js" ]

description = "libsqlite3 bindings for MoonBit"

source = "."

preferred_target = "native"

options(
  exclude: [ "example", "sqlite_bench.ts" ],
)
