import std/[os, math, strformat]
import geometry, mathutils
from utils import IsEqual

type
    Quaternion* = ref object
        x*,y*,z*,w*: float32



# --------------- Constructors -----------------
proc newQuaternion*(): Quaternion=
    ## constructor for quaternion, sets to 0 all parameters
    result = Quaternion(x:0, y:0, z:0, w:0)

proc newQuaternion*(x,y,z,w: float32): Quaternion=
    ## constructor for quaternion
    result = Quaternion(x:x, y:y, z:z, w:w)

proc newQuaternion*(v: Vector3, w: float32): Quaternion=
    ## constructor for quaternion (normalized)
    result = newQuaternion(v[0], v[1], v[2], w)
    let dot = result.x * result.x + result.y * result.y + result.z * result.z + result.w * result.w
    let magn = sqrt(dot)
    result.x = result.x/magn
    result.y = result.y/magn
    result.z = result.z/magn
    result.w = result.w/magn

#[
proc newQuaternion*(m: Matrix): Quaternion= 
    result = newQuaternion()
    let trace = m.trace()
    if (trace > 0.0):
        let s = sqrt( trace + m[3][3] )
        result.w = s / 2.0
        result.x = m[2][1] - m[1][2] * s
        result.y = m[0][2] - m[2][0] * s
        result.z = m[1][0] - m[0][1] * s
    else:
        var 
            next: seq[int] = @[1,2,0]
            q: seq[float32] = newSeq[float32](3)
            i: int = 0
        if (m[1][1] > m[0][0]):
            i = 1
        if (m[2][2] > m[i][i]):
            i = 2
        let
            j = next[i]
            k = next[j]
        var s: float32 = sqrt((m[i][i] - (m[j][j] + m[k][k])) + 1.0)
        q[i] = s * 0.5
        if (s != 0.0):
            s = 0.5 / s
        result.w = (m[k][j] - m[j][k]) * s
        q[j] = (m[j][i] + m[i][j]) * s
        q[k] = (m[k][i] + m[i][k]) * s
        result.x = q[0]
        result.y = q[1]
        result.z = q[2]
        let dot = result.x * result.x + result.y * result.y + result.z * result.z + result.w * result.w
        let magn = sqrt(dot)
        result.x = result.x/magn
        result.y = result.y/magn
        result.z = result.z/magn
        result.w = result.w/magn
]#

proc newQuaternion*(other: Quaternion): Quaternion=
    ## returns a quaternion euqal to another
    result = Quaternion(x:other.x, y:other.y, z:other.z, w:other.w)

# ----------------- Operators -------------------

proc `[]`*(self: Quaternion, index: int): float32=
    ## Quaternion Getter operator. Returns the i-th component of a quaternion.
    ##
    ## Parameters
    ##      index (int): Index of the component
    ##
    ## Returns
    ##      i-th component of the quaternion where i=index
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
    ## Quaternion Setter operator. Sets the i-th component of a quaternion.
    ##
    ## Parameters
    ##      index (int): Index of the component to be set
    ##      value (float32): New value for the quaternion component
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

proc `$`*(self: Quaternion): string = 
    ## String representation of a quaternion.
    ## A quaternion with components x,y,z,w is stringified as 'Quaternion(x,y,z,w)'
    ##
    ## Returns
    ##      String representation of the quaternion
    result = fmt"Quaternion({self.x},{self.y},{self.z},{self.w})"

proc `+`(lhs, rhs: Quaternion): Quaternion=
    ## Sum between two quaternions
    ## Parameters
    ##      lhs, rhs (Quaternion): quaternions to be summed
    ## Results
    ##      (Quaternion): resulting from the sum
    result = newQuaternion(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z, lhs.w + rhs.w)

proc `-`(lhs, rhs: Quaternion): Quaternion=
    ## Difference between two quaternions
    ## Parameters
    ##      lhs, rhs (Quaternion): quaternions to be substracted
    ## Results
    ##      (Quaternion): resulting from the difference
    result = newQuaternion(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z, lhs.w - rhs.w)

proc `*`*(lhs, rhs: Quaternion): Quaternion {.inline.}=
    ## Product between two quaternions
    ## Parameters
    ##      lhs, rhs (Quaternion): quaternions to be multiplied
    ## Results
    ##      (Quaternion): resulting from the product
    result = newQuaternion(
        lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y,
        lhs.w * rhs.y + lhs.y * rhs.w + lhs.z * rhs.x - lhs.x * rhs.z,
        lhs.w * rhs.z + lhs.z * rhs.w + lhs.x * rhs.y - lhs.y * rhs.x,
        lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z
    ) 

proc `*`*(rotation: Quaternion, v: Vector3): Vector3 {.inline.}=
    ## Multiplication '*' operator between a quaternion and a Vector3.
    ## Applying a quaternion to a vector results in a rotation of the vector to a new vector, described by the quaternion.
    ## The implementation of the product is already the solution of the multiplication q' = q v q*, where vector v is multiplied by the quaternion and its conjugate.
    ## The multiplication q v changes the length of the vector, therefore a multiplication for the conjugate q* is required to cancel out the change in length.
    ##
    ## Parameters
    ##      rotation (Quaternion): Quaternion responsible for the rotation
    ##      v (Vector3): The vector to be multiplied
    ##
    ## Returns
    ##      The rotated Vector3
    var
        x: float32 = rotation.x * 2.0
        y: float32 = rotation.y * 2.0
        z: float32 = rotation.z * 2.0
        xx: float32 = rotation.x * x # 2x^2
        yy: float32 = rotation.y * y # 2y^2
        zz: float32 = rotation.z * z # 2z^2
        xy: float32 = rotation.x * y # 2xy
        xz: float32 = rotation.x * z # 2xz
        yz: float32 = rotation.y * z # 2yz
        wx: float32 = rotation.w * x # 2wz
        wy: float32 = rotation.w * y # 2wy
        wz: float32 = rotation.w * z # 2wz
        
    result = newVector3(
        (1.0 - (yy + zz)) * v.x + (xy - wz) * v.y + (xz + wy) * v.z,
        (xy + wz) * v.x + (1.0 - (xx + zz)) * v.y + (yz - wx) * v.z,
        (xz - wy) * v.x + (yz + wx) * v.y + (1.0 - (xx + yy)) * v.z
    )

proc `*`*(v: Vector3, rotation: Quaternion): Vector3 {.inline.}=
    ## v * q --> Mirror of q * v
    ## See q * v documentation
    return rotation*v

proc `*`*(rotation: Quaternion, scalar: float32): Quaternion=
    ## Product between a quaternion and a scalar
    ## Parameters
    ##      rotation (Quaternion): quaternions to be multiplied
    ##      scalar (float)
    ## Results
    ##      (Quaternion): resulting from the product
    result = newQuaternion(rotation.x * scalar, rotation.y * scalar, rotation.z * scalar, rotation.w * scalar)

proc `*`*(scalar: float32, rotation: Quaternion): Quaternion=
    ## scalar * q --> Mirror of q * scalar
    ## See q * scalar documentation
    return rotation * scalar

proc `/`*(q: Quaternion, scalar: float32): Quaternion=
    ## Division between a quaternion and a scalar
    ## Parameters
    ##      q (Quaternion)
    ##      scalar (float)
    ## Results
    ##      (Quaternion): resulting from the division
    return newQuaternion(q.x/scalar, q.y/scalar, q.z/scalar, q.w/scalar)

proc `==`*(lhs, rhs: Quaternion): bool =
    ## Verifies if two quaternions are the same
    return lhs.x == rhs.x and lhs.y == rhs.y and lhs.z == rhs.z and lhs.w == rhs.w

proc `!=`*(lhs, rhs: Quaternion): bool=
    ## Verifies if two quaternions are NOT the same
    return not(lhs==rhs)

proc isClose*(lhs, rhs: Quaternion, epsilon: float32 = 1e-6): bool=
    ## Verifies if two quaternions are equal 
    ## raturns True if their difference is less then epsilon (default_value: 10^(-6))
    return IsEqual(lhs.x, rhs.x, epsilon) and IsEqual(lhs.y, rhs.y, epsilon) and IsEqual(lhs.z, rhs.z, epsilon) and IsEqual(lhs.w, rhs.w, epsilon)

proc isNotClose*(lhs, rhs: Quaternion): bool=
    ## Verifies if two quaternions are different
    ## opposite of 'isClose'
    return not isClose(lhs, rhs)

# ------------------------------------- Setters and Getters -------------------------------------
proc Set*(self: var Quaternion, x,y,z,w: float32): void =
    ## Sets quaternion values
    ##
    ## Parameters
    ##      self (Quaternion)
    ##      x,y,z,w (float32)
    self.x = x
    self.y = y
    self.z = z
    self.w = w

proc SetVector*(self: var Quaternion, vectorComponents: Vector3): void =
    # Sets quaternion values
    ##
    ## Parameters
    ##      self (Quaternion)
    ##      vectorComponents (Vector3)
    self.x = vectorComponents[0]
    self.y = vectorComponents[1]
    self.z = vectorComponents[2]

# ------------------------------------------- Methods ------------------------------------------

proc Dot*(a,b: Quaternion): float32=
    ## Returns the dot product of two quaternions
    ## Parameters
    ##      a,b (Quaternion)
    ## Results
    ##      (float)
    result = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w

proc Angle*(a,b: Quaternion): float32=
    ## Returns the angle in degrees between two quaternions
    ## Parameters
    ##      a,b (Quaternion)
    ## Results
    ##      (float)
    let dot = min(abs(Dot(a,b)), 1.0)
    if a.isClose(b):
        return 0.0
    else:
        let angle = arccos(dot) * 2.0
        return radToDeg(angle)

proc Identity*(_: typedesc[Quaternion]): Quaternion =
    ## Identity quaternion
    result = newQuaternion(0.0, 0.0, 0.0, 1.0)

proc Norm*(q: Quaternion): float32 =
    ## Returns the norm of a quaternion
    return sqrt(Dot(q,q))

proc Normalize*(self: Quaternion, epsilon: float32 = 1e-6): Quaternion=
    ## Normalizes a quaternion
    let magn = Norm(self)

    if magn < epsilon:
        return Quaternion.Identity()
    else:
        return self / magn

proc NormalizeInplace*(self: var Quaternion) : void=
    ## Normalizes inplace a quaternion
    let magn = sqrt(Dot(self, self))
    self.x = self.x/magn
    self.y = self.y/magn
    self.z = self.z/magn
    self.w = self.w/magn

proc squaredNorm*(q: Quaternion): float32 =
    ## Returns the suqared norm of a quaternion
    return Norm(q) * Norm(q)

proc Conjugate*(q: Quaternion): Quaternion=
    ## Returns the conjugate of a quaternion
    return newQuaternion(-q.x, -q.y, -q.z, q.w)

proc Inverse*(q: Quaternion): Quaternion=
    ## Returns the inverse of a quaternion
    return q.Conjugate() / q.squaredNorm()

proc Negativize*(q: Quaternion): Quaternion=
    ## Returns the negative of a quaternion
    return newQuaternion(-q.x, -q.y, -q.z, -q.w)

proc makePositive*(euler: Vector3): Vector3=
    let negativeFlip = radToDeg(-0.0001)
    let positiveFlip = 360 + negativeFlip

    result = newVector3(euler)
    if (result.x < negativeFlip):
        result.x = result.x + 360.0
    elif (result.x > positiveFlip):
        result.x -= 360.0

    if (result.y < negativeFlip):
        result.y += 360.0
    elif (result.y > positiveFlip):
        result.y -= 360.0

    if (result.z < negativeFlip):
        result.z += 360.0
    elif (result.z > positiveFlip):
        result.z -= 360.0

proc isNormalized*(self: Quaternion): bool=
    ## Verifies if a quaternion is normalized
    return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w == 1

proc toEuler*(q: Quaternion): Vector3 {.inline.}=
    ## Sets a quaternion equal to a set of Euler Angles
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
    ## Load a quaternion from a set of Euler Angles
    ## 
    ## Parameters
    ##      phi (float32): phi angle of Euler
    ##      theta (float32): theta angle of Euler
    ##      psi (float32): psi angle of Euler
    ## Returns
    ##      Quaternion conversion of the Euler angles.
    let
        qw = cos(phi/2) * cos(theta/2) * cos(psi/2) + sin(phi/2) * sin(theta/2) * sin(psi/2)
        qx = sin(phi/2) * cos(theta/2) * cos(psi/2) - cos(phi/2) * sin(theta/2) * sin(psi/2)
        qy = cos(phi/2) * sin(theta/2) * cos(psi/2) + sin(phi/2) * cos(theta/2) * sin(psi/2)
        qz = cos(phi/2) * cos(theta/2) * sin(psi/2) - sin(phi/2) * sin(theta/2) * cos(psi/2)
    return newQuaternion(qx, qy, qz, qw)

#[
proc Slerp*(a, b: var Quaternion, t: var float32): Quaternion {.inline.} =
    ## Spherical linear interpolation between two quaternions.
    ## Interpolates a quaternion in between two quaternions based on the free parameter t.
    ## If t=0, returns the first quaternion. If t=1, returns the second quaternion.
    ## This function clamps the value of t between 0 and 1.
    ##
    ## Parameters
    ##      a (Quaternion): Starting quaternion
    ##      b (Quaternion): Ending quaternion
    ##      t (float32): Interpolation value
    ##
    ## Returns
    ##      Interpolated quaternion between a and b at value t 
    ## 
    a = a.Normalize()
    b = b.Normalize()
    var cosTheta: float32 = Dot(a, b)
    if (cosTheta > 0.9995):  #a,b are parallel
        return Normalize((1 - t) * a + t * b);  #linear interpolation
    else:
        var theta: float32 = arccos(Clamp(cosTheta, -1, 1))
        echo "t: ",theta
        var thetap: float32 = theta * t
        var qperp: Quaternion = Normalize(b - a * cosTheta) #orthogonl to a
        return a * cos(thetap) + qperp * sin(thetap) #interpolation quaternion
]#
proc Slerp*(a, b: var Quaternion, t: var float32): Quaternion {.inline.} =
    ## Returns the interpolation between two rotations (a,b quaternions) at time t
    ## Parameters
    ##      a,b (Quaternion): initial and final quaternion
    ##      t (float): time at which interpolate
    ## Returns
    ##      (Quaternion): quaterion interpolated at time t
    a = a.Normalize()
    b = b.Normalize()
    t = Clamp(t, 0.0, 1.0)
    var dot: float32 = Dot(a,b)
    let theta = arccos(Clamp(dot, -1.0, 1.0))
    if theta.IsEqual(0.0):
        return Normalize((1 - t) * a + t * b)
    return a * ( sin((1-t)*theta)/(sin(theta)) ) + b * (sin(t*theta) / sin(theta))

proc RotationQuaternion*(q: Quaternion): Quaternion=
    ## Rotates a quaternion
    let angle = q[3]
    let s = sin(angle/2.0)
    result = newQuaternion(
        q.x * s,
        q.y * s,
        q.z * s,
        cos(angle/2.0)  
    ) 

proc RotationQuaternion*(axis: Vector3, angle: float32): Quaternion {.inline.}=
    ## Rotates a quaternion of 'angle'
    ## Parameters
    ##      axis (Vector3)
    ##      angle (float)
    ## Returns
    ##      (Quaternion)
    return RotationQuaternion( newQuaternion(axis[0], axis[1], axis[2], angle))



# ------------------------------ Static Methods -----------------------------------
proc VectorRotation*(_: typedesc[Quaternion], v1, v2: Vector3): Quaternion {.inline.}=
    ## Computes the necessary quaternion to rotate a vector to another.
    ## 
    ## Parameters:
    ##      v1 (Vector3): Starting vector
    ##      v2 (Vector3): End vector
    ##
    ## Returns
    ##      The quaternion responsible for the rotation from v1 to v2
    result = newQuaternion()
    var
        a: Vector3 = v1.Cross(v2)
    result.SetVector(a)
    result.w = sqrt((v1.norm() * v1.norm()) * (v2.norm() * v2.norm())) + Dot(v1, v2)
    result.NormalizeInplace()



###### ----------- Standard Quaternions --------------

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

    
