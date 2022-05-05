import "../src/RaytracingAlgorithm/imagetracer.nim"
import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/raytypes.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/geometry.nim"

proc test_base_tracer*()=
    var
        img: HdrImage = newHdrImage(200,100)
        tracer: ImageTracer = newImageTracer(img)
        newray: Ray = newRay()

    tracer.fireAllRays(customColor, newray, newColor(0.0, 0.0, 1.0))
    for i in countup(0, tracer.image.height-1):
        for j in countup(0, tracer.image.width-1):
            assert tracer.image.get_pixel(j, i) == newColor(0.0, 0.0, 1.0)

test_base_tracer()

