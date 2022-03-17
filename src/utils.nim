import std/[strutils, strformat]
from macros import newTree, nnkBracket, newLit
from sequtils import mapIt


proc hexDump*[T](v: T): string =
  var s: seq[uint8] = @[]
  s.setLen(v.sizeof)
  copymem(addr(s[0]), v.unsafeAddr, v.sizeof)
  result = ""

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

proc concatArrays[I1, I2: static[int]; T](a: array[I1, T], b: array[I2, T]): array[I1 + I2, T] =
  result[0..a.high] = a
  result[a.len..result.high] = b