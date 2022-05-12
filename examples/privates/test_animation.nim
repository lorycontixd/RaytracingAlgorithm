include "../../src/RaytracingAlgorithm/animation.nim"
import std/[marshal]


var w: World = newWorld()
w.Add( newSphere("SPHERE_0", Transformation.translation(newVector3(2.0, 0.0, 0.0))* Transformation.scale(newVector3(0.5, 0.5, 0.5))) )


var animation: Animation = newAnimation( 
    Transformation.translation(-0.3, 0.0, 0.0),
    Transformation.translation(0.0, 0.0, 0.0),
    CameraType.Perspective,
    500,
    200,
    w,
    3,
    20
)

animation.Play()
animation.Save(true)

#echo transform