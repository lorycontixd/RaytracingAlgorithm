
import RaytracingAlgorithm/[hdrimage, geometry, utils, logger]
import std/[parsecfg, os, streams]

when isMainModule:
    addLogger( open("main.log", fmWrite))
    info("Running RaytracingAlgorithm on version ",getPackageVersion())
    

