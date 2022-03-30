import std/[os, strutils, strformat, macros, parsecfg]
from macros import newTree, nnkBracket, newLit
from sequtils import mapIt

#[
proc toString*(bytes: openarray[byte]): string =
    #[
        Converts an array of bytes to string

        Parameters:
            array of bytes to be converted
        Returns:
            string: 
    ]#
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

proc byteArrayToHex32*(a: array[4,byte]): string {.inline.} {.deprecated: "use toString instead".}=
    var b: array[4, string]
    for i in 0..len(a)-1:
      b[i] = toHex(a[i])
    result = fmt"{b[0]}{b[1]} {b[2]}{b[3]}"
]#

proc seqToArray32*(s: seq[byte]): array[4, byte] {.inline.} =
    #[
        Converts a sequence of bytes into a 32 bit array.
    ]#
    assert len(s)==4
    var x: array[4, byte]
    for i in 0..len(s)-1:
        x[i] = s[i]
    return x

proc size*[T](x: T): int =
    #[
        Returns the size of a container of type T
    ]#
    for _ in x:
        inc result

proc charSeqToByte*(s: seq[char]): seq[byte] {.inline.}= 
    #[
        Converts a sequence of char into a sequence of bytes.
    ]#
    #echo size(s)
    result = newSeq[byte](size(s))
    #echo "- ",s
    for i in 0..size(s)-1:
        result[i] = cast[byte](s[i])

proc clampFloat*(x: float32): float32=
    return x/(1+x)

proc cmdArgsToString*(): string=
    var str: string = ""
    for param in commandLineParams():
        str = str & param & " "
    str = str[.. ^2]
    return str

proc getPackageVersion*(): string=
    var p: Config = loadConfig(joinPath(parentDir(getCurrentDir()), "RaytracingAlgorithm.nimble"))
    result = p.getSectionValue("", "version") 