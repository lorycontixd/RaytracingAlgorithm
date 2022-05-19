import "../src/RaytracingAlgorithm/mathutils.nim"
import "../src/RaytracingAlgorithm/pcg.nim"
import "../src/RaytracingAlgorithm/geometry.nim"


proc test_onbCreation(): void= 
    var pcg : PCG = newPCG()

    for i in 0..100:

        var normal: Normal = newNormal(pcg.random_float(), pcg.random_float(), pcg.random_float() ).normalize()
        let
            e1 = CreateOnbFromZ(normal)
            e2 = CreateOnbFromZ(normal)
            e3 = CreateOnbFromZ(normal)
        

        assert (e1.squareNorm()).IsEqual(1.0)