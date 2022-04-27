import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"


var ray1: Ray = newRay( newPoint(1.0, 2.0, 3.0), newVector(5.0, 4.0, -1.0))
var ray2: Ray = newRay( newPoint(1.0, 2.0, 3.0), newVector(5.0, 4.0, -1.0))
var ray3: Ray = newRay( newPoint(5.0, 1.0, 4.0), newVector(3.0, 9.0, 4.0))

assert ray1.isClose(ray2)
assert not ray1.isClose(ray3)


var myray: Ray = newRay( newPoint(1.0, 2.0, 4.0), newVector(4.0, 2.0, 1.0))
assert myray.at(0.0).isClose( myray.origin)
assert myray.at(1.0).isClose( newPoint(5.0, 4.0, 5.0))
assert myray.at(2.0).isClose( newPoint(9.0, 6.0, 6.0))


var ray4: Ray = newRay( newPoint(1.0, 2.0, 3.0), newVector(6.0, 5.0, 4.0))
var transform: Transformation = Transformation.translation(newVector(10.0, 11.0, 12.0)) * Transformation.rotationX(90.0)
var transformed: Ray = myray.Transform(transform)

assert transformed.origin.isClose(newPoint(11.0, 7.0, 14.0))
assert transformed.dir.isClose(newVector(4.0, -1.0, 2.0))
#assert transformed.dir.isClose(newVector(6.0, -4.0, 5.0))