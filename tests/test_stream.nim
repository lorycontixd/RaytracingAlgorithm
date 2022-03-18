import std/endians
import std/streams
import std/strformat
import std/strutils
import "../src/hdrimage.nim"
import "../src/utils.nim"

type Endianness = hdrimage.Endianness


# Endians tst
var
    flt: float32 = 3.1415
    inp: array[4, uint8]# = [byte 195, 245, 72, 64]
    line = ""

littleEndian32(addr inp, addr flt) # float -> array
echo inp    


let hexarray = byteArrayToHex32(inp)
echo hexarray
let x = -1.0
echo x.formatFloat(ffDecimal, 4)


var writeStream: FileStream = newFileStream("test.pfm",  fmWrite)
var hdr1 : HdrImage = newHdrImage(20,20, Endianness.littleEndian)

#let newbyte = hexToByteArray32(hexarray)
#echo newbyte
#hdr1.write_pfm(writeStream)


#[
# Streams test
var strm = newFileStream("helloworld.txt", fmRead)
if not isNil(strm):
    while strm.readLine(line):
        echo line

var str: string = "\n\n\n\n\n\n"
echo str.toOpenArrayByte(0, str.high) # string -> byte array


var h = newHdrImage(10,10)
var res: string = h.parse_endianess("pippo")
]#
