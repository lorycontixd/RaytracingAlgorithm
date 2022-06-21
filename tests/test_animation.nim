#[
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/animation.nim"
import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/camera.nim"
import "../src/RaytracingAlgorithm/renderer.nim"
import "../src/RaytracingAlgorithm/matrix.nim"
import std/[math]

proc test_animation1(): void=
    var world: World = newWorld()
    world.Add( newSphere("SPHERE_0", Transformation.translation(newVector3(1.0, 1.0, 1.0)) * Transformation.scale(newVector3(0.5, 0.5, 0.5))) )

    var animation: Animation = newAnimation(
        world,
        500,
        200,
        newOnOffRenderer(world, Color.black(), Color.white()),
        newTransformation(),
        CameraType.Perspective,
        2,
        2
    )

    assert animation.Interpolate(0.5, false) == newTransformation(newMatrix(
        @[
            @[1.0'f32, 0.0, 0.0, 2.0],
            @[0.0'f32, 1.0, 0.0, 2.0],
            @[0.0'f32, 0.0, 1.0, 2.0],
            @[0.0'f32, 0.0, 0.0, 1.0],
        ]
    ))

    assert animation.Interpolate(1.0) == newTransformation(newMatrix(
        @[
            @[1.0'f32, 0.0, 0.0, 2.0],
            @[0.0'f32, 1.0, 0.0, 2.0],
            @[0.0'f32, 0.0, 1.0, 2.0],
            @[0.0'f32, 0.0, 0.0, 1.0],
        ]
    ))

proc test_animation2(): void=
    var world: World = newWorld()
    world.Add( newSphere("SPHERE_0", Transformation.translation(newVector3(1.0, 1.0, 1.0)) * Transformation.scale(newVector3(0.5, 0.5, 0.5))) )

    var animation: Animation = newAnimation( 
        Transformation.translation(newVector3(10.0, 0.0, -10.0)),
        Transformation.translation(newVector3(-10.0, 0.0, 10.0)),
        CameraType.Perspective,
        newOnOffRenderer(world, Color.black(), Color.white()),
        500,
        200,
        world,
        2,
        2
    )
    assert animation.Interpolate(0.0) == newTransformation(newMatrix(
        @[
            @[1.0'f32, 0.0, 0.0, 10.0],
            @[0.0'f32, 1.0, 0.0, 0.0],
            @[0.0'f32, 0.0, 1.0, -10.0],
            @[0.0'f32, 0.0, 0.0, 1.0],
        ]
    ))

    assert animation.Interpolate(1.0) == newTransformation(newMatrix(
        @[
            @[1.0'f32, 0.0, 0.0, 0.0],
            @[0.0'f32, 1.0, 0.0, 0.0],
            @[0.0'f32, 0.0, 1.0, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0],
        ]
    ))

    assert animation.Interpolate(2.0) == newTransformation(newMatrix(
        @[
            @[1.0'f32, 0.0, 0.0, -10.0],
            @[0.0'f32, 1.0, 0.0, 0.0],
            @[0.0'f32, 0.0, 1.0, 10.0],
            @[0.0'f32, 0.0, 0.0, 1.0],
        ]
    ))

proc test_animation3()=
    var world: World = newWorld()
    world.Add( newSphere("SPHERE_0", Transformation.translation(newVector3(1.0, 1.0, 1.0)) * Transformation.scale(newVector3(0.5, 0.5, 0.5))) )

    var animation: Animation = newAnimation( 
        Transformation.translation(0.0, 0.0, 0.0) * Transformation.rotationZ(0.0),
        Transformation.translation(0.0, 0.0, 0.0) * Transformation.rotationZ(60.0),
        CameraType.Perspective,
        newOnOffRenderer(world, Color.black(), Color.white()),
        500,
        200,
        world,
        2,
        2
    )

    assert animation.Interpolate(0.0) == newTransformation(newMatrix(
        @[
            @[1.0'f32, 0.0, 0.0, 0.0],
            @[0.0'f32, 1.0, 0.0, 0.0],
            @[0.0'f32, 0.0, 1.0, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0],
        ]
    ))

    animation.Interpolate(2.0).Show()
    let sin60 = sin(degToRad(60.0)).float32
    echo "-> ", sin60
    assert animation.Interpolate(2.0) == newTransformation(newMatrix(
        @[
            @[0.5'f32, -sin60, 0.0, 0.0],
            @[sin60, 0.5, 0.0, 0.0],
            @[0.0'f32, 0.0, 1.0, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0],
        ]
    ))

    #[animation.Interpolate(2.0).Show()
    assert animation.Interpolate(2.0) == newTransformation(newMatrix(
        @[
            @[-1.0'f32, 0.0, 0.0, 0.0],
            @[0.0'f32, -1.0, 0.0, 0.0],
            @[0.0'f32, 0.0, 1.0, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0],
        ]
    ))]#





# Translations
test_animation1()
test_animation2()
test_animation3()
]#