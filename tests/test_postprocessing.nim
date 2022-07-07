import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import "../src/RaytracingAlgorithm/postprocessing.nim"
import std/[options, math]

var l: float32 = 100.0
var tm: ToneMapping = newToneMapping(1000.0, luminosity=some(l))


# Average Luminosity
proc test_luminosity=
    let col1 = newColor(1.0,2.0,3.0)
    let col2 = newColor(9.0,5.0,7.0)
    assert IsEqual(col1.luminosity(), 2.0)
    assert IsEqual(col2.luminosity(), 7.0)

### Tone Mapping
# Normalize
proc test_normalize=
    var img = newHdrImage(2,1)
    img.set_pixel(0,0, newColor(5.0, 10.0, 15.0))
    img.set_pixel(1,0, newColor(500.0, 1000.0, 1500.0))
    assert IsEqual(100.0, img.average_luminosity(delta=0.0))

    tm.normalize_image(img)
    assert img.get_pixel(0,0) == newColor(0.5e2, 1.0e2, 1.5e2)
    assert img.get_pixel(1,0) == newColor(0.5e4, 1.0e4, 1.5e4)

# Clamp
proc test_clamp=
    var img2 = newHdrImage(2,1)
    img2.set_pixel(0, 0, newColor(0.5e1, 1.0e1, 1.5e1))
    img2.set_pixel(1, 0, newColor(0.5e3, 1.0e3, 1.5e3))
    tm.clamp_image(img2)
    for pixel in img2.pixels:
        assert (pixel.r >= 0) and (pixel.r <= 1)
        assert (pixel.g >= 0) and (pixel.g <= 1)
        assert (pixel.b >= 0) and (pixel.b <= 1)

### Gaussian Blur
proc test_gaussian_function=
    assert gaussian(2,2,1).IsEqual((1/(2*PI)) * exp(-4.float32))
    assert gaussian(4,4,3).IsEqual((1/(18*PI)) * exp(float32(-32.0)/18.0))

proc test_kernel()=
    let radius = 2
    let
        blur: GaussianBlur = newGaussianBlur(radius)
        kernel = blur.GetKernel()

    assert len(kernel) == (2 * radius + 1)
    assert len(kernel[0]) == (2 * radius + 1)
    assert kernel[0][0].IsEqual(0.002969)
    assert kernel[0][1].IsEqual(0.013306)
    assert kernel[2][0].IsEqual(0.021938)


test_luminosity()
test_normalize()
test_clamp()

test_gaussian_function()
test_kernel()
