import "../src/hdrimage.nim"
import "../src/color.nim"
import std/[streams, random]

randomize()

var strmWrite = newFileStream("colored_image1.pfm", fmWrite)
var hdrImageWrite = newHdrImage(1440 , 900, hdrimage.Endianness.littleEndian)
var k: int = 0
for i in 0..hdrImageWrite.width-1:
    for j in 0..hdrImageWrite.height-1:
        hdrImageWrite.set_pixel(i,j, newColor(
            rand(1.0),
            float((i)/(hdrImageWrite.width + hdrImageWrite.height)),
            float((j)/(hdrImageWrite.width + hdrImageWrite.height))
        ))


hdrImageWrite.write_pfm(strmWrite)

var strm = newFileStream("colored_image1.pfm", fmRead)
var hdrRead = newHdrImage()
hdrRead.read_pfm(strm)
echo hdrRead.pixels[0]

