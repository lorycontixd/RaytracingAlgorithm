import std/[macros, strformat, strutils]
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/exception.nim"


dumpAstGen:
    proc Distance*(_:typedesc[Vector], a,b: Vector): float32 {.inline.}=
        let
            diff_x = a.x - b.x
            diff_y = a.y - b.y
            diff_z = a.z - b.z
        result = float(sqrt(diff_x * diff_x + diff_y * diff_y + diff_z * diff_z))

