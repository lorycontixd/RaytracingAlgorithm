import "../src/hdrimage.nim"
import "../src/color.nim"
import std/[streams, random]

randomize()

var strmWrite = newFileStream("colored_image1.pfm", fmWrite)
var hdrImageWrite = newHdrImage(2, 2, hdrimage.Endianness.littleEndian)
var k: int = 0
for i in 0..hdrImageWrite.width-1:
    for j in countdown(hdrImageWrite.height-1, 0):
        hdrImageWrite.set_pixel(i,j, newColor(
          10000.0,
          10000.0,
          10000.0
        ))
        


hdrImageWrite.write_pfm(strmWrite)
var strm = newFileStream("colored_image1.pfm", fmRead)
var hdrRead = newHdrImage()
hdrRead.read_pfm(strm)



