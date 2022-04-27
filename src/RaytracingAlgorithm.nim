
import RaytracingAlgorithm/[hdrimage, geometry, utils, logger, shape, ray, transformation]
import std/[parsecfg, os, streams]

when isMainModule:
    #addLogger( open("main.log", fmWrite))
    #info("Running RaytracingAlgorithm on version ",getPackageVersion())
    var
        r: Ray = newRay()
        s: Sphere = newSphere()
    echo s.rayIntersect(r)
    

