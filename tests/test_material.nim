import "../src/RaytracingAlgorithm/material.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/pcg.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/rayhit.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/utils.nim"

import std/[options]

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
    

proc testSpecBRDF =
    var
        specBRDF: SpecularBRDF = newSpecularBRDF(newUniformPigment(newColor(0.5, 0.5, 0.5)))
        s: Sphere = newSphere(
            "MYSPHERE",
            newTransformation(),
            newMaterial(
                specBRDF, newUniformPigment(Color.black())
            )
        )
        p: PCG = newPCG()

    var
        r1: Ray = newRay(
            newPoint(-2,0,0),
            Vector3.right(),
            1e-4,
            Inf,
            0
        )
        hitoption1: Option[RayHit] = s.rayIntersect(r1)
        hit1: RayHit = hitoption1.get()

        newray1: Ray = specBRDF.ScatterRay(
            p,
            r1.dir,
            hit1.world_point,
            hit1.normal,
            0
        )
    
    assert newray1.origin.isClose(newPoint(-1,0,0))
    assert newray1.dir.isClose(Vector3.left())

    var
        r2: Ray = newRay(
            newPoint(0,-2,0),
            Vector3.up(),
            1e-4,
            Inf,
            0
        )
        hitoption2: Option[RayHit] = s.rayIntersect(r2)
        hit2: RayHit = hitoption2.get()

        newray2: Ray = specBRDF.ScatterRay(
            p,
            r2.dir,
            hit2.world_point,
            hit2.normal,
            0
        )
    
    assert newray2.origin.isClose(newPoint(0,-1,0))
    assert newray2.dir.isClose(Vector3.down())

    var
        r3: Ray = newRay(
            newPoint(0,2,2),
            newVector3(0,-2,-1).normalize(),
            1e-4,
            Inf,
            0
        )
        hitoption3: Option[RayHit] = s.rayIntersect(r3)
        hit3: RayHit = hitoption3.get()

        newray3: Ray = specBRDF.ScatterRay(
            p,
            r3.dir,
            hit3.world_point,
            hit3.normal,
            0
        )
    
    assert newray3.origin.isClose(newPoint(0,0,1))
    assert newray3.dir.isClose(newVector3(0, -2, 1).normalize())



testUniformPigment()
testImagePigment()
testCheckeredPigment()

testSpecBRDF()