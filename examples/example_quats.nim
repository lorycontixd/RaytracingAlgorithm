include "../src/RaytracingAlgorithm/quaternion.nim"

var
    q1: Quaternion = newQuaternion(1.0, 0.0, 0.0, 0.0) # 0 deg around (1,0,0)
    q2: Quaternion = newQuaternion(1.0, 0.0, 0.0, PI/2) # 90 deg around (1,0,0)
    q3: Quaternion = newQuaternion(1.0, 0.0, 0.0, PI) # 180 deg around (1,0,0)

    q4: Quaternion = newQuaternion(0.0, 1.0, 0.0, PI/2) # 90 deg around (0,1,0)
    q5: Quaternion = newQuaternion(0.0, 1.0, 0.0, PI) # 180 deg around (0,1,0)

echo RotationQuaternion(q1)
echo RotationQuaternion(q2)
echo RotationQuaternion(q3)
echo RotationQuaternion(q4)
echo RotationQuaternion(q5)
