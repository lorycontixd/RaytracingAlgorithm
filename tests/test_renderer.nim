import "../src/RaytracingAlgorithm/renderer.nim"
import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/material.nim"
import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/camera.nim"
import "../src/RaytracingAlgorithm/imagetracer.nim"
import streams



proc test_onoff_renderer(): void=
    var world: World = newWorld()
    world.Add( newSphere("SPHERE_0", Transformation.translation( newVector3(10.0, 0.0, 0.0)) ))
    var onoff: Renderer = newOnOffRenderer(world, Color.black(), Color.white())
    var r1: Ray = newRay( newPoint(0.0, 0.0, 0.0), Vector3.right())

    let x = onoff.Get()

proc test_onoff_renderer2(): void=
    
    let
        sphere = newSphere("SPHERE_=0", Transformation.translation(2.0,0.0,0.0)*Transformation.scale(0.2,0.2,0.2),
        newMaterial(newDiffuseBRDF(newUniformPigment(Color.white())))
        )

    var image: HdrImage = newHdrImage(3,3)
    var camera: Camera = newOrthogonalCamera(1.0, Transformation.translation(0.0,0.0,0.0))
    var tracer: ImageTracer = newImageTracer(image, camera)
    var world2 : World = newWorld()

    world2.Add(sphere)
    var renderer : Renderer = newOnOffRenderer(world2, Color.black, Color.white)
    tracer.fireAllRays(renderer.Get())

    assert tracer.image.get_pixel(0,0) == Color.black
    assert tracer.image.get_pixel(1,0) == Color.black
    assert tracer.image.get_pixel(2,0) == Color.black
    assert tracer.image.get_pixel(0,1) == Color.black
    assert tracer.image.get_pixel(1,1) == Color.white
    assert tracer.image.get_pixel(0,2) == Color.black
    assert tracer.image.get_pixel(1,2) == Color.black
    assert tracer.image.get_pixel(2,2) == Color.black


proc test_flat_renderer(): void=
    var sphere_color : Color = newColor(1.0, 2.0, 3.0)
    let
        sphere = newSphere("SPHERE_=0", Transformation.translation(2.0,0.0,0.0)*Transformation.scale(0.2,0.2,0.2),
        newMaterial(newDiffuseBRDF(newUniformPigment(sphere_color)))
        )

    var image: HdrImage = newHdrImage(3,3)
    var camera: Camera = newOrthogonalCamera(2.0, Transformation.translation(0.0,0.0,0.0))
    var tracer: ImageTracer = newImageTracer(image, camera)
    var world2 : World = newWorld()

    world2.Add(sphere)
    var renderer : Renderer = newFlatRenderer(world2, Color.black)
    tracer.fireAllRays(renderer.Get())

    assert tracer.image.get_pixel(0,0) == Color.black
    assert tracer.image.get_pixel(1,0) == Color.black
    assert tracer.image.get_pixel(2,0) == Color.black
    assert tracer.image.get_pixel(0,1) == Color.black
    assert tracer.image.get_pixel(1,1) == sphere_color
    assert tracer.image.get_pixel(2,1) == Color.black
    assert tracer.image.get_pixel(0,2) == Color.black
    assert tracer.image.get_pixel(1,2) == Color.black
    assert tracer.image.get_pixel(2,2) == Color.black

#proc test_pointlight_renderer(): void = discard




test_onoff_renderer()
test_onoff_renderer2()
test_flat_renderer()