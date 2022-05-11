import geometry, utils, matrix
import std/[sequtils, math]

type
    Transformation* = object
        m*, inverse*: Matrix



proc newTransformation*(m: Matrix=IdentityMatrix(), inv: Matrix=IdentityMatrix()): Transformation=
    result = Transformation(m:m, inverse:inv) 

proc newTransformation*(m: Matrix): Transformation=
    result = Transformation(m: m, inverse: matrix.inverse(m))



proc Inverse*(t: Transformation): Transformation=
    result = Transformation(m:t.inverse, inverse:t.m)


proc `*`*(t: Transformation, other: Vector3): Vector3=
    result = newVector3(
        t.m[0][0] * other.x + t.m[0][1] * other.y + t.m[0][2] * other.z,# + t m[0][3],
        t.m[1][0] * other.x + t.m[1][1] * other.y + t.m[1][2] * other.z,# + t.m[1][3],
        t.m[2][0] * other.x + t.m[2][1] * other.y + t.m[2][2] * other.z,# + t.m[2][3]
    )

proc `*`*(t: Transformation, other: Point): Point=
    result = newPoint(
        t.m[0][0] * other.x + t.m[0][1] * other.y + t.m[0][2] * other.z + t.m[0][3],
        t.m[1][0] * other.x + t.m[1][1] * other.y + t.m[1][2] * other.z + t.m[1][3],
        t.m[2][0] * other.x + t.m[2][1] * other.y + t.m[2][2] * other.z + t.m[2][3]
    )
    let w = other.x * t.m[3][0] + other.y * t.m[3][1] + other.z * t.m[3][2]  + t.m[3][3] 
    if float32(w) != 1.0 and float32(w) != 0.0:
        result.x = result.x / w
        result.y = result.y / w
        result.z = result.z / w

proc `*`*(t: Transformation, other: Normal): Normal=
    result = newNormal(
        t.m[0][0] * other.x + t.m[0][1] * other.y + t.m[0][2] * other.z + t.m[0][3],
        t.m[1][0] * other.x + t.m[1][1] * other.y + t.m[1][2] * other.z + t.m[1][3],
        t.m[2][0] * other.x + t.m[2][1] * other.y + t.m[2][2] * other.z + t.m[2][3]
    )

proc `*`*(self, other: Transformation): Transformation= 
    var
        res_m: Matrix = self.m * other.m
        res_inv: Matrix = other.inverse * self.inverse
    result = newTransformation(res_m, res_inv)


proc is_consistent*(t : Transformation): bool =
    let product = t.m * t.inverse
    return are_matrix_close(product, IdentityMatrix())



### -------------------------------------------------- Static methods -----------------------------------

proc translation*(_: typedesc[Transformation], vector: Vector3): Transformation =
    result = newTransformation()
    result.m = TranslationMatrix(vector)
    result.inverse = TranslationInverseMatrix(vector)

proc translation*(_: typedesc[Transformation], x,y,z: float32): Transformation=
    result = newTransformation()
    result.m = TranslationMatrix(newVector3(x,y,z))
    result.inverse = TranslationInverseMatrix(newVector3(x,y,z))

proc scale*(_: typedesc[Transformation], vector: Vector3): Transformation =
    result = newTransformation()
    result.m = ScaleMatrix(vector)
    result.inverse = ScaleInverseMatrix(vector)

proc scale*(_: typedesc[Transformation], x,y,z: float32): Transformation =
    result = newTransformation()
    result.m = ScaleMatrix(newVector3(x,y,z))
    result.inverse = ScaleInverseMatrix(newVector3(x,y,z))
    
proc rotationX*(_: typedesc[Transformation], angle_deg: float32): Transformation =
    result = newTransformation()
    result.m = RotationX_Matrix(angle_deg)
    result.inverse = RotationX_InverseMatrix(angle_deg)

proc rotationY*(_: typedesc[Transformation], angle_deg: float32): Transformation =
    result = newTransformation()
    result.m = RotationY_Matrix(angle_deg)
    result.inverse = RotationY_InverseMatrix(angle_deg)

proc rotationZ*(_: typedesc[Transformation], angle_deg: float32): Transformation =
    result = newTransformation()
    result.m = RotationZ_Matrix(angle_deg)
    result.inverse = RotationZ_InverseMatrix(angle_deg)