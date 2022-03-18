import std/[streams]
import "../src/hdrimage.nim"

var hdr = newHdrImage(5,5, hdrimage.Endianness.littleEndian)

var writeStrm1: FileStream = newFileStream("images/res2.pfm", fmWrite)
hdr.write_pfm(writeStrm1)