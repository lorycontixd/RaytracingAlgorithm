import std/[os, math, macros, strformat]
import geometry, exception, transformation

type
    Quaternion* = ref object
        x*,y*,z*,w*: float32


proc newQuaternion*(): Quaternion=
    result = Quaternion(x:0, y:0, z:0, w:0)

proc newQuaternion*(x,y,z,w: float32): Quaternion=
    result = Quaternion(x:x, y:y, z:z, w:w)

proc newQuaternion*(v: Vector3, w: float32): Quaternion=
    result = newQuaternion(v[0], v[1], v[2], w)

proc newQuaternion*(other: Quaternion): Quaternion=
    result = Quaternion(x:other.x, y:other.y, z:other.z, w:other.w)

proc `[]`*(self: Quaternion, index: int): float32=
    case index:
        of 0:
            return self.x
        of 1:
            return self.y
        of 2:
            return self.z
        of 3:
            return self.w
        else:
            raise ValueError.newException("Invalid index for quaternion.")

proc `[]=`*(self: var Quaternion, index: int, value: float32): void=
    case index:
        of 0:
            self.x = value
        of 1:
            self.y = value
        of 2:
            self.z = value
        of 3:
            self.w = value
        else:
            raise ValueError.newException("Invalid index for quaternion.")

proc Set*(self: var Quaternion, x,y,z,w: float32): void =
    self.x = x
    self.y = y
    self.z = z
    self.w = w

proc SetVector*(self: var Quaternion, vectorComponents: Vector3): void =
    self.x = vectorComponents[0]
    self.y = vectorComponents[1]
    self.z = vectorComponents[2]

proc Identity*(_: typedesc[Quaternion]): Quaternion =
    result = newQuaternion(0.0, 0.0, 0.0, 1.0)

proc `$`*(self: Quaternion): string = 
    result = fmt"Quaternion({self.x},{self.y},{self.z},{self.w})"

proc `+`(lhs, rhs: Quaternion): Quaternion=
    result = newQuaternion(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z, lhs.w + rhs.w)

proc `-`(lhs, rhs: Quaternion): Quaternion=
    result = newQuaternion(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z, lhs.w - rhs.w)

proc `*`*(lhs, rhs: Quaternion): Quaternion {.inline.}=
    result = newQuaternion(
        lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y,
        lhs.w * rhs.y + lhs.y * rhs.w + lhs.z * rhs.x - lhs.x * rhs.z,
        lhs.w * rhs.z + lhs.z * rhs.w + lhs.x * rhs.y - lhs.y * rhs.x,
        lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z
    ) 

proc `*`*(rotation: Quaternion, v: Vector3): Vector3 {.inline.}=
    var
        x: float32 = rotation.x * 2.0
        y: float32 = rotation.y * 2.0
        z: float32 = rotation.z * 2.0
        xx: float32 = rotation.x * x
        yy: float32 = rotation.y * y
        zz: float32 = rotation.z * z
        xy: float32 = rotation.x * y
        xz: float32 = rotation.x * z
        yz: float32 = rotation.y * z
        wx: float32 = rotation.w * x
        wy: float32 = rotation.w * y
        wz: float32 = rotation.w * z
        
    result = newVector3(
        (1.0 - (yy + zz)) * v.x + (xy - wz) * v.y + (xz + wy) * v.z,
        (xy + wz) * v.x + (1.0 - (xx + zz)) * v.y + (yz - wx) * v.z,
        (xz - wy) * v.x + (yz + wx) * v.y + (1.0 - (xx + yy)) * v.z
    )

proc `*`*(v: Vector3, rotation: Quaternion): Vector3 {.inline.}=
    return rotation*v

proc `*`*(rotation: Quaternion, scalar: float32): Quaternion=
    result = newQuaternion(rotation.x * scalar, rotation.y * scalar, rotation.z * scalar, rotation.w * scalar)

proc `/`*(q: Quaternion, scalar: float32): Quaternion=
    return newQuaternion(q.x/scalar, q.y/scalar, q.z/scalar, q.w/scalar)

proc `==`*(lhs, rhs: Quaternion): bool =
    return lhs.x == rhs.x and lhs.y == rhs.y and lhs.z == rhs.z and lhs.w == rhs.w

proc `!=`(lhs, rhs: Quaternion): bool=
    return not(lhs==rhs)

proc isClose*(lhs, rhs: Quaternion, epsilon: float32 = 1e-6): bool=
    return IsEqual(lhs.x, rhs.x, epsilon) and IsEqual(lhs.y, rhs.y, epsilon) and IsEqual(lhs.z, rhs.z, epsilon) and IsEqual(lhs.w, rhs.w, epsilon)

proc isNotClose*(lhs, rhs: Quaternion): bool=
    return not isClose(lhs, rhs)

proc Dot(a,b: Quaternion): float32=
    result = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w

proc Angle*(a,b: Quaternion): float32=
    let dot = min(abs(Dot(a,b)), 1.0)
    if a.isClose(b):
        return 0.0
    else:
        let angle = arccos(dot) * 2.0
        return radToDeg(angle)

proc Norm*(q: Quaternion): float32 =
    return sqrt(Dot(q,q))

proc squaredNorm*(q: Quaternion): float32 =
    return Norm(q) * Norm(q)

proc Conjugate*(q: Quaternion): Quaternion=
    return newQuaternion(-q.x, -q.y, -q.z, q.w)

proc Inverse(q: Quaternion): Quaternion {.inline.}=
    return q.Conjugate() / q.squaredNorm()

proc makePositive*(euler: Vector3): Vector3=
    let negativeFlip = radToDeg(-0.0001)
    let positiveFlip = 360 + negativeFlip

    result = newVector3(euler)
    if (result.x < negativeFlip):
        result.x = result.x + 360.0f
    elif (result.x > positiveFlip):
        result.x -= 360.0f;

    if (result.y < negativeFlip):
        result.y += 360.0f
    elif (result.y > positiveFlip):
        result.y -= 360.0f

    if (result.z < negativeFlip):
        result.z += 360.0f
    elif (result.z > positiveFlip):
        result.z -= 360.0f

proc Normalize*(self: Quaternion, epsilon: float32 = 1e-6): Quaternion=
    let magn = sqrt(Dot(self, self))

    if magn < epsilon:
        return Quaternion.Identity()
    else:
        return newQuaternion(self.x/magn, self.y/magn, self.z/magn, self.w/magn)

proc NormalizeInplace*(self: var Quaternion) : void=
    let magn = sqrt(Dot(self, self))
    self.x = self.x/magn
    self.y = self.y/magn
    self.z = self.z/magn
    self.w = self.w/magn

proc isNormalized*(self: Quaternion): bool=
    return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w == 1

proc toEuler*(q: Quaternion): Vector3 {.inline.}=
    let
        sqw = q.w * q.w
        sqx = q.x * q.x
        sqy = q.y * q.y
        sqz = q.z * q.z
        unit = sqx + sqy + sqz + sqw # if normalised is one, otherwise is correction factor
        test = q.x * q.w - q.y * q.z
    var v: Vector3 = newVector3()

    if (test > 0.4995 * unit): # singularity at north pole
        v.y = 2f * arctan2(q.y, q.x)
        v.x = PI / 2
        v.z = 0
        return makePositive(radToDeg(v))
    if (test < -0.4995 * unit): # singularity at south pole
        v.y = -2f * arctan2(q.y, q.x)
        v.x = - PI / 2.0
        v.z = 0
        return makePositive(radToDeg(v))
    var q2: Quaternion = Normalize(newQuaternion(q.w, q.z, q.x, q.y))
    v.y = (float)arctan2(2.0 * q2.x * q2.w + 2.0 * q2.y * q2.z, 1 - 2.0 * (q2.z * q2.z + q2.w * q2.w)) # Yaw
    v.x = (float)arcsin (2.0 * (q2.x * q2.z - q2.w * q2.y)) # Pitch
    v.z = (float)arctan2(2.0 * q2.x * q2.y + 2.0 * q2.z * q2.w, 1 - 2.0 * (q2.y * q2.y + q2.z * q2.z)) # Roll
    return makePositive(radToDeg(v))

proc fromEuler*(phi, theta, psi: float32): Quaternion {.inline.}=
    let
        qw = cos(phi/2) * cos(theta/2) * cos(psi/2) + sin(phi/2) * sin(theta/2) * sin(psi/2)
        qx = sin(phi/2) * cos(theta/2) * cos(psi/2) - cos(phi/2) * sin(theta/2) * sin(psi/2)
        qy = cos(phi/2) * sin(theta/2) * cos(psi/2) + sin(phi/2) * cos(theta/2) * sin(psi/2)
        qz = cos(phi/2) * cos(theta/2) * sin(psi/2) - sin(phi/2) * sin(theta/2) * cos(psi/2)
    return newQuaternion(qx, qy, qz, qw)

proc toRotationMatrix*(q: Quaternion): Matrix {.inline.}=
    var
        q0: float32 = q[0]
        q1: float32 = q[1]
        q2: float32 = q[2]
        q3: float32 = q[3]

        m00: float32 = 2.0 * (q0 * q0 + q1 * q1)
        m01: float32 = 2.0 * (q1 * q2 - q0 * q3)
        m02: float32 = 2.0 * (q1 * q3 + q0 * q2)
        m03: float32 = 0.0

        m10: float32 = 2.0 * (q1 * q2 + q0 * q3)
        m11: float32 = 2.0 * (q0 * q0 + q2 * q2)
        m12: float32 = 2.0 * (q2 * q3 - q0 * q1)
        m13: float32 = 0.0

        m20: float32 = 2.0 * (q1 * q3 - q0 * q2)
        m21: float32 = 2.0 * (q2 * q3 + q0 * q1)
        m22: float32 = 2.0 * (q0 * q0 + q3 * q3) - 1
        m23: float32 = 0.0

        m30: float32 = 0.0
        m31: float32 = 0.0
        m32: float32 = 0.0
        m33: float32 = 1.0

    ## [m00, m01, m02, 0.0]
    ## [m10, m11, m12, 0.0]
    ## [m20, m21, m22, 0.0]
    ## [0.0, 0.0, 0.0, 1.0]

    result = newMatrix(@[
        @[m00, m01, m02, m03],
        @[m10, m11, m12, m13],
        @[m20, m21, m22, m23],
        @[m30, m31, m32, m33]]
    )


proc Slerp*(a, b: Quaternion, t: float32): Quaternion {.inline.}=
    assert a.isNormalized() and b.isNormalized()

    var q: Quaternion = newQuaternion()
    
    var 
        t2: float32 = 1 - t
        theta: float32 = arccos(Dot(a,b))
        sn: float32 = sin(theta)
        wa: float32 =  sin(t2 * theta) / sn
        wb: float32 = sin(t * theta) / sn
    q.x = wa * a.x + wb * b.x
    q.y = wa * a.y + wb * b.y
    q.z = wa * a.z + wb * b.z
    q.w = wa * a.w + wb * b.w
    result = q.Normalize()


proc RotationQuaternion*(q: Quaternion): Quaternion=
    let angle = q[3]
    let s = sin(angle/2.0)
    result = newQuaternion(
        q.x * s,
        q.y * s,
        q.z * s,
        cos(angle/2.0)
    ) 

proc RotationQuaternion*(axis: Vector3, angle: float32): Quaternion {.inline.}=
    return RotationQuaternion( newQuaternion(axis[0], axis[1], axis[2], angle))

proc VectorRotation*(v1, v2: Vector3): Quaternion {.inline.}=
    result = newQuaternion()
    var
        a: Vector3 = v1.Cross(v2)
    result.SetVector(a)
    result.w = sqrt((v1.norm() * v1.norm()) * (v2.norm() * v2.norm())) + Dot(v1, v2)
    result.NormalizeInplace()

# -- Standard Quaternions

proc xBy90*(_: typedesc[Quaternion]): Quaternion =
    return RotationQuaternion(newQuaternion(1.0, 0.0, 0.0, PI/2.0))
proc xBy180*(_: typedesc[Quaternion]): Quaternion =
    return RotationQuaternion(newQuaternion(1.0, 0.0, 0.0, PI))
proc yBy90*(_: typedesc[Quaternion]): Quaternion =
    return RotationQuaternion(newQuaternion(0.0, 1.0, 0.0, PI/2.0))
proc yBy180*(_: typedesc[Quaternion]): Quaternion =
    return RotationQuaternion(newQuaternion(0.0, 1.0, 0.0, PI))
proc zBy90*(_: typedesc[Quaternion]): Quaternion =
    return RotationQuaternion(newQuaternion(0.0, 0.0, 1.0, PI/2.0))
proc zBy180*(_: typedesc[Quaternion]): Quaternion =
    return RotationQuaternion(newQuaternion(0.0, 0.0, 1.0, PI))

#[ macro for base rotations xby0, xby90, xby180, y, z, ..

macro define_base_quaternions(axis: string, angle: float32)=
    var source: string = fmt"""echo axis"""
    parseStmt(source)
]#