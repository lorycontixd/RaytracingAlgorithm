
import RaytracingAlgorithm/[hdrimage, geometry, utils, logger, shape, ray, transformation, world, rayhit, imagetracer, exceptions]
import std/[parsecfg, os, streams, times, options, parseopt]

when isMainModule:
    addLogger( open( joinPath(getCurrentDir(), "main.log"), fmWrite))
    info("Running RaytracingAlgorithm on version ",getPackageVersion())
    debug("Creating variables")

    