
import std/[strformat, os]
import "../src/RayTracingAlgorithm/camera.nim"
import "../src/RayTracingAlgorithm/ray.nim"
import "../src/RayTracingAlgorithm/geometry.nim"
import "../src/RayTracingAlgorithm/transformation.nim"
import "../src/RayTracingAlgorithm/imagetracer.nim"
import "../src/RayTracingAlgorithm/hdrimage.nim"

proc test_transform*()=
    var ray : Ray = newRay(newPoint(1.0, 2.0, 3.0), newVector(6.0, 5.0, 4.0))
    var transformation: Transformation = Transformation.translation(newVector(10.0, 11.0, 12.0)) * Transformation.rotationX(90.0)
    let transformed = ray.transform(transformation)

    assert transformed.origin == newPoint(11.0, 8.0, 14.0)
    assert transformed.dir == newVector(6.0, -4.0, 5.0)

proc test_orthogonal_camera*()=
    let a = 1

proc test_ray*()=
    var img = newHdrImage(200,100)
    var tracer: ImageTracer = newImageTracer(img)
    echo tracer


test_transform()
test_ray()