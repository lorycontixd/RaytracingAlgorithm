
discard """
  action: "run"
  exitcode: 0
  output: "Testing cameras"
  batchable: true
  joinable: true
  valgrind: false
  cmd: "nim cpp -r -d:release $file"
"""

import "../src/RaytracingAlgorithm/camera.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/utils.nim"

echo "Testing cameras"

proc test_transform*()=
    var ray : Ray = newRay(newPoint(1.0, 2.0, 3.0), newVector3(6.0, 5.0, 4.0))
    # define single transformations
    var translation: Transformation = Transformation.translation(newVector3(10.0, 11.0, 12.0))
    var rotation: Transformation = Transformation.rotationX(90.0)
    # combine transformations
    var transform: Transformation = rotation * translation
    # apply transformation
    var transformed = ray.Transform(transform)
    
    assert transformed.origin.isClose(newPoint(11.0, -15.0, 13.0))
    assert transformed.dir.isClose(newVector3(6, -4, 5))


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


    # Verify that the ray hitting the corners have the right coordinates
    assert ray1.at(1.0).isClose(newPoint(0.0, 2.0, -1.0))
    assert ray2.at(1.0).isClose(newPoint(0.0, -2.0, -1.0))
    assert ray3.at(1.0).isClose(newPoint(0.0, 2.0, 1.0))
    assert ray4.at(1.0).isClose(newPoint(0.0, -2.0, 1.0))


proc test_orthogonal_camera_transform*()=
    
    var transformation: Transformation = Transformation.translation(Vector3.down() * 2.0) * Transformation.rotationX(90.0)
    var cam : OrthogonalCamera = newOrthogonalCamera(2.0, transformation)
    var ray = cam.fireRay(0.5, 0.5)

    assert ray.at(1.0).is_close(newPoint(0.0, -2.0, 0.0))


proc test_perspective_camera*()=
    var cam : PerspectiveCamera = newPerspectiveCamera(2.0, 1.0)
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
    
    
test_transform()
test_orthogonal_camera()
test_orthogonal_camera_transform()
test_perspective_camera()

