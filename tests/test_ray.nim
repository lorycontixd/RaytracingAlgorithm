import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"


var ray1: Ray = newRay( newPoint(1.0, 2.0, 3.0), newVector3(5.0, 4.0, -1.0))
var ray2: Ray = newRay( newPoint(1.0, 2.0, 3.0), newVector3(5.0, 4.0, -1.0))
var ray3: Ray = newRay( newPoint(5.0, 1.0, 4.0), newVector3(3.0, 9.0, 4.0))

assert ray1.isClose(ray2)
assert not ray1.isClose(ray3)

var myray: Ray = newRay( newPoint(1.0, 2.0, 4.0), newVector3(4.0, 2.0, 1.0))
assert myray.at(0.0).isClose( myray.origin)
assert myray.at(1.0).isClose( newPoint(5.0, 4.0, 5.0))
assert myray.at(2.0).isClose( newPoint(9.0, 6.0, 6.0))

proc ray_transform1(): void=
    var ray4: Ray = newRay( newPoint(1.0, 2.0, 3.0), newVector3(6.0, 5.0, 4.0))
    var transform: Transformation = Transformation.translation(newVector3(10.0, 11.0, 12.0)) * Transformation.rotationX(90.0)
    var transformed: Ray = ray4.Transform(transform)

    #echo transformed
    assert transformed.origin.isClose(newPoint(11.0, 8.0, 14.0))
    assert transformed.dir.isClose(newVector3(6.0, -4.0, 5.0))


proc ray_transform2(): void=
    var ray: Ray = newRay(newPoint(-2.0, 0.0, 0.0), newVector3(2.0, 3.0, 4.0))
    assert ray.at(1.0).isClose(newPoint(0.0, 3.0, 4.0))

    var
        translation: Transformation = Transformation.translation( newVector3(5.0, 6.0, 7.0) )
        rotation90x: Transformation = Transformation.rotationX(90.0)
        comb = translation * rotation90x

    var transformed: Ray = ray.Transform(comb)
    assert transformed.origin.isClose(newPoint(3.0, 6.0, 7.0))
    assert transformed.dir.isClose(newVector3( 2.0, -4.0, 3.0 ))


ray_transform1()
ray_transform2()

