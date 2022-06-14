import geometry, exception, quaternion, stats, utils
import std/[math, times]

type
    Matrix* = array[16, float32]


proc GetOffset*(row, col: int): int =
    return col + 4 * row

proc GetValue*(self: Matrix, row, col: int): float32=
    return self[GetOffset(row, col)] 

proc `[]`*(m: Matrix, i, j: int): float32 =
  m.GetValue(i,j)

proc `[]=`*(m: var Matrix, i, j: int, value: float32): void =
  m[GetOffset(i,j)] = value


proc Zeros*(): Matrix =
    result = [0.0.float32, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]


proc Ones*(): Matrix=
    result = [1.0.float32, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

proc IdentityMatrix*(): Matrix=
    result = Zeros()
    result[0,0] = 1.0
    result[1,1] = 1.0
    result[2,2] = 1.0
    result[3,3] = 1.0

proc newMatrix*(): Matrix=
    return Zeros()

proc newMatrix*(m: seq[seq[float32]]): Matrix=
    result = Zeros()
    for i in 0..m.high:
        for j in 0..m[0].high:
            result[i,j] = m[i][j]

proc newMatrix*(m: Matrix): Matrix=
    return deepCopy(m)

## Methods
## 
## NB: we are using homogenous coordinates: matrix 3x3 becomes 4x4 where line_4 and row_4 a
## are all zeros with element[4,4] equal to 0 for vectors and to 1 for points
proc Show*(m: Matrix): void=
    for i in countup(0, 3):
        var line: string = "["
        for j in countup(0, 3):
            let f = round(m[i,j], 3)
            line = line & $f
            if j != m.high:
                line = line & "\t"
        line = line & "]"
        echo line

proc TranslationMatrix*(v: Vector3): Matrix=
    result = [
        float32(1.0), float32(0.0), float32(0.0), float32(v.x),
        float32(0.0), float32(1.0), float32(0.0), float32(v.y),
        float32(0.0), float32(0.0), float32(1.0), float32(v.z),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc TranslationInverseMatrix*(v: Vector3): Matrix=
    result = [
        float32(1.0), float32(0.0), float32(0.0), float32(-v.x),
        float32(0.0), float32(1.0), float32(0.0), float32(-v.y),
        float32(0.0), float32(0.0), float32(1.0), float32(-v.z),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc ScaleMatrix*(v: Vector3): Matrix=
    result = [
        float32(v.x), float32(0.0), float32(0.0), float32(0.0),
        float32(0.0), float32(v.y), float32(0.0), float32(0.0),
        float32(0.0), float32(0.0), float32(v.z), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc ScaleInverseMatrix*(v: Vector3): Matrix=
    result = [
        float32(1/v.x), float32(0.0), float32(0.0), float32(0.0),
        float32(0.0), float32(1/v.y), float32(0.0), float32(0.0),
        float32(0.0), float32(0.0), float32(1/v.z), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0),
    ]

proc RotationX_Matrix*(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = [
        float32(1.0), float32(0.0), float32(0.0), float32(0.0),
        float32(0.0), float32(cosang), float32(-sinang), float32(0.0),
        float32(0.0), float32(sinang), float32(cosang), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc RotationX_InverseMatrix*(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = [
        float32(1.0), float32(0.0), float32(0.0), float32(0.0),
        float32(0.0), float32(cosang), float32(sinang), float32(0.0),
        float32(0.0), float32(-sinang), float32(cosang), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]


proc RotationY_Matrix*(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = [
        float32(cosang), float32(0.0), float32(sinang), float32(0.0),
        float32(0.0), float32(1.0), float32(0.0), float32(0.0),
        float32(-sinang), float32(0.0), float32(cosang), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc RotationY_InverseMatrix*(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = [
        float32(cosang), float32(0.0), float32(-sinang), float32(0.0),
        float32(0.0), float32(1.0), float32(0.0), float32(0.0),
        float32(sinang), float32(0.0), float32(cosang), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc RotationZ_Matrix*(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))

    result = [
        float32(cosang), float32(-sinang), float32(0.0), float32(0.0),
        float32(sinang), float32(cosang), float32(0.0), float32(0.0),
        float32(0.0), float32(0.0), float32(1.0), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc RotationZ_InverseMatrix*(angle_deg: float32): Matrix=
    let
        sinang = sin(degToRad(angle_deg))
        cosang = cos(degToRad(angle_deg))
    result = [
        float32(cosang), float32(-sinang), float32(0.0), float32(0.0),
        float32(-sinang), float32(cosang), float32(0.0), float32(0.0),
        float32(0.0), float32(0.0), float32(1.0), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

    
proc Determinant*(m: Matrix): float32 {.inline, injectProcName.}=
    ## Calculates the inverse matrix of a 4x4 matrix
    let start = now()
    var A2323 = m[2,2] * m[3,3] - m[2,3] * m[3,2]
    var A1323 = m[2,1] * m[3,3] - m[2,3] * m[3,1]
    var A1223 = m[2,1] * m[3,2] - m[2,2] * m[3,1]
    var A0323 = m[2,0] * m[3,3] - m[2,3] * m[3,0]
    var A0223 = m[2,0] * m[3,2] - m[2,2] * m[3,0]
    var A0123 = m[2,0] * m[3,1] - m[2,1] * m[3,0]
    var A2313 = m[1,2] * m[3,3] - m[1,3] * m[3,2]
    var A1313 = m[1,1] * m[3,3] - m[1,3] * m[3,1]
    var A1213 = m[1,1] * m[3,2] - m[1,2] * m[3,1]
    var A2312 = m[1,2] * m[2,3] - m[1,3] * m[2,2]
    var A1312 = m[1,1] * m[2,3] - m[1,3] * m[2,1]
    var A1212 = m[1,1] * m[2,2] - m[1,2] * m[2,1]
    var A0313 = m[1,0] * m[3,3] - m[1,3] * m[3,0]
    var A0213 = m[1,0] * m[3,2] - m[1,2] * m[3,0]
    var A0312 = m[1,0] * m[2,3] - m[1,3] * m[2,0]
    var A0212 = m[1,0] * m[2,2] - m[1,2] * m[2,0]
    var A0113 = m[1,0] * m[3,1] - m[1,1] * m[3,0]
    var A0112 = m[1,0] * m[2,1] - m[1,1] * m[2,0]

    var det: float32 = m[0,0] * ( m[1,1] * A2323 - m[1,2] * A1323 + m[1,3] * A1223 ) - m[0,1] * ( m[1,0] * A2323 - m[1,2] * A0323 + m[1,3] * A0223 ) + m[0,2] * ( m[1,0] * A1323 - m[1,1] * A0323 + m[1,3] * A0123 ) - m[0,3] * ( m[1,0] * A1223 - m[1,1] * A0223 + m[1,2] * A0123 ) ;
    return det

proc Inverse*(m: Matrix): Matrix {.inline, injectProcName.}=
    ## Calculates the inverse matrix of a 4x4 matrix
    let start = now()
    var A2323 = m[2,2] * m[3,3] - m[2,3] * m[3,2]
    var A1323 = m[2,1] * m[3,3] - m[2,3] * m[3,1]
    var A1223 = m[2,1] * m[3,2] - m[2,2] * m[3,1]
    var A0323 = m[2,0] * m[3,3] - m[2,3] * m[3,0]
    var A0223 = m[2,0] * m[3,2] - m[2,2] * m[3,0]
    var A0123 = m[2,0] * m[3,1] - m[2,1] * m[3,0]
    var A2313 = m[1,2] * m[3,3] - m[1,3] * m[3,2]
    var A1313 = m[1,1] * m[3,3] - m[1,3] * m[3,1]
    var A1213 = m[1,1] * m[3,2] - m[1,2] * m[3,1]
    var A2312 = m[1,2] * m[2,3] - m[1,3] * m[2,2]
    var A1312 = m[1,1] * m[2,3] - m[1,3] * m[2,1]
    var A1212 = m[1,1] * m[2,2] - m[1,2] * m[2,1]
    var A0313 = m[1,0] * m[3,3] - m[1,3] * m[3,0]
    var A0213 = m[1,0] * m[3,2] - m[1,2] * m[3,0]
    var A0312 = m[1,0] * m[2,3] - m[1,3] * m[2,0]
    var A0212 = m[1,0] * m[2,2] - m[1,2] * m[2,0]
    var A0113 = m[1,0] * m[3,1] - m[1,1] * m[3,0]
    var A0112 = m[1,0] * m[2,1] - m[1,1] * m[2,0]

    var det: float32 = m[0,0] * ( m[1,1] * A2323 - m[1,2] * A1323 + m[1,3] * A1223 ) - m[0,1] * ( m[1,0] * A2323 - m[1,2] * A0323 + m[1,3] * A0223 ) + m[0,2] * ( m[1,0] * A1323 - m[1,1] * A0323 + m[1,3] * A0123 ) - m[0,3] * ( m[1,0] * A1223 - m[1,1] * A0223 + m[1,2] * A0123 ) ;
    
    if det == 0:
        m.Show()
        raise ZeroDeterminantError.newException("Matrix with zero determinant is not invertible")
    det = float32(1 / det)

    let
        m00 = det *   ( m[1,1] * A2323 - m[1,2] * A1323 + m[1,3] * A1223 )
        m01 = det * - ( m[0,1] * A2323 - m[0,2] * A1323 + m[0,3] * A1223 )
        m02 = det *   ( m[0,1] * A2313 - m[0,2] * A1313 + m[0,3] * A1213 )
        m03 = det * - ( m[0,1] * A2312 - m[0,2] * A1312 + m[0,3] * A1212 )
        m10 = det * - ( m[1,0] * A2323 - m[1,2] * A0323 + m[1,3] * A0223 )
        m11 = det *   ( m[0,0] * A2323 - m[0,2] * A0323 + m[0,3] * A0223 )
        m12 = det * - ( m[0,0] * A2313 - m[0,2] * A0313 + m[0,3] * A0213 )
        m13 = det *   ( m[0,0] * A2312 - m[0,2] * A0312 + m[0,3] * A0212 )
        m20 = det *   ( m[1,0] * A1323 - m[1,1] * A0323 + m[1,3] * A0123 )
        m21 = det * - ( m[0,0] * A1323 - m[0,1] * A0323 + m[0,3] * A0123 )
        m22 = det *   ( m[0,0] * A1313 - m[0,1] * A0313 + m[0,3] * A0113 )
        m23 = det * - ( m[0,0] * A1312 - m[0,1] * A0312 + m[0,3] * A0112 )
        m30 = det * - ( m[1,0] * A1223 - m[1,1] * A0223 + m[1,2] * A0123 )
        m31 = det *   ( m[0,0] * A1223 - m[0,1] * A0223 + m[0,2] * A0123 )
        m32 = det * - ( m[0,0] * A1213 - m[0,1] * A0213 + m[0,2] * A0113 )
        m33 = det *   ( m[0,0] * A1212 - m[0,1] * A0212 + m[0,2] * A0112 )

    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 2)
    return [
        m00.float32, m01, m02, m03,
        m10, m11, m12, m13,
        m20, m21, m22, m23,
        m30, m31, m32, m33
    ]

proc TransposeInplace*(m1: var Matrix): Matrix=
    for i in 0..3:
        for j in 0..3:
            let temp = m1[j,i]
            m1[j,i] = m1[i,j]
            m1[i,j] = temp

proc Transpose*(m1: Matrix): Matrix=
    result = [
        float32(m1[0,0]), float32(m1[1,0]), float32(m1[2,0]), float32(m1[3,0]),
        float32(m1[0,1]), float32(m1[1,1]), float32(m1[2,1]), float32(m1[3,1]),
        float32(m1[0,2]), float32(m1[1,2]), float32(m1[2,2]), float32(m1[3,2]),
        float32(m1[0,3]), float32(m1[1,3]), float32(m1[2,3]), float32(m1[3,3])
    ]

proc Trace*(m: Matrix): float32=
    return m[0,0] + m[1,1] + m[2,2]


proc ToQuaternion*(m: Matrix): Quaternion=
    ##
    ##   
    result = newQuaternion()
    let
        trace = m.Trace()
        a1 = m[0,0] - m[1,1] - m[2,2]
        a2 = -m[0,0] + m[1,1] - m[2,2]
        a3 = -m[0,0] - m[1,1] + m[2,2]
    if (trace > 0):
        result.w = 0.5 * sqrt( trace + 1.0)
    else:
        result.w = 0.5 * sqrt ( ( pow(m[2,1] - m[1,2],2.0) + pow(m[0,2] - m[2,0],2.0) + pow(m[1,0] - m[0,1],2.0)) / (3 - trace) )

    if (a1 > 0):
        result.x = 0.5 * sqrt ( a1 + 1)
    else:
        result.x = 0.5 * sqrt ( ( pow(m[2,1] - m[1,2],2.0) + pow(m[0,1] + m[1,0],2.0) + pow(m[2,0] + m[0,2],2.0)) / (3 - a1) )

    if (a2 > 0):
        result.y = 0.5 * sqrt (a2 + 1)
    else:
        result.y = 0.5 * sqrt ( ( pow(m[0,2] - m[2,0],2.0) + pow(m[0,1] + m[1,0],2.0) + pow(m[1,2] + m[2,1],2.0)) / (3 - a2) )

    if (a3 > 0):
        result.z = 0.5 * sqrt (a3 + 1)
    else:
        result.z = 0.5 * sqrt ( ( pow(m[1,0] - m[0,1],2.0) + pow(m[2,0] + m[0,2],2.0) + pow(m[2,1] + m[1,2],2.0)) / (3 - a3) )


proc ToRotation*(q: var Quaternion): Matrix {.inline.}=
    q = q.Normalize()
    var
        xx: float32 = q.x * q.x
        yy: float32 = q.y * q.y
        zz: float32 = q.z * q.z
        xy: float32 = q.x * q.y
        xz: float32 = q.x * q.z
        yz: float32 = q.y * q.z
        wx: float32 = q.x * q.w
        wy: float32 = q.y * q.w
        wz: float32 = q.z * q.w

    var m: Matrix = Zeros()
    m[0,0] = 1.0 - 2.0 * (yy + zz)
    m[0,1] = 2.0 * (xy + wz)
    m[0,2] = 2.0 * (xz - wy)
    m[1,0] = 2.0 * (xy - wz)
    m[1,1] = 1.0 - 2.0 * (xx + zz)
    m[1,2] = 2.0 * (yz + wx)
    m[2,0] = 2.0 * (xz + wy)
    m[2,1] = 2.0 * (yz - wx)
    m[2,2] = 1.0 - 2.0 * (xx + yy)
    m[3,3] = 1.0
    return m




proc `*`*(this, other: Matrix): Matrix=
    ## Matrix4 - Matrix4 product
    result = Zeros()
    for i in 0 .. 3:
        for j in 0 .. 3:
            for k in 0 .. 3:
                result[i,j] = result[i,j] + this[i,k] * other[k,j]

proc are_matrix_close*(m1, m2 : Matrix, epsilon: float32 = 1e-5): bool=
    for i in 0 .. 3:
        for j in 0 .. 3:
            if not IsEqual(m1[i,j], m2[i,j], epsilon):
                return false
    return true

proc `==`*(m1, m2: Matrix): bool=
    return are_matrix_close(m1,m2)


## -------- Matrix decomposition ----------
func ExtractTranslation*(m: Matrix): Vector3=
    result = newVector3(m[0,3], m[1,3], m[2,3])

func RemoveTranslationFromMatrix(m: Matrix): Matrix=
    result = newMatrix(m)
    for i in 0..3:
        result[i,3] = float32(0.0)
        result[3,i] = float32(0.0)
    result[3,3] = float32(1.0)

proc ExtractRotationMatrix*(m: Matrix): Matrix=
    var M: Matrix = RemoveTranslationFromMatrix(m)
    #- Extract rotation from transform matrix
    var 
        norm: float32
        count: int = 0
        R: Matrix = newMatrix(M)
    
    while true:
        var
            Rnext: Matrix = Zeros()
            Rit: Matrix = Inverse(Transpose(R))
        for i in countup(0,3):
            for j in countup(0,3):
                Rnext[i,j] = 0.5 * (R[i,j] + Rit[i,j])
        norm = 0
        for i in 0..3:
            let n = abs(R[i,0] - Rnext[i,0]) + abs(R[i,1] - Rnext[i,1]) + abs(R[i,2] - Rnext[i,2]) 
            norm = max(norm, n)
        R = newMatrix(Rnext)
        count = count + 1
        if (count > 100 or norm <= 0.0001):
            break
    let x = newMatrix(R)
    result = x

proc ExtractRotation*(m: Matrix): Quaternion=
    var R: Matrix = ExtractRotationMatrix(m)
    result = ToQuaternion(R).Normalize()

proc ExtractScale*(R: Matrix, M: Matrix): Matrix=
    result = matrix.Inverse(R) * M

proc ExtractScale*(m: Matrix): Matrix=
    result = ExtractScale(ExtractRotationMatrix(m), RemoveTranslationFromMatrix(m))

proc Decompose*(m: Matrix, T: var Vector3, Rquat: var Quaternion, S: var Matrix): void {.inline.}=
    ##
    ##

    #- Extract translation components from transform matrix
    T = ExtractTranslation(m)
    #- Compute a matrix with no translation components
    Rquat = ExtractRotation(m)
    #- Extract scale matrix -> M=RS
    S = ExtractScale(m)