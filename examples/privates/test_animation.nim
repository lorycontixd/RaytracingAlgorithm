include "../../src/RaytracingAlgorithm/animation.nim"
import std/[marshal]


var w: World = newWorld()
var scale_tranform: Transformation = Transformation.scale(newVector3(0.1, 0.1, 0.1))
w.Add(newSphere("SPHERE_0", Transformation.translation( newVector3(0.5, 0.5, 0.5)) * scale_tranform))
w.Add(newSphere("SPHERE_1", Transformation.translation( newVector3(0.5, 0.5, -0.5)) * scale_tranform))
w.Add(newSphere("SPHERE_2", Transformation.translation( newVector3(0.5, -0.5, 0.5)) * scale_tranform))
w.Add(newSphere("SPHERE_3", Transformation.translation( newVector3(0.5, -0.5, -0.5)) * scale_tranform))
w.Add(newSphere("SPHERE_4", Transformation.translation( newVector3(-0.5, 0.5, 0.5)) * scale_tranform))
w.Add(newSphere("SPHERE_5", Transformation.translation( newVector3(-0.5, 0.5, -0.5)) * scale_tranform))
w.Add(newSphere("SPHERE_6", Transformation.translation( newVector3(-0.5, -0.5, -0.5)) * scale_tranform))
w.Add(newSphere("SPHERE_7", Transformation.translation( newVector3(-0.5, -0.5, 0.5)) * scale_tranform))
w.Add(newSphere("SPHERE_7", Transformation.translation( newVector3(-0.5, 0.0, -0.5)) * scale_tranform))


var animation: Animation = newAnimation( 
    Transformation.rotationX(90.0),
    Transformation.rotationX(180.0) * Transformation.rotationY(40) * Transformation.rotationZ(45),
    CameraType.Perspective,
    300,
    200,
    w,
    1,
    30
)

animation.Play()
animation.Save(true)

#echo transform