import unittest
import streams
import "../src/hdrimage.nim"
import "../src/color.nim"
type Endianness = hdrimage.Endianness

var hdr = newHdrImage(1000,100)
assert hdr.valid_coordinates(1,1)
#assert hdr.valid_coordinates(-1,1) # correctly failed
#assert hdr.valid_coordinates(21,1) # correctly failed
#assert hdr.valid_coordinates(1,11) # correctly failed


var hdr1 = newHdrImage(120,120,Endianness.littleEndian)
#assert endianTable[hdr1.endianness] == "<f"
assert hdr1.endianness == Endianness.littleEndian

var readstrm : FileStream = newFileStream("images/memorial.pfm", fmRead)
var writestrm : FileStream = newFileStream("images/res1.pfm", fmWrite)

var hdr2 = hdr.read_pfm(readstrm)
hdr.write_black(writestrm)
