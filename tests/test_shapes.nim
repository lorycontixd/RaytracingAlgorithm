import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/rayhit.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import std/[options]

proc testSphere*(): void=
    ## ------ test sphere 1 ---------
    var
        r1: Ray = newRay(newPoint(0.0, 0.0, 2.0), Vector3.backward())
        unitSphere1: Sphere = newSphere("SPHERE_0", Transformation.translation(newVector3(0.0, 0.0, 0.0)))
        
    let res1 = unitSphere1.rayIntersect(r1)    
    
    if res1.isSome:
        let intersection1 = res1.get()
        assert intersection1.world_point.isClose(newPoint(0.0, 0.0, 1.0))
        assert intersection1.normal.isClose(Vector3.forward().convert(Normal))

    ## ------ test sphere 2 --------
    var r2: Ray = newRay(newPoint(3.0, 0.0, 0.0), Vector3.left())

    let res2 = unitSphere1.rayIntersect(r2)
    if res2.isSome:
        let intersection2 = res2.get()
        assert intersection2.world_point.isClose(newPoint(1.0, 0.0, 0.0))
        assert intersection2.normal.isClose(Vector3.right().convert(Normal))
    

testSphere()
