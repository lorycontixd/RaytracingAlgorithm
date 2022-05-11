# Compute PI in an inefficient way
import std/[strutils, math, threadpool, options, marshal]
import "../../src/RaytracingAlgorithm/renderer.nim"
import "../../src/RaytracingAlgorithm/geometry.nim"
import "../../src/RaytracingAlgorithm/transformation.nim"
import "../../src/RaytracingAlgorithm/color.nim"
import "../../src/RaytracingAlgorithm/world.nim"
import "../../src/RaytracingAlgorithm/shape.nim"
import "../../src/RaytracingAlgorithm/ray.nim"
import "../../src/RaytracingAlgorithm/rayhit.nim"
{.experimental: "parallel".}


var
    w: World = newWorld()
    O: Point = newPoint(-2.0, 0.0, 0.0)
    dir1: Vector3 = newVector3(0.61158, 0.20386, 0.76447) # Normalized direction vector between O and S2
    dir2: Vector3 = Vector3.right()
    dir3: Vector3 = Vector3.forward()

    s1: Sphere = newSphere("SPHERE_1", Transformation.translation(newVector3(10.0, 0.0, 0.0)) * Transformation.scale(newVector3(0.5, 0.5, 0.5)))
    r1: Ray = newRay(O, dir1, 0.1, 10000.0)
    r2: Ray = newRay(O, dir2, 0.1, 10000.0)
    r3: Ray = newRay(O, dir3, 0.1, 10000.0)
w.Add(s1)

proc rayParallelFire(s: Sphere, r: Ray):Option[RayHit] {.gcsafe, thread, inline, noSideEffect.} =
    return s.rayIntersect(r, false)

proc main(n: int)=
    var results: seq[Option[rayhit.RayHit]] = newSeq[Option[rayhit.RayHit]](n+1)
    var s1: Sphere = newSphere("SPHERE_1", Transformation.translation(newVector3(10.0, 0.0, 0.0)) * Transformation.scale(newVector3(0.5, 0.5, 0.5)))
    var tempRay: Ray
    parallel:
        for i in 0..results.high:
            tempRay = newRay(newPoint(-2.0, 0.0, 0.0), Vector3.right() + newVector3(0.0, float32( pow( float32(i-3) , 1.2) ), 0.0), 0.01, 1000.0)
            results[i] = spawn(rayParallelFire(s1, tempRay))
        
    echo results.len()

main(30)