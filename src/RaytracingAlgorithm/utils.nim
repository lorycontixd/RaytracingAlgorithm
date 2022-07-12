import std/[os, strutils, macros, parsecfg, times, terminal, options]

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

proc bufferToArray32*(s: seq[byte]): array[12, byte]{.inline.}=
    assert len(s)==12
    var x: array[12, byte]
    for i in 0..len(s)-1:
        x[i] = s[i]
    return x

proc bytesToString*(bytes: openarray[byte]): string =
    result = newString(bytes.len)
    copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

proc IsEqual*(x,y: float32, epsilon:float32=1e-5): bool {.inline.}=
    ## Function to verify if two floats are approximately equal
    ## 
    ## Parameters
    ## - x (float32): left float
    ## - y (float32): right float
    ## 
    ## Returns
    ##      True (floats are close) or False (floats are not equal)
    return abs(x - y) < epsilon

proc size*[T](x: T): int =
    #[
        Returns the size of a container of type T
    ]#
    for _ in x:
        inc result

proc getFileCount*(dirPath: string): int =
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

proc byteSeqToChar*(s: seq[byte]): seq[char] {.inline.}=
    result = newSeq[char](size(s))
    for i in 0..size(s)-1:
        result[i] = cast[char](s[i])

proc clampFloat*(x: float32): float32=
    return x/(1+x)

proc cmdArgsToString*(): string=
    var str: string = ""
    for param in commandLineParams():
        str = str & param & " "
    str = str[0 .. ^2]
    return str

proc getPackageVersion*(isMainModule: bool = false): Option[string]=
    if isMainModule:
        var p: Config = loadConfig(joinPath(packageRootDir, "RaytracingAlgorithm.nimble"))
        result = some(p.getSectionValue("", "version"))
    else:
        result = none(string)

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

proc showBar*(content: string) =
    stdout.eraseLine
    stdout.write("[$1]" % [content])
    stdout.flushFile

proc progressBar*()=
    for i in 0..100:
        stdout.styledWriteLine(fgRed, "0% ", fgWhite, '#'.repeat i, if i > 50: fgGreen else: fgYellow, "\t", $i , "%")
        sleep 42
        cursorUp 1
        eraseLine()

    stdout.resetAttributes()


macro injectProcName*(procDef: untyped): untyped =
  procDef.expectKind({nnkProcDef, nnkMethodDef, nnkFuncDef})
  
  let
    procName = procDef[0].toStrLit
    procNameId = ident("procName")
  
  let pnameDef = quote do:
    let `procNameId` = `procName`
  
  procDef.body.insert(0, pnameDef)
  
  return procDef


proc TriangulatePolygon*(vertices: seq[int]): seq[int]=
    if len(vertices) == 0:
        return @[]
    var newVertices: seq[int]
    var pivot: int = vertices[0]
    for i in 1..len(vertices)-2:
        newVertices.add(pivot)
        newVertices.add(vertices[i])
        newVertices.add(vertices[i+1])
    return newVertices


        

