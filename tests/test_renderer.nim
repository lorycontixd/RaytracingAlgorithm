import "../src/RaytracingAlgorithm/renderer.nim"
import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/transformation.nim"

proc test_onoff_renderer(): void=
    var world: World = newWorld()
    world.Add( newSphere("SPHERE_0", Transformation.translation( newVector3(10.0, 0.0, 0.0)) ))
    var onoff: Renderer = newOnOffRenderer(world, Color.black(), Color.white())
    var r1: Ray = newRay( newPoint(0.0, 0.0, 0.0), Vector3.right())

    let x = onoff.Get()

test_onoff_renderer()

