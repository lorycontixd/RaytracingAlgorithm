import std/[times, nimprof, typetraits, strutils, options]
import renderer

type
    FunctionCallback* = object
        funcName*: string
        timeTaken*: float32
        callCount*: int
        timePerCall: float32
        depth*: int

    Stats* = object
        # time
        startTime*: DateTime
        endTime*: DateTime
        duration*: Duration

        # tools
        renderer*: string
        imageWidth*: int
        imageHeight*: int
        
        #pcg
        averageFloatExtracted*: float32

        # rays
        
        raysShot*: int

        # world
        shapeCount: int

        # function callbacks
        functionCallbacks: seq[FunctionCallback]

## function callback
func newFunctionCallback*(fname: string): FunctionCallback=
    return FunctionCallback(funcName: fname, callCount: 0)

func newFunctionCallback*(fName: string, timeTaken: float32): FunctionCallback=
    return FunctionCallback(funcName: fName, timeTaken: timeTaken, callCount: 0)

func newFunctionCallback*(fName: string, timeTaken: float32, callCount: int, depth: int = 1): FunctionCallback=
    return FunctionCallback(funcName: fName, timeTaken: timeTaken, callCount: callCount, timePerCall: timeTaken/callCount.float32, depth: depth)

func AddTimer*(self: var FunctionCallback, duration: float32): void=
    self.timeTaken = self.timeTaken + duration

proc AddCall*(self: var FunctionCallback, duration: float32): void=
    self.AddTimer(duration)
    inc self.callCount

## stats

proc newStats*(): Stats =
    return Stats(startTime: now(), functionCallbacks: newSeq[FunctionCallback]())

proc newStats*(renderer: Renderer): Stats =
    let renderer = $renderer.type.name.toLowerAscii()
    return Stats(startTime: now(), renderer: renderer, functionCallbacks: newSeq[FunctionCallback]())

proc closeStats*(self: var Stats): void =
    self.endTIme = now()
    self.duration = self.endTime - self.startTime

proc FindFunctionCallback*(self: var Stats, fName: string): Option[FunctionCallback]=
    echo "fname: ",fName
    for i in 0..self.functionCallbacks.high:
        if self.functionCallbacks[i].funcName == fName:
            return some(self.functionCallbacks[i])
    return none(FunctionCallback)

func ToFile*(): void = discard

func Show*(): void = discard

proc AddCall*(self: var Stats, fName: string, duration: float32): void=
    let res = self.FindFunctionCallback(fName)
    if not res.isSome:
        self.functionCallbacks.add(newFunctionCallback(fName, cast[float32](duration), 1))
    else:   
        var callback: FunctionCallback =  res.get()
        callback.AddCall(duration)


func SetRaysShot*(self: var Stats, renderer: Renderer): void=
    self.raysShot = renderer.raysShot


###
var 
    mainStats* = newStats()