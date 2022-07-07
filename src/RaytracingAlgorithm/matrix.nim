import geometry, exception, quaternion, stats, utils
import std/[math, times]

type
    ##class for 4x4 matrix
    Matrix* = array[16, float32] 


proc GetOffset*(row, col: int): int =
    ## Gets the array index corresponding to the matrix element specified
    ## Parameters
    ##      row (int): row of matrix element
    ##      col (int): column of matrix element
    ## Returns
    ##      (int) : index of the array-element representing the matrix-element
    return col + 4 * row

proc GetValue*(self: Matrix, row, col: int): float32=
    ## Gets the value of the element of the matrix
    ## Parameters
    ##      self (Matrix): matrix which the element belongs to
    ##      row (int): row of matrix element
    ##      col (int): column of matrix element
    ## Returns
    ##      (float) : value of the element 
    return self[GetOffset(row, col)] 

proc `[]`*(m: Matrix, i, j: int): float32 =
    ## Gets the value of the (i,j) element of the matrix
    ## Parameters
    ##      self (Matrix): matrix which the element belongs to
    ##      i (int): row of matrix element
    ##      j (int): column of matrix element
    ## Returns
    ##      (float) : value of the element 
    m.GetValue(i,j)

proc `[]=`*(m: var Matrix, i, j: int, value: float32): void =
    ## Sets the value of the (i,j) element of the matrix to 'value'
    ## Parameters
    ##      self (Matrix): matrix which the element belongs to
    ##      i (int): row of matrix element
    ##      j (int): column of matrix element
    ##      value (float): value to be assigned
    ## Returns
    ##      no returns, just sets the element value
    m[GetOffset(i,j)] = value


proc Zeros*(): Matrix =
    ## Creates a zeros-Matrix
    ## Parameters
    ##      no params
    ## Returns
    ##      a zeros-Matrix (4x4, float elements)
    result = [0.0.float32, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]


proc Ones*(): Matrix=
    ## Creates a ones-Matrix
    ## Parameters
    ##      no params
    ## Returns
    ##      a ones-Matrix (4x4, float elements)
    result = [1.0.float32, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

proc IdentityMatrix*(): Matrix=
    ## Creates an Identity-Matrix
    ## Parameters
    ##      no params
    ## Returns
    ##      Identity Matrix (4x4, float elements)
    result = Zeros()
    result[0,0] = 1.0
    result[1,1] = 1.0
    result[2,2] = 1.0
    result[3,3] = 1.0

proc newMatrix*(): Matrix=
    ## Creates an empty Matrix
    ## Parameters
    ##      no params
    ## Returns
    ##      zeros-Matrix (4x4, float elements)
    return Zeros()

proc newMatrix*(m: seq[seq[float32]]): Matrix=
    ## Creates a Matrix object from a sequence of sequnce of floats
    ## Parameters
    ##      m (sequence[sequnence[float]) : sequence to be converted into matirx
    ## Returns
    ##      Matrix
    result = Zeros()
    for i in 0..m.high:
        for j in 0..m[0].high:
            result[i,j] = m[i][j]

proc newMatrix*(m: Matrix): Matrix=
    ## Creates a deep copy of a Matrix
    ## Parameters
    ##      m (Matrix): matrix to be copied
    ## Returns
    ##      Matrix : copy of the input matrix
    return deepCopy(m)

## Methods
## 
## NB: we are using homogenous coordinates: matrix 3x3 becomes 4x4 where line_4 and row_4 
## are all zeros with element[4,4] equal to 0 for vectors and to 1 for points

proc Show*(m: Matrix): void=
    ## Prints the matrix
    ## Parameters
    ##      m (Matrix): matrix to be printed
    ## Returns
    ##      no returns, just a print
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
    ## Returns the Matrix object encoding a rigid translation
    ## Parameters
    ##       v (Vector3): specifies the amount of shift to be applied along the three axes
    ## Returns
    ##       translation matrix
    result = [
        float32(1.0), float32(0.0), float32(0.0), float32(v.x),
        float32(0.0), float32(1.0), float32(0.0), float32(v.y),
        float32(0.0), float32(0.0), float32(1.0), float32(v.z),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc TranslationInverseMatrix*(v: Vector3): Matrix=
    ## Returns the Matrix object encoding the Inverse matrix for a rigid translation
    ## Parameters
    ##       v (Vector3): specifies the amount of shift to be applied along the three axes
    ## Returns
    ##       translation Inverse matrix
    result = [
        float32(1.0), float32(0.0), float32(0.0), float32(-v.x),
        float32(0.0), float32(1.0), float32(0.0), float32(-v.y),
        float32(0.0), float32(0.0), float32(1.0), float32(-v.z),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc ScaleMatrix*(v: Vector3): Matrix=
    ## Returns the Matrix object encoding a scale transformation
    ## 
    ## Parameters
    ##        v (Vector3): specifies the amount of scaling to be applied along the three axes
    ## Returns
    ##       scale matrix
    result = [
        float32(v.x), float32(0.0), float32(0.0), float32(0.0),
        float32(0.0), float32(v.y), float32(0.0), float32(0.0),
        float32(0.0), float32(0.0), float32(v.z), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0)
    ]

proc ScaleInverseMatrix*(v: Vector3): Matrix=
    ## Returns the Matrix object encoding the Inverse matrix for a scale transformation
    ## 
    ## Parameters
    ##        v (Vector3): specifies the amount of scaling to be applied along the three axes
    ## Returns
    ##       scale Inverse matrix
    result = [
        float32(1/v.x), float32(0.0), float32(0.0), float32(0.0),
        float32(0.0), float32(1/v.y), float32(0.0), float32(0.0),
        float32(0.0), float32(0.0), float32(1/v.z), float32(0.0),
        float32(0.0), float32(0.0), float32(0.0), float32(1.0),
    ]

proc RotationX_Matrix*(angle_deg: float32): Matrix=
    ## Returns a Matrix object encoding a rotation around axisX
    ## 
    ## Parameters
    ##         angle in degrees (float), which specifies the rotation angle.
    ##                              The positive sign is given by the right-hand rule
    ## Returns
    ##         Rotation aroud X-axis matrix
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
    ## Returns a Matrix object encoding the Inverse matrix for a rotation around axisX
    ## 
    ## Parameters
    ##       angle in degrees (float), which specifies the rotation angle.
    ##                          The positive sign is given by the right-hand rule
    ## Returns
    ##       Rotation aroud X-axis Inverse matrix
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
    ## Returns a Matrix object encoding a rotation around axisY
    ## 
    ## Parameters
    ##         angle in degrees (float), which specifies the rotation angle.
    ##                              The positive sign is given by the right-hand rule
    ## Returns
    ##         Rotation aroud Y-axis matrix
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
    ## Returns a Matrix object encoding the Inverse matrix for a rotation around axisY
    ## 
    ## Parameters
    ##       angle in degrees (float), which specifies the rotation angle.
    ##                          The positive sign is given by the right-hand rule
    ## Returns
    ##       Rotation aroud Y-axis Inverse matrix
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
    ## Returns a Matrix object encoding a rotation around axisZ
    ## 
    ## Parameters
    ##         angle in degrees (float), which specifies the rotation angle.
    ##                              The positive sign is given by the right-hand rule
    ## Returns
    ##         Rotation aroud Z-axis matrix
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
    ## Returns a Matrix object encoding the Inverse matrix for a rotation around axisZ
    ## 
    ## Parameters
    ##       angle in degrees (float), which specifies the rotation angle.
    ##                          The positive sign is given by the right-hand rule
    ## Returns
    ##       Rotation aroud Z-axis Inverse matrix
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
    ## Calculates the determinant of a 4x4 matrix
    ## Parameters
    ##      m (Matrix)
    ## Returns
    ##      det (float): determinant
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
    ## Parameters
    ##      m (Matrix): matrix from which compute the Inverse 
    ## Returns
    ##      array[float] : array representing the inverse matrix of m
    #let start = now()
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

    #let endTime = now() - start
    #mainStats.AddCall(procName, endTime, 2)
    return [
        m00.float32, m01, m02, m03,
        m10, m11, m12, m13,
        m20, m21, m22, m23,
        m30, m31, m32, m33
    ]

proc TransposeInplace*(m1: var Matrix): Matrix=
    ## Sets a matrix equal to its transpose
    ## Parameters
    ##      m1 (Matrix): matrix of which compute the transpose
    ## Returns
    ##      no returns, just sets m1 equal to its transpose
    for i in 0..3:
        for j in 0..3:
            let temp = m1[j,i]
            m1[j,i] = m1[i,j]
            m1[i,j] = temp

proc Transpose*(m1: Matrix): Matrix=
    ## Returns the transpose of a matrix
    ## Parameters
    ##      m1 (Matrix): matrix of which compute the transpose
    ## Returns
    ##      array[float]: transpose matrix of m1
    result = [
        float32(m1[0,0]), float32(m1[1,0]), float32(m1[2,0]), float32(m1[3,0]),
        float32(m1[0,1]), float32(m1[1,1]), float32(m1[2,1]), float32(m1[3,1]),
        float32(m1[0,2]), float32(m1[1,2]), float32(m1[2,2]), float32(m1[3,2]),
        float32(m1[0,3]), float32(m1[1,3]), float32(m1[2,3]), float32(m1[3,3])
    ]

proc Trace*(m: Matrix): float32=
    ## Returns the trace of a matrix
    ## Parameters
    ##      m (Matrix): matrix of which compute the trace
    ## Returns
    ##      float: trace of m
    return m[0,0] + m[1,1] + m[2,2]


## ----- Quaternions --------
## quaternions are useful to codify rotations in 3D-space

proc ToQuaternion*(m: Matrix): Quaternion=
    ## Returns the quaternion which corresponds to a given matrix
    ## Parameters
    ##      m (Matrix): matrix of which calculate the corresponding quaternion 
    ## Returns
    ##      (Quaternion): corresponding quaternion
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
    ## Returns the rotation matrix from a given quaternion
    ## Parameters
    ##      q (Quaternion): quaternion from which derive the rotation matrix
    ## Returns
    ##      m (Matrix): rotation matrix
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


## --------------------------------------------------

proc `+`*(this, other: Matrix): Matrix=
    result = Zeros()
    for i in 0 .. 3:
        for j in 0 .. 3:
            result[i,j] = this[i,j] + other[i,j]

proc `*`*(this, other: Matrix): Matrix=
    ## Matrix4 - Matrix4 product
    ## Parameters
    ##      this, other (Matrix): matrixes 4x4
    ## Returns
    ##      product matrix 4x4
    result = Zeros()
    for i in 0 .. 3:
        for j in 0 .. 3:
            for k in 0 .. 3:
                result[i,j] = result[i,j] + this[i,k] * other[k,j]

proc are_matrix_close*(m1, m2 : Matrix, epsilon: float32 = 1e-5): bool=
    ## Verifies if two matrixes are equal
    ## Parameters
    ##      m1, m2 (Matrix): matrixes to be verified
    ##      epsilon (float): threshold for equality --> m1 - m2 must be < epsilon
    ##                          default-value: 1e-5
    ## Returns
    ##      (Bool): True (matrixes are equal) or False (else)
    for i in 0 .. 3:
        for j in 0 .. 3:
            if not IsEqual(m1[i,j], m2[i,j], epsilon):
                return false
    return true

proc `==`*(m1, m2: Matrix): bool=
    ## Verifies if two matrixes are equal
    ## Parameters
    ##      m1, m2 (Matrix): matrixes to be verified -->  m1 - m2 must be < 1e-5
    ## Returns
    ##      (Bool): True (matrixes are equal) or False (else)
    return are_matrix_close(m1,m2)


## -------- Matrix decomposition ----------
func ExtractTranslation*(m: Matrix): Vector3=
    ## Returns the vector representing the amount of shift from the transformed matrix
    ## Parameters
    ##      m (Matrix): transformed matrix from which extract the translation-vector 
    ## Returns
    ##      (Vector3): vector representing the translation
    result = newVector3(m[0,3], m[1,3], m[2,3])

func RemoveTranslationFromMatrix(m: Matrix): Matrix=
    ## Returns the initial matrix, removing the translation applied
    ## Parameters
    ##       m (Matrix): transformed matrix from which extract the initial matrix
    ## Returns
    ##      (Matrix): the initial matrix
    result = newMatrix(m)
    for i in 0..3:
        result[i,3] = float32(0.0)
        result[3,i] = float32(0.0)
    result[3,3] = float32(1.0)

proc ExtractRotationMatrix*(m: Matrix): Matrix=
    ## Returns the rotation-matrix, representing the transformation applied to the matrix
    ## Parameters
    ##      m (Matrix): transformed matrix from which extract the rotation-matrix 
    ## Returns
    ##      (Matrix): rotation matrix
    
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
    ## Returns the rotation-matrix as a quaternion, representing the transformation applied to the matrix
    ## Parameters
    ##      m (Matrix): transformed matrix from which extract the quaternion
    ## Returns
    ##      (Matrix): quaternion (representing the rotation matrix)
    var R: Matrix = ExtractRotationMatrix(m)
    result = ToQuaternion(R).Normalize()

proc ExtractScale*(R: Matrix, M: Matrix): Matrix=
    ## Returns the scale matrix, from a matrix transformed with both scale and rotation
    ## Parameters
    ##       R (Matrix): Rotation matrix
    ##       M (Matrix): transformed matrix from which extract the scale matrix
    ## Returns
    ##      (Matrix): scale matrix
    result = matrix.Inverse(R) * M

proc ExtractScale*(m: Matrix): Matrix=
    ## Returns the scale matrix, representing the transformation applied to the matrix
    ## Parameters
    ##       m (Matrix): transformed matrix from which extract the scale matrix
    ## Returns
    ##      (Matrix): scale matrix
    result = ExtractScale(ExtractRotationMatrix(m), RemoveTranslationFromMatrix(m))

proc Decompose*(m: Matrix, T: var Vector3, Rquat: var Quaternion, S: var Matrix): void {.inline.}=
    ## Decomposes a matrix into its transformation components
    ## Parameters
    ##      m (Matrix): transformed matrix
    ##      T (Vector3): translation vectors
    ##      Rquat (Quaternion): quaternion representing the rotation
    ##      S (Matrix): scale matrix
    ## Returns
    ##      no returns, just decomposes

    #- Extract translation components from transform matrix
    T = ExtractTranslation(m)
    #- Compute a matrix with no translation components
    Rquat = ExtractRotation(m)
    #- Extract scale matrix -> M=RS
    S = ExtractScale(m)