
import RaytracingAlgorithm/[hdrimage, geometry, utils, logger, shape, ray, transformation, world, rayhit, imagetracer]
import std/[parsecfg, os, streams, times]
import therapist

when isMainModule:
    addLogger( open( joinPath(getCurrentDir(), "main.log"), fmWrite))
    #info("Running RaytracingAlgorithm on version ",getPackageVersion())
    debug("Creating variables")
    var
        scene: World = newWorld()

        vertex_spheres: seq[Sphere] = newSeq[Sphere](8)
        #imagetracer: ImageTracer = newImageTracer()


    let cube = (
        width: newIntArg(@["--width"], default=800, help="Width of the image to render"),
        height: newIntArg(@["--height"], default=600, help="Height of the image to render"),
        output_file: newStringArg(@["--pfm_output"], default="output", help="Name of the output file"),
        output_png: newBoolArg(@["--png_output"], defaultVal = false, help = "Produce a PNG output.")
    )

    let demo = (
        cube: newCommandArg(@["cube"], cube, help="Launches cube demo"),
    )

    let spec = (
        demo: newCommandArg(@["demo"], demo, help="Ship commands"),
        #render: newCommandArg(@["render"], render, help="Mine commands"),
        help: newHelpArg()
    )

    var argv: string = ""
    for i in countup(0, paramCount()):
        argv = argv & paramStr(i) & " "

    let (success, message) = parseOrMessage(spec, args=argv, command="hello")


