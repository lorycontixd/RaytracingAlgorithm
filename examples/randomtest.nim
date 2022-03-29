import "../src/exception.nim"
import "../src/hdrimage.nim"
import "../src/logger.nim"
import std/monotimes
import std/strformat
import std/[times, os, math]

let hdr = newHdrImage()
logger.logLevel = Level.debug

const cLOOPS {.intdefine.} = 1225

addLogger(open("bench.log", fmWrite))
proc main=
    for i in 1 .. 1_000_000:
        #echo "Hello World!"
        info(fmt"Hello world{i}!!")

let strt = getMonotime()
main()
var elpsd: float64 = float64((getMonotime() - strt).inNanoseconds)
elpsd = float64(elpsd) * 1e-6
sleep(1)
info(fmt"Time elapsed in milliseconds: {elpsd} ")