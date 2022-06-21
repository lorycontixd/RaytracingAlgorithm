import "../src/RaytracingAlgorithm/mathutils.nim"
import "../src/RaytracingAlgorithm/pcg.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/utils.nim"


proc test_onbCreation(): void= 
    var pcg : PCG = newPCG()

    for i in 0..100:
        let
            f1 = pcg.random_float()
            f2 = pcg.random_float()
            f3 = pcg.random_float()
        var normal: Normal = newNormal(f1, f2, f3).normalize()
        let
            (e1, e2, e3) = CreateOnbFromZ(normal)      

        # normalization
        assert (e1.squareNorm()).IsEqual(1.0)
        assert (e2.squareNorm()).IsEqual(1.0)
        assert (e3.squareNorm()).IsEqual(1.0)

        # normal aligned with z-axis
        assert (e3.isClose(normal.convert(Vector3)))

        # orthogonality
        assert (e1.Dot(e2).IsEqual(0.0))
        assert (e2.Dot(e3).IsEqual(0.0))
        assert (e3.Dot(e1).IsEqual(0.0))


test_onbCreation()