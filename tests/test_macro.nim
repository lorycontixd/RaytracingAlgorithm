import std/[macros, strformat, strutils, typetraits, math]
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/exception.nim"


dumpAstGen:
    proc Distance*(a,b: Vector): float32 {.inline.}=
        let
            diff_x = a.x - b.x
            diff_y = a.y - b.y
            diff_z = a.z - b.z
        result = float(sqrt(diff_x * diff_x + diff_y * diff_y + diff_z * diff_z))
    
        