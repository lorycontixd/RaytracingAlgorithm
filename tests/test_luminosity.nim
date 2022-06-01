import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import std/[options]

let col1 = newColor(1.0,2.0,3.0)
let col2 = newColor(9.0,5.0,7.0)

assert IsEqual(col1.luminosity(), 2.0)
assert IsEqual(col2.luminosity(), 7.0)

# Average Luminosity
var img = newHdrImage(2,1)
img.set_pixel(0,0, newColor(5.0, 10.0, 15.0))
img.set_pixel(1,0, newColor(500.0, 1000.0, 1500.0))
assert IsEqual(100.0, img.average_luminosity(delta=0.0))

# Normalize
var l: float32 = 100.0
img.normalize_image(factor=1000.0, luminosity=some(l))
assert img.get_pixel(0,0) == newColor(0.5e2, 1.0e2, 1.5e2)
assert img.get_pixel(1,0) == newColor(0.5e4, 1.0e4, 1.5e4)

# Clamp
var img2 = newHdrImage(2,1)
img2.set_pixel(0, 0, newColor(0.5e1, 1.0e1, 1.5e1))
img2.set_pixel(1, 0, newColor(0.5e3, 1.0e3, 1.5e3))
img2.clamp_image()
for pixel in img2.pixels:
    assert (pixel.r >= 0) and (pixel.r <= 1)
    assert (pixel.g >= 0) and (pixel.g <= 1)
    assert (pixel.b >= 0) and (pixel.b <= 1)