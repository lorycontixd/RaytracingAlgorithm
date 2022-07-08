import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/rayhit.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import std/[options]

echo "Testing world"

proc test_rayIntersect =
   
    var 
        world : World= newWorld()
        sphere1 : Sphere = newSphere("SPHERE1", Transformation.translation(Vector3.right()*2))
        sphere2 : Sphere = newSphere("SPHERE2", Transformation.translation(Vector3.right()*8))

    world.Add(sphere1)
    world.Add(sphere2)

    let intersection1 = world.rayIntersect(newRay(newPoint(0.0,0.0,0.0), Vector3.right()))
    if intersection1.isSome:
        let int1 = intersection1.get()
        assert int1.world_point.isClose(newPoint(1.0, 0.0, 0.0))

    let intersection2 = world.rayIntersect(newRay(newPoint(10.0,0.0,0.0), Vector3.left()))
    if intersection2.isSome:
        let int2 = intersection2.get()
        assert int2.world_point.isClose(newPoint(9.0, 0.0, 0.0))

proc test_ray_intersection =
   
    var 
        world : World= newWorld()
        sphere1 : Sphere = newSphere("SPHERE1", Transformation.translation(Vector3.right()*2))
        sphere2 : Sphere = newSphere("SPHERE2", Transformation.translation(Vector3.right()*8))

    world.Add(sphere1)
    world.Add(sphere2)

    assert not world.IsPointVisible(newPoint(10.0,0.0,0.0),newPoint(0.0,0.0,0.0) )
    assert not world.IsPointVisible(newPoint(5.0,0.0,0.0),newPoint(0.0,0.0,0.0) )
    assert world.IsPointVisible(newPoint(5.0,0.0,0.0),newPoint(4.0,0.0,0.0) )
    assert world.IsPointVisible(newPoint(0.5,0.0,0.0),newPoint(0.0,0.0,0.0) )
    assert world.IsPointVisible(newPoint(0.0,10.0,0.0),newPoint(0.0,0.0,0.0) )
    assert world.IsPointVisible(newPoint(0.0,0.0,10.0),newPoint(0.0,0.0,0.0) )




test_rayIntersect()
test_ray_intersection()

