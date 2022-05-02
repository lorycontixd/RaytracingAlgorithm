
import RaytracingAlgorithm/[hdrimage, geometry, utils, logger, shape, ray, transformation, world, rayhit, imagetracer]
import std/[parsecfg, os, streams, times, options]
import therapist

when isMainModule:
    addLogger( open( joinPath(getCurrentDir(), "main.log"), fmWrite))
    info("Running RaytracingAlgorithm on version ",getPackageVersion())
    debug("Creating variables")
    var
        scene: World = newWorld()

        vertex_spheres: seq[Sphere] = newSeq[Sphere](8)
        #imagetracer: ImageTracer = newImageTracer()


    let cube = (
        width: newIntArg(@["--width"], default=800, help="Width of the image to render"),
        height: newIntArg(@["--height"], default=600, help="Height of the image to render"),
        output_file: newStringArg(@["--pfm_output"], default="output", help="Name of the output file"),
        output_png: newBoolArg(@["--png_output"], defaultVal = false, help = "Produce a PNG output."),
        help: newHelpArg()
    )

    let demo = (
        cube: newCommandArg(@["cube"], cube, help="Launches cube demo"),
        help: newHelpArg()
    )

    let spec = (
        demo: newCommandArg(@["demo"], demo, help="Run a demo script"),
        #render: newCommandArg(@["render"], render, help="Mine commands"),
        version: newMessageArg(@["--version"], getPackageVersion() , help="Prints version"),
        help: newHelpArg(@["-h", "--help"], help="Show help message")
    )

    var args_string: string = cmdArgsToString()
    echo "1: ",args_string
    #args_string = deleteWord(args_string, 0)
    #echo "2: ",args_string

    let (success, message) = spec.parseOrMessage(prolog="main", args=args_string, command="main")

    echo message.isSome
    if success and message.isSome:
        echo message.get