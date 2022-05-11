import "../src/RaytracingAlgorithm/quaternion.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import std/[math]

proc test_quat1(): void=
    var 
        v1: Vector3 = newVector3(1.0, 1.0, 1.0)
        q1: Quaternion = Quaternion.xBy90()
    
    assert (q1*v1).isClose(newVector3(1.0, -1.0, 1.0))

proc test_quat2(): void=
    let
        phi = PI/2.0
        theta = PI/4.0
        psi = PI/2.0
        q = fromEuler(phi, theta, psi)

        v1 = newVector3(1.0, 0.0, 0.0)
        q2 = newQuaternion(0.0, 1.0, 0.0, 0) # 180 degrees around y-axis (same as rotationquaternion(0.0, 1.0, 0.0, PI))


    assert (q*v1).isClose( newVector3(0.0, 0.7071, -0.7071), 1e-3 )
    assert RotationQuaternion(newQuaternion(0.0, 1.0, 0.0, PI)).isClose(newQuaternion(0.0, 1.0, 0.0, 0.0))
    assert Quaternion.xBy90().isClose( newQuaternion(0.707106, 0.0, 0.0, 0.707106), 1e-4)

    assert (q2 * v1).isClose(newVector3(-1.0, 0.0, 0.0)) # point (1,0,0) rotated by 180 degrees around y-axis(vertical) is (-1,0,0)

proc test_quat3(): void=
    var q: Quaternion = newQuaternion(1.0, 2.0, 3.0, 4.0)
    assert q.isClose(newQuaternion(1.0, 2.0, 3.0, 4.0))
    q.SetVector(newVector3(4.0,5.0,6.0))
    assert q.isClose(newQuaternion(4.0, 5.0, 6.0, 4.0))

proc test_quat4(): void=
    var
        v1: Vector3 = Vector3.left()
        v2: Vector3 = Vector3.up()
        v3: Vector3 = Vector3.forward()
        v4: Vector3 = newVector3(5.0, 5.0, 5.0).normalize()

    var
        q1: Quaternion = VectorRotation(v1, v2)
        q2: Quaternion = VectorRotation(v1, v3)
        q3: Quaternion = VectorRotation(v1, v4)
    assert (q1 * v1).isClose(v2)
    assert (q2 * v1).isClose(v3)
    assert q2.isClose(Quaternion.yBy90())
    assert (q3 * v1).isClose(v4)
     

test_quat1()
test_quat2()
test_quat3()
test_quat4()