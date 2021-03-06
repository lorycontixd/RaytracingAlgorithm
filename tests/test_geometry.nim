import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import "../src/RaytracingAlgorithm/matrix.nim"
import std/[math]

discard """
  action: "run"
  exitcode: 0
  output: "Testing geometry & transformations"
  batchable: true
  joinable: true
  valgrind: false
  cmd: "nim cpp -r -d:release $file"
"""

echo "Testing geometry & transformations"

proc test_geometry=
    let 
        a = newVector3(3.0, 6.0, 2.0)
        b = newVector3(-1.0, -10.0, 2.0) 

    assert a+b == newVector3(2.0, -4.0, 4.0)
    assert a-b == newVector3(4.0, 16.0, 0.0)
    assert a*b == -59.0
    assert b*a == a*b
    assert a.Cross(b) == newVector3(32.0, -8.0, -24.0)
    assert a.norm() == 7.0
    assert pow(a.norm(), 2)  == 49

    var c = newPoint(1.0, 1.0, 2.0)

    assert a+c == newPoint(4.0, 7.0, 4.0)
    assert c-a == newPoint(-2.0, -5.0, 0.0)

    assert a[0] == 3.0
    assert b[2] == 2.0
    assert c[1] == 1.0

    assert a == a
    assert a != b
    assert a.isClose(a)
    assert a.isNotClose(b)

    assert neg(a) == newVector3(-3.0, -6.0, -2.0)


    assert $a == "Vector3(3.0,6.0,2.0)"
    assert $c == "Point(1.0,1.0,2.0)"

    var 
        d = newPoint(1.0, 2.0, 3.0)
        e = newPoint(4.0, 6.0, 8.0)

    assert d == d
    assert d != e
    assert d.isClose(d)
    assert d.isNotClose(e)


proc test_rotation(): void=
    var
        v: Vector3 = Vector3.right()
    assert (Transformation.rotationY(180) * v).isClose(Vector3.left())
    assert (Transformation.rotationZ(90) * v).isClose(Vector3.up())

proc test_translation(): void=
    var
        trans: Vector3 = newVector3(2.0, 2.0, 2.0)
        p: Point = newPoint(2.0, 0.0, 0.0)
        v: Vector3 = newVector3(2.0, 0.0, 0.0)

    assert (Transformation.translation(trans) * p).isClose( newPoint(4.0, 2.0, 2.0) )
    assert (Transformation.translation(trans) * v).isClose( newVector3(2.0, 0.0, 0.0) )
    assert (Transformation.translation(trans) * (v * 2.0)).isClose( newVector3(4.0, 0.0, 0.0) )

proc test_scale(): void =
    var
        trans: Vector3 = newVector3(2.0, 2.0, 2.0)
        v: Vector3 = newVector3(1.0, 1.0, 1.0)

    assert (Transformation.scale(trans) * v).isClose(newVector3(2.0, 2.0, 2.0))

proc test_transformation_composition(): void=
    var
        translation: Vector3 = newVector3(1.0, 1.0, 1.0)
        scale: Vector3 = newVector3(2.0, 2.0, 2.0)
        res: Matrix = [
            float32(scale.x),float32(0.0), float32(0.0), float32(translation.x),
            float32(0.0),float32(scale.y), float32(0.0), float32(translation.y),
            float32(0.0),float32(0.0), float32(scale.z), float32(translation.z),
            float32(0.0),float32(0.0), float32(0.0), float32(1.0)
        ]
    assert (TranslationMatrix(translation) * ScaleMatrix(scale)).are_matrix_close(res)

proc test_transformation_matrix_inverse(): void=
    var
        quar: float32 = 1/4
        m1: Matrix = IdentityMatrix()
        m2: Matrix = [
            float32(1.0), float32(1.0), float32(1.0), float32(-1.0),
            float32(1.0), float32(1.0), float32(-1.0), float32(1.0),
            float32(1.0), float32(-1.0), float32(1.0), float32(1.0),
            float32(-1.0), float32(1.0), float32(1.0), float32(1.0)
        ]
        invm2: Matrix = [
            quar, quar, quar, -quar,
            quar, quar, -quar, quar,
            quar, -quar, quar, quar,
            -quar, quar, quar, quar
        ]

    assert m1.Inverse().are_matrix_close(m1)



test_transformation_matrix_inverse()
test_rotation()
test_translation()
test_scale()
test_transformation_composition()