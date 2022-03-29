import RaytracingAlgorithm/[hdrimage]
import std/[parsecfg]

when isMainModule:
    var p: Config = loadConfig("./RaytracingAlgorithm.nimble")
    echo p.getSectionValue("", "version") 