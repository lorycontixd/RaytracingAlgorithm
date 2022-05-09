import std/[os, strutils, strformat, macros, parsecfg, times]
from sequtils import mapIt
import neo

let packageRootDir* = joinPath(parentDir(getCurrentDir()), "")

func deleteWord*(s: var string, id: int): string =
    let copy = s
    var x = copy.split(" ")
    x.delete(id)
    let y = join(x, " ")
    return y

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

proc getFileCount(dirPath: string): int =
    result = 0
    for kind, path in walkDir(dirPath):
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
    str = str[0 .. ^2]
    return str

proc getPackageVersion*(): string=
    var p: Config = loadConfig(joinPath(packageRootDir, "RaytracingAlgorithm.nimble"))

    result = p.getSectionValue("", "version") 

proc getMatrixRows*(m: Matrix): int =
    var k: int = 0
    for i in m.rows:
        inc k
    return k

proc getMatrixCols*(m: Matrix): int =
    var k: int = 0
    for i in m.columns:
        inc k
    return k

proc getMatrixSize*(m: Matrix): (int,int)=
    result = (getMatrixRows(m), getMatrixCols(m))


macro apply*(f, t: typed): auto =
  var args = newSeq[NimNode]()
  let ty = getTypeImpl(t)
  assert(ty.typeKind == ntyTuple)
  for child in ty:
    expectKind(child, nnkIdentDefs)
    args.add(newDotExpr(t, child[0]))
  result = newCall(f, args)

template timeIt*(theFunc: proc, passedArgs: varargs[untyped]): untyped =
  let t = cpuTime()
  let res = theFunc(passedArgs)
  echo "Time taken: ",cpuTime() - t
  res