import geometry, utils 
import std/[sequtils]


type
    Matrix* = seq[seq[float32]]
    Transformation* = object
        m*, inverse*: Matrix


proc IdentityMatrix*(): Matrix=
    result = newSeq[seq[float32]](4)
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)

proc Zeros*(): Matrix =
    result = newSeq[seq[float32]](4)
    for i in 0 .. 3:
        result[i] = newSeq[float32](4)
        for j in 0 .. 3:
            result[i][j] = float32(0.0)

proc Ones*(): Matrix=
    result = newSeq[seq[float32]](4)
    for i in 0 .. 3:
        result[i] = newSeq[float32](4)
        for j in 0 .. 3:
            result[i][j] = float32(1.0)

proc ScaleMatrix(v: Vector): Matrix=
    result = newSeq[seq[float32]](4)
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        if i<3:
            result[i][i] = float32(v[i])
        else:
            result[i][i] = float32(1.0)

proc ScaleInverseMatrix(v: Vector): Matrix=
    result = newSeq[seq[float32]](4)
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        if i<3:
            result[i][i] = float32(1.0/v[i])
        else:
            result[i][i] = float32(1.0)

proc TranslationMatrix(v: Vector): Matrix=
    result = newSeq[seq[float32]](4)
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i<3:
            result[i][result.len-1] = float32(v[i])

proc TranslationInverseMatrix(v: Vector): Matrix=
    result = newSeq[seq[float32]](4)
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i<3:
            result[i][result.len-1] = float32(-v[i])



proc newTransormation*(m: Matrix=IdentityMatrix(), inv: Matrix=IdentityMatrix()): Transformation=
    result = Transformation(m:m, inverse:inv) 

proc inverse*(t: Transformation): Transformation=
    result = Transformation(m:t.inverse, inverse:t.m)

proc `*`*(t: Transformation, other: Vector): Vector=
    result = newVector(
        t.m[0][0] * other.x + t.m[0][1] * other.y + t.m[0][2] * other.z,
        t.m[1][0] * other.x + t.m[1][1] * other.y + t.m[1][2] * other.z,
        t.m[2][0] * other.x + t.m[2][1] * other.y + t.m[2][2] * other.z
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

#proc `*`*(t: Transformation, other: Transformation): Transformation= 

proc translation*(_: typedesc[Transformation], vector: Vector): Transformation=
    result = newTransormation()
    result.m = TranslationMatrix(vector)
    result.inverse = TranslationInverseMatrix(vector)

proc scale*(_: typedesc[Transformation], vector: Vector): Transformation=
    result = newTransormation()
    result.m = ScaleMatrix(vector)
    result.inverse = ScaleInverseMatrix(vector)
    



proc `*`*(this, other: Matrix): Matrix=
    result = Zeros()
    for i in 0 .. 3:
        for j in 0 .. 3:
            for k in 0 .. 3:
                result[i][j] += this[i][k] * other[k][j]


##-------------------- utilities --------------------
proc are_matrix_close*(m1, m2 : Matrix): bool=
    for i in 0 .. 3:
        for j in 0 .. 3:
            return IsEqual(m1[i][j], m2[i][j])

proc is_consistent*(t : Transformation): bool =
    let product = t.m * t.inverse
    return are_matrix_close(product, IdentityMatrix())
    
