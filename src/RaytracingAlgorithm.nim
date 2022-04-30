
import RaytracingAlgorithm/[hdrimage, geometry, utils, logger, shape, ray, transformation, world, rayhit, imagetracer]
import std/[parsecfg, os, streams, times]
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
    width: newIntArg(@["--width"], defaultVal=800, help="Width of the image to render"),
    height: newIntArg(@["--height"], defaultVal=600, help="Height of the image to render"),
    pfm_output: newBoolArg(@["--pfm_output"], defaultVal=false, help="Produce a ")

)

let demo = (
    cube: newCommandArg(@["cube"], create, help="Create a new ship"),
)

let spec = (
      ship: newCommandArg(@["demo"], demo, help="Ship commands"),
      mine: newCommandArg(@["render"], mine, help="Mine commands"),
      help: newHelpArg()
)


