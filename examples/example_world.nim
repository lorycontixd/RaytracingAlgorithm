import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import std/[typetraits]

var scene: World = newWorld()

var 
    sphere0: Sphere = newSphere()
    sphere1: Sphere = newSphere("SPHERE_1", newVector3(1.0, 0.0, 0.0))
    sphere2: Sphere = newSphere("SPHERE_2", newVector3(2.0, 0.0, 1.0), 2.0)
    plane0: Plane = newPlane()

scene.Add(sphere0, sphere1, sphere2, plane0)
scene.Show()
echo ""
let x = scene.Filter(Sphere)
for i in x:
    echo i.id