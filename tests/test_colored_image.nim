import "../src/hdrimage.nim"
import "../src/color.nim"
import std/[streams, random]

randomize()

var strmWrite = newFileStream("colored_image1.pfm", fmWrite)
var hdrImageWrite = newHdrImage(1440 , 900, hdrimage.Endianness.littleEndian)
var k: int = 0
hdrImageWrite.fill_gradient()


hdrImageWrite.write_pfm(strmWrite)

var strm = newFileStream("colored_image1.pfm", fmRead)
var hdrRead = newHdrImage()
hdrRead.read_pfm(strm)
echo hdrRead.pixels[0]

