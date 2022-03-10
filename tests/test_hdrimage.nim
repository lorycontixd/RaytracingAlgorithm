import unittest
import "../src/HdrImage.nim"
import "../src/color.nim"

var hdr = newHdrImage(20,10)
assert hdr.valid_coordinates(1,1)
assert hdr.valid_coordinates(-1,1) # correctly failed
assert hdr.valid_coordinates(21,1) # correctly failed
assert hdr.valid_coordinates(1,11) # correctly failed

