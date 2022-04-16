include "../src/RaytracingAlgorithm/quaternion.nim"

var
    quat1 : Quaternion = newQuaternion(1.0, 2.0, 3.0, 5.0)
    quat2 : Quaternion = newQuaternion(4.0, 3.0, 2.0, 1.0)
    quat_id = Quaternion.Identity()
    v1: Vector = newVector(5.0, 4.0, 6.0)

let
    r1 = quat1 * quat2
    r2 = quat1 * v1
    r3 = quat1 * quat_id
    r4 = quat1.Angle(quat2)

    r0 = toEuler(quat1)

echo r0

echo "q1 * q2: ", r1
echo "q1 * v1: ", r2
echo "q1 * id: ", r3

echo "Angle q1,q2: ", r4

echo "Euler: ",r0