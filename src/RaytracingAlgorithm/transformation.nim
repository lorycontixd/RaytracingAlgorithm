import geometry, matrix

type
    Transformation* = object
        m*, inverse*: Matrix


proc newTransformation*(): Transformation=
    result = Transformation(m:IdentityMatrix(), inverse: IdentityMatrix())

proc newTransformation*(m: Matrix, inv: Matrix): Transformation=
    result = Transformation(m:m, inverse:inv) 

proc newTransformation*(m: Matrix): Transformation=
    result = Transformation(m: m, inverse: Inverse(m))



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
#[
proc `*`*(self: Transformation, b: Bounds3): Bounds3=
    result = newBounds3(self * newPoint(b.pMin.x, b.pMin.y, b.pMin.z))
    result = Union(result, self * newPoint(b.pMax.x, b.pMin.y, b.pMin.z))
    result = Union(result, self * newPoint(b.pMin.x, b.pMax.y, b.pMin.z))
    result = Union(result, self * newPoint(b.pMin.x, b.pMin.y, b.pMax.z))
    result = Union(result, self * newPoint(b.pMin.x, b.pMax.y, b.pMax.z))
    result = Union(result, self * newPoint(b.pMax.x, b.pMax.y, b.pMin.z))
    result = Union(result, self * newPoint(b.pMax.x, b.pMin.y, b.pMax.z))
    result = Union(result, self * newPoint(b.pMax.x, b.pMax.y, b.pMax.z))
]#

proc `==`*(self, other: Transformation): bool=
    return are_matrix_close(self.m, other.m ) and are_matrix_close(self.inverse, other.inverse)

proc `!=`*(self, other: Transformation): bool=
    return not (self == other)

func TransformVector3*(self: Transformation, v: Vector3): Vector3=
    return self * v

func TransformNormal*(self: Transformation, n: Normal): Normal=
    return self * n

func TransformPoint*(self: Transformation, p: Point): Point=
    return self * p

#func TransformBounds*(self: Transformation, bounds: Bounds3): Bounds3=
#    return self * bounds

proc LookAt*(pos: Point, look: Point, up: Vector3): Transformation=
    ## Returns the necessary transformation to get an object to face a specific point (usually used on a camera)
    ## The call specifies the position of the object and the point for the object to look at, together with an "up" bector for object orientation.
    ## The returned transformation is a transformation between object(camera) space to world space.
    ## 
    ## Parameters
    ##      position (Point): 
    ##      look (Point):
    ##      up (Vector3):
    ## Returns
    ##      
    var cameraToWorld: Matrix = newMatrix()
    # Set camera position in world space
    cameraToWorld[0][3] = pos[0]
    cameraToWorld[1][3] = pos[1]
    cameraToWorld[2][3] = pos[2]
    cameraToWorld[3][3] = float32(1.0)

    let
        dir = (look - pos).convert(Vector3).normalize()
        right = Vector3.Cross(up.normalize(), dir).normalize()
        newUp = Vector3.Cross(dir, right)
    cameraToWorld[0][0] = right.x
    cameraToWorld[1][0] = right.y
    cameraToWorld[2][0] = right.z
    cameraToWorld[3][0] = float32(0.0)
    cameraToWorld[0][1] = newUp.x
    cameraToWorld[1][1] = newUp.y
    cameraToWorld[2][1] = newUp.z
    cameraToWorld[3][1] = float32(0.0)
    cameraToWorld[0][2] = dir.x
    cameraToWorld[1][2] = dir.y
    cameraToWorld[2][2] = dir.z
    cameraToWorld[3][2] = float32(0.0)
    return newTransformation(Inverse(cameraToWorld), cameraToWorld)



proc is_consistent*(t : Transformation): bool =
    let product = t.m * t.inverse
    return are_matrix_close(product, IdentityMatrix())

proc Show*(self: Transformation): void=
    echo "=> Matrix: "
    self.m.Show()
    echo ""
    echo "=> Inverse: "
    self.inverse.Show()
    


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