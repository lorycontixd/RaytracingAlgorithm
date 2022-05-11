import "../src/RaytracingAlgorithm/material.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/hdrimage.nim"


proc testUniformPigment =
    var color: Color = newColor(1.0, 2.0, 3.0)
    var pigment : UniformPigment = newUniformPigment(color)
   
    assert pigment.getColor(newVector2(0.0, 0.0)) == color 
    assert pigment.getColor(newVector2(1.0, 0.0)) == color
    assert pigment.getColor(newVector2(0.0, 1.0)) == color 
    assert pigment.getColor(newVector2(1.0, 1.0)) == color


proc testImagePigment =
    var image : HdrImage = newHdrImage(2,2)

    image.set_pixel(0, 0, newColor(1.0, 2.0, 3.0))
    image.set_pixel(1, 0, newColor(2.0, 3.0, 1.0))
    image.set_pixel(0, 1, newColor(2.0, 1.0, 3.0))
    image.set_pixel(1, 1, newColor(3.0, 2.0, 1.0))

    var pigment : ImagePigment = newImagePigment(image)

    assert pigment.getColor(newVector2(0.0, 0.0)) == newColor(1.0, 2.0, 3.0)
    assert pigment.getColor(newVector2(1.0, 0.0)) == newColor(2.0, 3.0, 1.0)
    assert pigment.getColor(newVector2(0.0, 1.0)) == newColor(2.0, 1.0, 3.0)
    assert pigment.getColor(newVector2(1.0, 1.0)) == newColor(3.0, 2.0, 1.0)

proc testCheckeredPigment =
    var color1: Color = newColor(1.0, 2.0, 3.0)
    var color2: Color = newColor(10.0, 20.0, 30.0)

    var pigment : CheckeredPigment = newCheckeredPigment(color1, color2, 2)

    assert pigment.getColor(newVector2(0.25, 0.25)) == color1
    assert pigment.getColor(newVector2(0.75, 0.25)) == color2
    assert pigment.getColor(newVector2(0.25, 0.75)) == color2
    assert pigment.getColor(newVector2(0.75, 0.75)) == color1
    



testUniformPigment()
testImagePigment()
testCheckeredPigment()
