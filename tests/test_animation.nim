import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/animation.nim"
import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/camera.nim"
import std/[marshal]

proc test_animation1(): void=
    var world: World = newWorld()
    world.Add( newSphere("SPHERE_0", Transformation.translation(newVector3(1.0, 1.0, 1.0))* Transformation.scale(newVector3(0.5, 0.5, 0.5))) )

    var animation: Animation = newAnimation( 
        newVector3(1.0, 1.0, 2.0),
        newVector3(3.0, 0.0, 0.0),
        CameraType.Perspective,
        500,
        200,
        world,
        2,
        2
    )
    animation.Play()
    echo animation.frames

test_animation1()