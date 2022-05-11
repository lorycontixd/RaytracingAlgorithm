import geometry, utils 
import std/[sequtils, math]


type
    Matrix* = seq[seq[float32]]
    Transformation* = object
        m*, inverse*: Matrix

proc newMatrix*(s: seq[seq[float32]]): Matrix=
    return cast[Matrix](s)

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



#[
proc TranslationMatrix*(v: Vector3): Matrix=
    result = newSeq[seq[float32]](4)
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i<3:
            result[i][result.len-1] = float32(v[i])

proc TranslationInverseMatrix*(v: Vector3): Matrix=
    result = newSeq[seq[float32]](4)
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i<3:
            result[i][result.len-1] = float32(-v[i])

proc ScaleMatrix*(v: Vector3): Matrix=
    result = newSeq[seq[float32]](4)
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        if i<3:
            result[i][i] = float32(v[i])
        else:
            result[i][i] = float32(1.0)
            
proc ScaleInverseMatrix*(v: Vector3): Matrix=

    result = newSeq[seq[float32]](4)
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        if i<3:
            result[i][i] = float32(1.0/v[i])
        else:
            result[i][i] = float32(1.0)

proc RotationX_Matrix(angle_deg: float32): Matrix=
    result = newSeq[seq[float32]](4)
    let angle = degToRad(angle_deg)
    let ang = [cos(angle), sin(angle)]
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i==1:
            result[i][i] = ang[0]
            result[i][i+1] = -ang[1]
        if i==2:
            result[i][i-1] = ang[1]
            result[i][i] = ang[0]

proc RotationX_InverseMatrix(angle_deg: float32): Matrix=
    result = newSeq[seq[float32]](4)
    let angle = degToRad(angle_deg)
    let ang = [cos(angle), sin(angle)]
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i==1:
            result[i][i] = ang[0]
            result[i][i+1] = ang[1]
        if i==2:
            result[i][i-1] = -ang[1]
            result[i][i] = ang[0]

proc RotationY_Matrix(angle_deg: float32): Matrix=
    result = newSeq[seq[float32]](4)
    let angle = degToRad(angle_deg)
    let ang = [cos(angle), sin(angle)]
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i==0:
            result[i][i] = ang[0]
            result[i][i+2] = ang[1]
        if i==2:
            result[i][i-2] = -ang[1]
            result[i][i] = ang[0]

proc RotationY_InverseMatrix(angle_deg: float32): Matrix=
    result = newSeq[seq[float32]](4)
    let angle = degToRad(angle_deg)
    let ang = [cos(angle), sin(angle)]
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i==0:
            result[i][i] = ang[0]
            result[i][i+2] = -ang[1]
        if i==2:
            result[i][i-2] = ang[1]
            result[i][i] = ang[0]

proc RotationZ_Matrix(angle_deg: float32): Matrix=
    result = newSeq[seq[float32]](4)
    let angle = degToRad(angle_deg)
    let ang = [cos(angle), sin(angle)]
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i==0:
            result[i][i] = ang[0]
            result[i][i+1] = -ang[1]
            result[i+1][i] = ang[1]
            result[i+1][i+1] = ang[0]

proc RotationZ_InverseMatrix(angle_deg: float32): Matrix=
    result = newSeq[seq[float32]](4)
    let angle = degToRad(angle_deg)
    let ang = [cos(angle), sin(angle)]
    for i in 0 ..< result.len:
        result[i] = newSeq[float32](4)
        result[i][i] = float32(1.0)
        if i==0:
            result[i][i] = ang[0]
            result[i][i+1] = ang[1]
            result[i+1][i] = -ang[1]
            result[i+1][i+1] = ang[0]
]#


proc TranslationMatrix*(v: Vector3): Matrix=
    result = @[
        @[float32(1.0), float32(0.0), float32(0.0), float32(v.x)],
        @[float32(0.0), float32(1.0), float32(0.0), float32(v.y)],
        @[float32(0.0), float32(0.0), float32(1.0), float32(v.z)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)],
    ]

proc TranslationInverseMatrix*(v: Vector3): Matrix=
    result = @[
        @[float32(1.0), float32(0.0), float32(0.0), float32(-v.x)],
        @[float32(0.0), float32(1.0), float32(0.0), float32(-v.y)],
        @[float32(0.0), float32(0.0), float32(1.0), float32(-v.z)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)],
    ]

proc ScaleMatrix*(v: Vector3): Matrix=
    result = @[
        @[float32(v.x), float32(0.0), float32(0.0), float32(0.0)],
        @[float32(0.0), float32(v.y), float32(0.0), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(v.z), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)],
    ]

proc ScaleInverseMatrix*(v: Vector3): Matrix=
    result = @[
        @[float32(1/v.x), float32(0.0), float32(0.0), float32(0.0)],
        @[float32(0.0), float32(1/v.y), float32(0.0), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(1/v.z), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)],
    ]

proc RotationX_Matrix(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = @[
        @[float32(1.0), float32(0.0), float32(0.0), float32(0.0)],
        @[float32(0.0), float32(cosang), float32(-sinang), float32(0.0)],
        @[float32(0.0), float32(sinang), float32(cosang), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)]
    ]

proc RotationX_InverseMatrix(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = @[
        @[float32(1.0), float32(0.0), float32(0.0), float32(0.0)],
        @[float32(0.0), float32(cosang), float32(sinang), float32(0.0)],
        @[float32(0.0), float32(-sinang), float32(cosang), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)]
    ]


proc RotationY_Matrix(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = @[
        @[float32(cosang), float32(0.0), float32(sinang), float32(0.0)],
        @[float32(0.0), float32(1.0), float32(0.0), float32(0.0)],
        @[float32(-sinang), float32(0.0), float32(cosang), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)]
    ]

proc RotationY_InverseMatrix(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = @[
        @[float32(cosang), float32(0.0), float32(-sinang), float32(0.0)],
        @[float32(0.0), float32(1.0), float32(0.0), float32(0.0)],
        @[float32(sinang), float32(0.0), float32(cosang), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)]
    ]

proc RotationZ_Matrix(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = @[
        @[float32(cosang), float32(-sinang), float32(0.0), float32(0.0)],
        @[float32(sinang), float32(cosang), float32(0.0), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(1.0), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)]
    ]

proc RotationZ_InverseMatrix(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))
    result = @[
        @[float32(cosang), float32(-sinang), float32(0.0), float32(0.0)],
        @[float32(-sinang), float32(cosang), float32(0.0), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(1.0), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)]
    ]

proc newTransformation*(m: Matrix=IdentityMatrix(), inv: Matrix=IdentityMatrix()): Transformation=
    result = Transformation(m:m, inverse:inv) 

proc Inverse*(t: Transformation): Transformation=
    result = Transformation(m:t.inverse, inverse:t.m)

proc `*`*(this, other: Matrix): Matrix=
    ## Matrix4 - Matrix4 product
    result = Zeros()
    for i in 0 .. 3:
        for j in 0 .. 3:
            for k in 0 .. 3:
                result[i][j] += this[i][k] * other[k][j]

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

proc translation*(_: typedesc[Transformation], vector: Vector3): Transformation =
    result = newTransformation()
    result.m = TranslationMatrix(vector)
    result.inverse = TranslationInverseMatrix(vector)

proc scale*(_: typedesc[Transformation], vector: Vector3): Transformation =
    result = newTransformation()
    result.m = ScaleMatrix(vector)
    result.inverse = ScaleInverseMatrix(vector)
    
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


##-------------------- utilities --------------------

proc inverse*(m: Matrix): Matrix {.inline.}=
    var A2323 = m[2][2] * m[3][3] - m[2][3] * m[3][2]
    var A1323 = m[2][1] * m[3][3] - m[2][3] * m[3][1]
    var A1223 = m[2][1] * m[3][2] - m[2][2] * m[3][1]
    var A0323 = m[2][0] * m[3][3] - m[2][3] * m[3][0]
    var A0223 = m[2][0] * m[3][2] - m[2][2] * m[3][0]
    var A0123 = m[2][0] * m[3][1] - m[2][1] * m[3][0]
    var A2313 = m[1][2] * m[3][3] - m[1][3] * m[3][2]
    var A1313 = m[1][1] * m[3][3] - m[1][3] * m[3][1]
    var A1213 = m[1][1] * m[3][2] - m[1][2] * m[3][1]
    var A2312 = m[1][2] * m[2][3] - m[1][3] * m[2][2]
    var A1312 = m[1][1] * m[2][3] - m[1][3] * m[2][1]
    var A1212 = m[1][1] * m[2][2] - m[1][2] * m[2][1]
    var A0313 = m[1][0] * m[3][3] - m[1][3] * m[3][0]
    var A0213 = m[1][0] * m[3][2] - m[1][2] * m[3][0]
    var A0312 = m[1][0] * m[2][3] - m[1][3] * m[2][0]
    var A0212 = m[1][0] * m[2][2] - m[1][2] * m[2][0]
    var A0113 = m[1][0] * m[3][1] - m[1][1] * m[3][0]
    var A0112 = m[1][0] * m[2][1] - m[1][1] * m[2][0]

    var det = m[0][0] * ( m[1][1] * A2323 - m[1][2] * A1323 + m[1][3] * A1223 ) - m[0][1] * ( m[1][0] * A2323 - m[1][2] * A0323 + m[1][3] * A0223 ) + m[0][2] * ( m[1][0] * A1323 - m[1][1] * A0323 + m[1][3] * A0123 ) - m[0][3] * ( m[1][0] * A1223 - m[1][1] * A0223 + m[1][2] * A0123 ) ;
    det = 1 / det;

    let
        m00 = det *   ( m[1][1] * A2323 - m[1][2] * A1323 + m[1][3] * A1223 )
        m01 = det * - ( m[0][1] * A2323 - m[0][2] * A1323 + m[0][3] * A1223 )
        m02 = det *   ( m[0][1] * A2313 - m[0][2] * A1313 + m[0][3] * A1213 )
        m03 = det * - ( m[0][1] * A2312 - m[0][2] * A1312 + m[0][3] * A1212 )
        m10 = det * - ( m[1][0] * A2323 - m[1][2] * A0323 + m[1][3] * A0223 )
        m11 = det *   ( m[0][0] * A2323 - m[0][2] * A0323 + m[0][3] * A0223 )
        m12 = det * - ( m[0][0] * A2313 - m[0][2] * A0313 + m[0][3] * A0213 )
        m13 = det *   ( m[0][0] * A2312 - m[0][2] * A0312 + m[0][3] * A0212 )
        m20 = det *   ( m[1][0] * A1323 - m[1][1] * A0323 + m[1][3] * A0123 )
        m21 = det * - ( m[0][0] * A1323 - m[0][1] * A0323 + m[0][3] * A0123 )
        m22 = det *   ( m[0][0] * A1313 - m[0][1] * A0313 + m[0][3] * A0113 )
        m23 = det * - ( m[0][0] * A1312 - m[0][1] * A0312 + m[0][3] * A0112 )
        m30 = det * - ( m[1][0] * A1223 - m[1][1] * A0223 + m[1][2] * A0123 )
        m31 = det *   ( m[0][0] * A1223 - m[0][1] * A0223 + m[0][2] * A0123 )
        m32 = det * - ( m[0][0] * A1213 - m[0][1] * A0213 + m[0][2] * A0113 )
        m33 = det *   ( m[0][0] * A1212 - m[0][1] * A0212 + m[0][2] * A0112 )

    return cast[Matrix](@[
        @[m00, m01, m02, m03],
        @[m10, m11, m12, m13],
        @[m20, m21, m22, m23],
        @[m30, m31, m32, m33]
    ])

proc transpose*(m1: Matrix): Matrix=
    result = cast[Matrix](@[
        @[float32(m1[0][0]), float32(m1[1][0]), float32(m1[2][0]), float32(m1[3][0])],
        @[float32(m1[0][1]), float32(m1[1][1]), float32(m1[2][1]), float32(m1[3][1])],
        @[float32(m1[0][2]), float32(m1[1][2]), float32(m1[2][2]), float32(m1[3][2])],
        @[float32(m1[0][3]), float32(m1[1][3]), float32(m1[2][3]), float32(m1[3][3])],
    ])

proc are_matrix_close*(m1, m2 : Matrix): bool=
    for i in 0 .. 3:
        for j in 0 .. 3:
            return IsEqual(m1[i][j], m2[i][j])

proc is_consistent*(t : Transformation): bool =
    let product = t.m * t.inverse
    return are_matrix_close(product, IdentityMatrix())

proc `==`*(m1, m2: Matrix): bool=
    return are_matrix_close(m1,m2)
