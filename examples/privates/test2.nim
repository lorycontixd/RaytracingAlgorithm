import "../../src/RaytracingAlgorithm/renderer.nim"
import "../../src/RaytracingAlgorithm/geometry.nim"
import "../../src/RaytracingAlgorithm/transformation.nim"
import "../../src/RaytracingAlgorithm/color.nim"
import "../../src/RaytracingAlgorithm/world.nim"
import "../../src/RaytracingAlgorithm/shape.nim"
import "../../src/RaytracingAlgorithm/ray.nim"
import std/[options, marshal]


var
    w: World = newWorld()
    O: Point = newPoint(-2.0, 0.0, 0.0)

    dir2: Vector3 = newVector3(0.61158, 0.20386, 0.76447) # Normalized direction vector between O and S2

    #s1: Sphere = newSphere("SPHERE_0", Transformation.translation(newVector3(10.0, 10.0, 10.9)))
    #r1: Ray = newRay(newPoint(1.0, 1.0, 1.0), newVector3(1.0, 1.0, 1.0), 0.1, 1000)
    s2: Sphere = newSphere("SPHERE_1", Transformation.scale(newVector3(0.5, 0.5, 0.5)) * Transformation.translation(newVector3(10.0, 4.0, 15.0)) * Transformation.translation(dir2 * 5.0))
    r2: Ray = newRay(O, dir2, 0.1, 10000.0)


let res = s2.rayIntersect(r2, true)
echo res
