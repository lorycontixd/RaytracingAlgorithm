import std/[streams, random]
import "../src/hdrimage.nim"
import "../src/color.nim"

randomize()

var strm1: FileStream = newFileStream("colored_image1.pfm", fmWrite)
var hdr1: HdrImage = newHdrImage(2560, 1440, hdrimage.Endianness.littleEndian)

for i in 0..(hdr1.width*hdr1.height)-1:
    let
        col = i mod hdr1.width
        row = int(i/hdr1.height)
    # echo "col: ",col/hdr1.
    hdr1.pixels[i] = newColor(float(col/hdr1.width), float(0.0), float(0.0))
hdr1.write_pfm(strm1)