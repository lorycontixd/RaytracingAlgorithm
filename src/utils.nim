import std/[strutils, strformat, macros]
from macros import newTree, nnkBracket, newLit
from sequtils import mapIt


proc toString*(bytes: openarray[byte]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

proc byteArrayToHex32*(a: array[4,byte]): string {.inline.}=
    var b: array[4, string]
    for i in 0..len(a)-1:
      b[i] = toHex(a[i])
    result = fmt"{b[0]}{b[1]} {b[2]}{b[3]}"

proc seqToArray32*(s: seq[byte]): array[4, byte] {.inline.} =
    assert len(s)==4
    var x: array[4, byte]
    for i in 0..len(s)-1:
        x[i] = s[i]
    return x

proc size*[T](x: T): int =
    for _ in x:
        inc result

proc charSeqToByte*(s: seq[char]): seq[byte] {.inline.}= 
    echo size(s)
    result = newSeq[byte](size(s))
    for i in 0..size(s)-1:
        result[i] = cast[byte](s[i])

