import os
import std/[os, strutils, streams, terminal, parsecfg]
import therapist
import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/logger.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import "../src/RaytracingAlgorithm/exception.nim"

##### Parameters
# 1. Input PFM filename (string)
# 2. Factor (float)
# 3. Gamma (float)
# 4. Output PNG filename (string)
 

# The parser is specified as a tuple
let spec = (
    # Name is a positional argument, by virtue of being surrounded by < and >
    inputfile: newStringArg(@["<input_image>"], help="Input HDR image to be converted to LDR."),
    # Name is a positional argument, by virtue of being surrounded by < and >
    outputfile: newStringArg(@["<output_image>"], help="Name for the output LDR image (currently can only be .png)"),
    # -- factor 
    factor: newFloatArg(@["-f", "--factor"], default=1, help="Luminosity correction factor."),
    # -- gamma
    gamma: newFloatArg(@["-g", "--gamma"], default=1, help="Gamma factor of the monitory for image correction."),

    # --version will cause 0.1.0 to be printed
    version: newMessageArg(@["--version"], getPackageVersion(), help="Prints version"),
    # --help will cause a help message to be printed
    help: newHelpArg(@["-h", "--help"], help="Show help message")
)


let args_string = cmdArgsToString()
let (success, message) = spec.parseOrMessage(prolog="Convert HDR image to .png format", args=args_string, command="example_png")
if not success:
    stdout.styledWriteLine(fgRed, "There was an error while parsing the input commands. Please view the help message.")
    spec.parseOrQuit(prolog="Convert HDR image to .png format", args="--help", command="example_png")

var hdr = newHdrImage(5,5)
let strm = newFileStream(spec.inputfile.value, fmRead)
hdr.read_pfm(strm)
hdr.normalize_image(spec.factor.value)
hdr.clamp_image()
hdr.write_png(spec.outputfile.value, spec.gamma.value)
