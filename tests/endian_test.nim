import std/endians
import std/streams
import "../src/HdrImage.nim"


# Endians tst
var
    flt: float32
    inp: array[4, uint8] = [byte 195, 245, 72, 64]
    line = ""

littleEndian32(addr flt, addr inp)

# Streams test
var strm = newFileStream("helloworld.txt", fmRead)
if not isNil(strm):
    while strm.readLine(line):
        echo line

var str: string = "\n\n\n\n\n\n"
echo str.toOpenArrayByte(0, str.high) # string -> byte array


var h = newHdrImage(10,10)
var res: string = h.parse_endianess("pippo")