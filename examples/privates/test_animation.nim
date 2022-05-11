include "../../src/RaytracingAlgorithm/animation.nim"
import std/[marshal]


var w: World = newWorld()
w.Add( newSphere("SPHERE_0", Transformation.translation(newVector3(1.0, 1.0, 1.0))* Transformation.scale(newVector3(0.5, 0.5, 0.5))) )


var animation: Animation = newAnimation( 
    Transformation.translation(newVector3(3.0, 3.0, 3.0)) * Transformation.rotationX(90.0) * Transformation.scale(newVector3(3.0, 3.0, 3.0)),
    Transformation.translation(newVector3(5.0, 5.0, 5.0)) * Transformation.rotationX(180.0) * Transformation.scale(newVector3(5.0, 5.0, 5.0)),
    CameraType.Perspective,
    500,
    200,
    w,
    2,
    2
)

animation.FindRotation()