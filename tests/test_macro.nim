import std/[macros, strformat, strutils]
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/exception.nim"


#dumpAstGen:
#    proc `$`*(this: type1): string=
#        return $type1 & "($1,$2,$3)" % [$this.x, $this.y, $this.z]