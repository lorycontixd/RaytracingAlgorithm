
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

let args = (
    name: newStringArg(@["<command>"], help="Command to execute")

)
