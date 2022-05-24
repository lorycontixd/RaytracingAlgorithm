import std/[times, typetraits, strutils, options, locks, strformat, streams]
type
    FunctionCallback* = object
        funcName*: string
        timeTaken*: Duration
        callCount*: int
        timePerCall: float64
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
    return FunctionCallback(funcName: fname, callCount: 1)

func newFunctionCallback*(fName: string, timeTaken: Duration): FunctionCallback=
    return FunctionCallback(funcName: fName, timeTaken: timeTaken, callCount: 1)

func newFunctionCallback*(fName: string, timeTaken: Duration, depth: int = 1): FunctionCallback=
    return FunctionCallback(funcName: fName, timeTaken: timeTaken, callCount: 1, timePerCall: float32(timeTaken.inSeconds)/1.0, depth: depth)

func AddTimer*(self: var FunctionCallback, duration: Duration): void=
    self.timeTaken += duration

proc AddFuncCall*(self: var FunctionCallback, duration: Duration): void=
    self.AddTimer(duration)
    inc self.callCount
    self.timePerCall = float64(self.timeTaken.inSeconds) / float64(self.callCount)


#### stats
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

proc ToString*(self: var Stats): string =
    let startdate = self.startTime.format("yyyy-MM-dd, HH:mm:ss")
    var enddate: string
    try:
        enddate = self.endTime.format("yyyy-MM-dd, HH:mm:ss")
    except:
        self.closeStats()
        enddate = self.endTime.format("yyyy-MM-dd, HH:mm:ss")
    var s: string = "--------- Raytracing Statistics ---------\n"
    s = s & "[Time taken]\n"
    s = s & "- Start: " & startdate & "\n"
    s = s & "- End: " & enddate & "\n"
    s = s & "- Total duration: " & $self.duration & "\n\n"
    s = s & "[Function Callbacks]\n"
    for callback in  self.functionCallbacks:
        s = s & "-- " & callback.funcName & " --> Total Time: " & $callback.timeTaken.inSeconds & ",  Call count: " & $callback.callCount & ",  Average Time Per Call: " & formatFloat(callback.timePerCall, ffDecimal, 9) & ",  Depth: " & $callback.depth & "\n"
    return s

proc Show*(self: var Stats): void =
    echo self.ToString()

proc ToFile*(self: var Stats): void =
    var strm: FileStream = newFileStream("stats.txt", fmWrite)
    strm.write(self.ToString())

proc AddCall*(self: var Stats, fName: string, duration: Duration) {.thread, gcsafe.}=
    let res = self.FindFunctionCallback(fName)
    if not res.isSome:
        self.functionCallbacks.add(newFunctionCallback(fName, cast[Duration](duration), 1))
    else:   
        var callback_index: int = res.get()
        self.functionCallbacks[callback_index].AddFuncCall(duration)

proc AddCall*(self: var Stats, fName: string, duration: Duration, depth: int) {.thread, gcsafe.}=
    let res = self.FindFunctionCallback(fName)
    if not res.isSome:
        self.functionCallbacks.add(newFunctionCallback(fName, duration, depth))
    else:   
        var callback_index: int = res.get()
        self.functionCallbacks[callback_index].AddFuncCall(duration)

func SetRaysShot*(self: var Stats, rays: int): void=
    self.raysShot = rays


###
var
    mainStats* = newStats()
