import "../src/RaytracingAlgorithm/pcg.nim"
import "../src/RaytracingAlgorithm/material.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/renderer.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/utils.nim"

proc test_random =
    var pcg: PCG = newPCG()

    assert pcg.state == cast[uint64](1753877967969059832)
    assert pcg.inc == 109

    for expected in @[2707161783'u32, 2068313097'u32, 3122475824'u32, 2211639955'u32, 3215226955'u32, 3421331566'u32]:
        assert expected == pcg.random()

    for i in 0..100:
        let f1 = pcg.random_float()
        assert (0 < f1 and f1 < 1)

proc test_furnace =
    var pcg: PCG = newPCG()

    for i in 0..5:
        var world : World =newWorld()
        let 
            emitted_radiance = pcg.random_float()
            reflectance = pcg.random_float()
        var enclosure_material : Material = newMaterial(newDiffuseBRDF(newUniformPigment(newColor(1.0, 1.0, 1.0)*reflectance)),
         newUniformPigment(newColor(1.0, 1.0, 1.0)*emitted_radiance))

        world.Add(newSphere("SPHERE1",Transformation.translation(0.0,0.0,0.0), enclosure_material))

        var path_tracer : PathTracer = newPathTracer(world,Color.black(), pcg,1, 100, 101 )
        var ray : Ray = newRay(newPoint(0.0,0.0,0.0), newVector3(1.0,0.0,0.0))
        var color : Color = path_tracer.Get()(ray)

        var expected: float32 = emitted_radiance/(1.0-reflectance)

        assert expected.IsEqual(color.r)
        assert expected.IsEqual(color.g)
        assert expected.IsEqual(color.b)

    



test_random()
#test_furnace()