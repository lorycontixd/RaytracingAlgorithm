import std/[math]
import "../src/RaytracingAlgorithm/quaternion.nim"
import "../src/RaytracingAlgorithm/geometry.nim"

let
    phi = PI/2.0
    theta = PI/4.0
    psi = PI/2.0
    q = fromEuler(phi, theta, psi)

    v1 = newVector3(1.0, 0.0, 0.0)
    q2 = newQuaternion(0.0, 1.0, 0.0, 0) # 180 degrees around z-axis (same as rotationquaternion(0.0, 1.0, 0.0, PI))




assert (q*v1).isClose( newVector3(0.0, 0.7071, -0.7071), 1e-3 )
assert RotationQuaternion(newQuaternion(0.0, 1.0, 0.0, PI)).isClose(newQuaternion(0.0, 1.0, 0.0, 0.0))
assert xBy90().isClose( newQuaternion(0.707106, 0.0, 0.0, 0.707106), 1e-4)

assert (q2 * v1).isClose(newVector3(-1.0, 0.0, 0.0)) # point (1,0,0) rotated by 180 degrees around y-axis(vertical) is (-1,0,0)


