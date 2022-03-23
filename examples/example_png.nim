import os
import std/[strutils, streams]
import "../src/hdrimage.nim"
import "../src/color.nim"

##### Parameters
# 1. Input PFM filename (string)
# 2. Factor (float)
# 3. Gamma (float)
# 4. Output PNG filename (string)

var
    pfm_inputfile: string = paramStr(1)
    factor: float32 = parseFloat(paramStr(2))
    gamma: float32 = parseFloat(paramStr(3))
    ldr_outputfile = paramStr(4)

echo pfm_inputfile
echo factor
echo gamma
echo ldr_outputfile

var hdr = newHdrImage(5,5)

let strm = newFileStream(pfm_inputfile, fmRead)
hdr.read_pfm(strm)

hdr.normalize_image(factor)
hdr.clamp_image()
hdr.write_png(ldr_outputfile, gamma)