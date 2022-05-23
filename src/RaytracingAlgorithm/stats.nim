import std/[times, nimprof, typetraits, strutils, options, locks]
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

    ThreadData = tuple[stat: Stats, fName: string, duration: float32]

## function callback
func newFunctionCallback*(fname: string): FunctionCallback=
    return FunctionCallback(funcName: fname, callCount: 0)

func newFunctionCallback*(fName: string, timeTaken: float32): FunctionCallback=
    return FunctionCallback(funcName: fName, timeTaken: timeTaken, callCount: 0)

func newFunctionCallback*(fName: string, timeTaken: float32, callCount: int, depth: int = 1): FunctionCallback=
    return FunctionCallback(funcName: fName, timeTaken: timeTaken, callCount: callCount, timePerCall: timeTaken/callCount.float32, depth: depth)

func AddTimer*(self: var FunctionCallback, duration: float32): void=
    self.timeTaken = self.timeTaken + duration

proc AddFuncCall*(self: var FunctionCallback, duration: float32): void=
    self.AddTimer(duration)
    inc self.callCount

## stats

proc newStats*(): Stats =
    return Stats(startTime: now(), functionCallbacks: newSeq[FunctionCallback]())

proc newStats*(renderer: string): Stats =
    return Stats(startTime: now(), renderer: renderer, functionCallbacks: newSeq[FunctionCallback]())

proc closeStats*(self: var Stats): void =
    self.endTIme = now()
    self.duration = self.endTime - self.startTime

proc FindFunctionCallback*(self: var Stats, fName: string): Option[int]=
    for i in 0..self.functionCallbacks.high:
        if self.functionCallbacks[i].funcName == fName:
            return some(i)
    return none(int)

func ToFile*(): void = discard

func Show*(): void = discard

proc AddCall*(self: var Stats, fName: string, duration: float32) {.thread, gcsafe.}=
    let res = self.FindFunctionCallback(fName)
    if not res.isSome:
        self.functionCallbacks.add(newFunctionCallback(fName, cast[float32](duration), 1))
    else:   
        var callback_index: int = res.get()
        self.functionCallbacks[callback_index].AddFuncCall(duration)

proc Test*(s: Stats, i: int) {.thread.}=
    echo "hi"

func SetRaysShot*(self: var Stats, rays: int): void=
    self.raysShot = rays


###
var
    mainStats* = newStats()
