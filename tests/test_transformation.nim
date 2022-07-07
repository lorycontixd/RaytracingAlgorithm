import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import "../src/RaytracingAlgorithm/matrix.nim"
import std/[math]

proc test_mul=
    var m = newTransformation(

        m = [
            float32(1.0), float32(2.0), float32(3.0), float32(4.0),
            float32(5.0), float32(6.0), float32(7.0), float32(8.0),
            float32(9.0), float32(9.0), float32(8.0), float32(7.0),
            float32(0.0), float32(0.0), float32(0.0), float32(1.0)
        ],

        inv = [
            float32(-3.75), float32(2.75), float32(-1.0), float32(0.0),
            float32(5.75), float32(-4.75), float32(2.0), float32(1.0),
            float32(-2.25), float32(2.25), float32(-1.0), float32(-2.0),
            float32(0.0), float32(0.0), float32(0.0), float32(1.0)
        ]
    )

    assert m.is_consistent()

    var exp_v = newVector3(14.0, 38.0, 51.0)
    assert exp_v.isClose(m*newVector3(1.0, 2.0, 3.0))

    var exp_p = newPoint(18.0, 46.0, 58.0)
    assert exp_p.isClose(m*newPoint(1.0, 2.0, 3.0))

    var exp_n = newNormal(-8.75, 7.75, -3.0)
    assert exp_n.isClose(m*newNormal(3.0, 2.0, 4.0))
    

test_mul()