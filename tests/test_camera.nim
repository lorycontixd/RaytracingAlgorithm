
import std/[strformat, os]
import "../src/RaytracingAlgorithm/camera.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/imagetracer.nim"
import "../src/RaytracingAlgorithm/hdrimage.nim"
#import "../src/RaytracingAlgorithm/raytypes.nim"

proc test_transform*()=
    var ray : Ray = newRay(newPoint(1.0, 2.0, 3.0), newVector3(6.0, 5.0, 4.0))
    var transformation: Transformation = Transformation.translation(newVector3(10.0, 11.0, 12.0)) * Transformation.rotationX(90.0)
    let transformed = ray.Transform(transformation)

    assert transformed.origin == newPoint(11.0, 8.0, 14.0)
    assert transformed.dir == newVector3(6.0, -4.0, 5.0)

proc test_orthogonal_camera*()=
    var cam : OrthogonalCamera = newOrthogonalCamera(2.0)
    var
        ray1 = cam.fireRay(0.0, 0.0)
        ray2 = cam.fireRay(1.0, 0.0)
        ray3 = cam.fireRay(0.0, 1.0)
        ray4 = cam.fireRay(1.0, 1.0)

    # Verify parallel rays
    assert IsEqual(0.0, ray1.dir.Cross(ray2.dir).squareNorm())
    assert IsEqual(0.0, ray1.dir.Cross(ray3.dir).squareNorm())
    assert IsEqual(0.0, ray1.dir.Cross(ray4.dir).squareNorm())

    echo "ray1"
    echo ray1
    echo "ray2" 
    echo ray2
    echo "ray3" 
    echo ray3
    echo "ray4" 
    echo ray4

    # Verify that the ray hitting the corners have the right coordinates
    assert ray1.at(1.0).isClose(newPoint(0.0, 2.0, -1.0))
    assert ray2.at(1.0).isClose(newPoint(0.0, -2.0, -1.0))
    assert ray3.at(1.0).isClose(newPoint(0.0, 2.0, 1.0))
    assert ray4.at(1.0).isClose(newPoint(0.0, -2.0, 1.0))


proc test_orthogonal_camera_transform*()=
    
    var transformation: Transformation = Transformation.translation(newVector3(0.0, -1.0, 0.0)*2.0) * Transformation.rotationX(90.0)
    var cam : OrthogonalCamera = newOrthogonalCamera(2.0, transformation)
    var ray = cam.fireRay(0.5, 0.5)

    echo ray

    assert ray.at(1.0).is_close(newPoint(0.0, -2.0, 0.0))



proc test_perspective_camera*()=
    var cam : PerspectiveCamera = newPerspectiveCamera(2.0)
    var
        ray1 = cam.fireRay(0.0, 0.0)
        ray2 = cam.fireRay(1.0, 0.0)
        ray3 = cam.fireRay(0.0, 1.0)
        ray4 = cam.fireRay(1.0, 1.0)
    
    # All rays starting from the same point
    assert ray1.origin.isClose(ray2.origin)
    assert ray1.origin.isClose(ray3.origin)
    assert ray1.origin.isClose(ray4.origin)

    # Verify that the ray hitting the corners have the right coordinates
    assert ray1.at(1.0).isClose(newPoint(0.0, 2.0, -1.0))
    assert ray2.at(1.0).isClose(newPoint(0.0, -2.0, -1.0))
    assert ray3.at(1.0).isClose(newPoint(0.0, 2.0, 1.0))
    assert ray4.at(1.0).isClose(newPoint(0.0, -2.0, 1.0))
    
    echo "ray1"
    echo ray1
    echo "ray2" 
    echo ray2
    echo "ray3" 
    echo ray3
    echo "ray4" 
    echo ray4


#[proc test_ray*()=
    var img: HdrImage = newHdrImage(200,100)
    var tracer: ImageTracer = newImageTracer(img)
    #tracer.fireAllRays(baseColor)]#


test_transform()
test_orthogonal_camera()
test_orthogonal_camera_transform()
echo "-----------"
test_perspective_camera()
#test_ray()

