import "../src/RaytracingAlgorithm/mathutils.nim"
import "../src/RaytracingAlgorithm/pcg.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import std/[math]

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

proc test_lerp=
    # Lerp clamped
    var t: float32 = 0.5

    assert Lerp(0.0, 1.0, t).IsEqual(0.5)
    assert Lerp(10, -10, t).IsEqual(0.0)

    var t2: float32 = 20.0
    assert Lerp(0.0, 2.0, t2).IsEqual(2.0)

    # Lerp unclamped
    var t3: float32 = -0.25
    assert LerpUnclamped(0.33, 1.5, t3).IsEqual(0.0375)

proc test_reflect=
    assert Reflect(Vector3.up(), Vector3.down().convert(Normal)).isClose(Vector3.down())
    assert Reflect((Vector3.right()+Vector3.up()).normalize(), Vector3.down().convert(Normal) ).isClose((Vector3.right()+Vector3.down()).normalize())

proc test_refract=
    let refract1 = Refract((Vector3.right()+Vector3.up()).normalize(),
        Vector3.down().convert(Normal),
        1.5.float32,
        cos(PI/2.0).float32,
        cos(PI/2.0).float32
    ).normalize()
    let res1 = (Vector3.right() + Vector3.up()).normalize()
    assert(refract1.isClose(res1))


test_onbCreation()
test_lerp()
test_reflect()
test_refract()