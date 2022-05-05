import "../src/RaytracingAlgorithm/imagetracer.nim"
import "../src/RaytracingAlgorithm/hdrimage.nim"
#import "../src/RaytracingAlgorithm/raytypes.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/camera.nim"

#[proc test_base_tracer*()=
    var
        img: HdrImage = newHdrImage(200,100)
        tracer: ImageTracer = newImageTracer(img)
        newray: Ray = newRay()

    tracer.fireAllRays(customColor, newray, newColor(0.0, 0.0, 1.0))
    for i in countup(0, tracer.image.height-1):
        for j in countup(0, tracer.image.width-1):
            assert tracer.image.get_pixel(j, i) == newColor(0.0, 0.0, 1.0)]#

proc test_image_tracer*()=
    var
        img: HdrImage = newHdrImage(4,2)
        cam: PerspectiveCamera = newPerspectiveCamera(2.0)
        tracer: ImageTracer = newImageTracer(img, cam)
        ray1 : Ray = tracer.fireRay(0, 0, 2.5, 1.5 )
        ray2 : Ray = tracer.fireRay(2, 1, 0.5, 0.5)

    echo ray1
    echo ray2

    #testing uv submapping
    assert ray1.isClose(ray2)

    #testing image coverage
    var f = proc (r: Ray): Color = newColor(1.0, 2.0, 3.0)
    fireAllRays(tracer, f)
    for row in 0..<(tracer.image.height):
      for col in 0..<(tracer.image.width):
          assert tracer.image.getPixel(col, row) == newColor(1.0, 2.0, 3.0)

    #testing orientation
    var
        top_left_ray : Ray = tracer.fireRay(0, 0, 0.0, 0.0)
        bottom_right_ray : Ray = tracer.fireRay(3, 1, 1.0, 1.0)

    # Fire a ray against top-left corner of the screen
    assert top_left_ray.at(1.0).is_close(newPoint(0.0, 2.0, 1.0))
    # Fire a ray against bottom-right corner of the screen
    assert bottom_right_ray.at(1.0).is_close(newPoint(0.0, -2.0, -1.0))







#test_base_tracer()
test_image_tracer()


