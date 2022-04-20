#[import "../src/RayTracingAlgorithm/ray.nim"
import "../src/RayTracingAlgorithm/geometry.nim"
import "../src/RayTracingAlgorithm/transformation.nim"


var ray1 = newRay(origin: Point(1.0, 2.0, 3.0), dir: Vector(5.0, 4.0, -1.0))
var ray2 = newRay(origin: Point(1.0, 2.0, 3.0), dir: Vector(5.0, 4.0, -1.0))
var ray3 = newRay(origin: Point(5.0, 1.0, 4.0), dir: Vector(3.0, 9.0, 4.0))

assert ray1.isClose(ray2)
assert not ray1.isClose(ray3)


var ray = newRay(origin=Point(1.0, 2.0, 4.0), dir=Vector(4.0, 2.0, 1.0))
assert ray.at(0.0).isClose(ray.origin)
assert ray.at(1.0).isClose(Point(5.0, 4.0, 5.0))
assert ray.at(2.0).isClose(Point(9.0, 6.0, 6.0))


var ray4 = newRay(origin=Point(1.0, 2.0, 3.0), dir=Vector(6.0, 5.0, 4.0))
var transformation = TranslationMatrix(Vec(10.0, 11.0, 12.0)) * rotationX(90.0)
var transformed = ray.Transform(transformation)
    
assert transformed.origin.isClose(Point(11.0, 8.0, 14.0))
assert transformed.dir.isClose(Vector(6.0, -4.0, 5.0))]#