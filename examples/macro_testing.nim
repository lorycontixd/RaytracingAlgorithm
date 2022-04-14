import std/[macros]
import "../src/RaytracingAlgorithm/utils.nim"

proc add(x,y: int): int=
    return x+y

type Vec2 = tuple[x,y:int]

let p: Vec2 = (1,1)

let x = add.apply(p)
echo x