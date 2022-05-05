import "../src/RaytracingAlgorithm/imagetracer.nim"
import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/camera.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/renderer.nim"
import "../src/RaytracingAlgorithm/world.nim"

var
    img: HdrImage = newHdrImage(4,2)
    cam: Camera = newPerspectiveCamera(2.0)
    tracer: ImageTracer = newImageTracer(img, cam)

proc test_orientation(self: var ImageTracer): void=
    var top_left_ray: Ray = self.fireRay(0, 0, u_pixel=0.0, v_pixel=0.0)
    assert newPoint(0.0, 2.0, 1.0).is_close(top_left_ray.at(1.0))

    var bottom_right_ray: Ray = self.fireRay(3, 1, u_pixel=1.0, v_pixel=1.0)
    assert newPoint(0.0, -2.0, -1.0).isClose(bottom_right_ray.at(1.0))

proc test_uv_sub_mapping(self: var ImageTracer): void =
    var
        ray1: Ray = self.fireRay(0, 0, u_pixel=2.5, v_pixel=1.5)
        ray2: Ray = self.fireRay(2, 1, u_pixel=0.5, v_pixel=0.5)
    assert ray1.is_close(ray2)

proc test_image_coverage(self: var ImageTracer): void =
    self.fireAllRays(newDebugRenderer(newWorld(), Color.black()).Get())
    for row in countup(0, self.image.height-1):
        for col in countup(0, self.image.width-1):
            assert self.image.get_pixel(col, row) == newColor(0.0, 0.0, 0.0)

test_orientation(tracer)
test_uv_sub_mapping(tracer)
test_image_coverage(tracer)