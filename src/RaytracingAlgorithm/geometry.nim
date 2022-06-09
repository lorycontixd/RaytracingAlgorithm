import std/[math, macros, typetraits, strformat, strutils]
from utils import IsEqual

type
    Vector3* = object   #to represent the ray-light direction
        x*, y*, z*: float32
    
    Vector2* = object
        u*, v*: float32

    Point* = object
        x*, y*, z*: float32
    
    Normal* = object   #to represent the surface inclination in a point
        x*, y*, z*: float32

## --------------------------------  CONSTRUCTORS  ------------------------------------------

macro defineEmptyConstructors(type1: typedesc) =
    let source = fmt"""
proc new{$type1}*(): {$type1} =
    result = {$type1}(x: 0.0, y: 0.0, z: 0.0)
"""
    result = parseStmt(source)

proc newVector2*(): Vector2=
    result = Vector2(u: 0.0, v: 0.0)

#[proc newPoint*(x: float32, y: float32, z: float32) : Point =
    result = Point(x:x, y:y, z:z)]#

macro defineConstructors(type1: typedesc) =
    let source = fmt"""
proc new{$type1}*(x,y,z: float32): {$type1} =
    result = {$type1}(x: x, y: y, z: z)
"""
    result = parseStmt(source)

proc newVector2*(u, v: float32): Vector2=
    result = Vector2(u:u, v:v)

macro defineCopyConstructors(type1: typedesc) =
    let source = fmt"""
proc new{$type1}*(other: {$type1}): {$type1} =
    result = {$type1}(x: other.x, y: other.y, z: other.z)
"""
    result = parseStmt(source)

proc newVector2*(other: Vector2): Vector2=
    result = Vector2(u: other.u, v: other.v)

defineEmptyConstructors(Point)
defineEmptyConstructors(Vector3)
defineEmptyConstructors(Normal)
defineConstructors(Point)
defineConstructors(Vector3)
defineConstructors(Normal)
defineCopyConstructors(Point)
defineCopyConstructors(Vector3)
defineCopyConstructors(Normal)


## --------------------------------  Sum + Subtraction  ------------------------------------------

template defineOperations(fname: untyped, type1: typedesc, type2: typedesc, rettype: typedesc) =
    proc fname*(a: type1, b: type2): rettype =
        result.x = fname(a.x, b.x)
        result.y = fname(a.y, b.y)
        result.z = fname(a.z, b.z)

defineOperations(`+`, Vector3, Vector3, Vector3)
defineOperations(`-`, Vector3, Vector3, Vector3)
defineOperations(`+`, Vector3, Point, Point)
defineOperations(`-`, Vector3, Point, Point)
defineOperations(`+`, Point, Vector3, Point)
defineOperations(`-`, Point, Vector3, Point)
defineOperations(`+`, Normal, Normal, Normal)
defineOperations(`-`, Normal, Normal, Normal)
defineOperations(`+`, Point, Point, Point)
defineOperations(`-`, Point, Point, Point)

template defineVector2Operations(fname: untyped) =
    proc fname*(a, b: Vector2): Vector2=
        result.u = fname(a.u, b.u)
        result.v = fname(a.v, b.v)

defineVector2Operations(`+`)
defineVector2Operations(`-`)

## ---------------------------------------  Products  ------------------------------------------

template defineFloatProduct(type1: typedesc) =
    # Product with scalar
    proc `*`*(a: type1, b: float32): type1 =
        result.x = a.x * b
        result.y = a.y * b
        result.z = a.z * b
    
    proc `*`*(b: float32, a: type1): type1 =
        result.x = a.x * b
        result.y = a.y * b
        result.z = a.z * b

defineFloatProduct(Vector3)
defineFloatProduct(Point)
defineFloatProduct(Normal)

proc `*`*(scalar: float32, v: Vector2): Vector2=
    result = newVector2(v.u * scalar, v.v * scalar)

proc `*`*(v: Vector2, scalar: float32): Vector2=
    result = scalar * v

template defineComponentProduct(type1, type2, rettype: typedesc) =
    proc ComponentProduct*(a: type1, b: type2): rettype=
        result.x = a.x * b.x
        result.y = a.y * b.y
        result.z = a.z * b.z

defineComponentProduct(Point, Point, Point)
defineComponentProduct(Vector3, Vector3, Vector3)
defineComponentProduct(Point, Vector3, Vector3)
defineComponentProduct(Vector3, Point, Vector3)

template defineFloatDivision(type1: typedesc) =
    # Product with scalar
    proc `/`*(a: type1, b: float32): type1 =
        result.x = a.x / b
        result.y = a.y / b
        result.z = a.z / b
    
    proc `/`*(b: float32, a: type1): type1 =
        result.x = b / a.x 
        result.y = b / a.y
        result.z = b / a.z

defineFloatDivision(Vector3)
defineFloatDivision(Point)
defineFloatDivision(Normal)


template defineDot(type1: typedesc, type2: typedesc) = 
    proc Dot*(this: type1, other: type2): float32 = 
        result = this.x * other.x + this.y * other.y + this.z * other.z
    
    proc `*`*(this: type1, other: type2): float32 = 
        result = this.Dot(other)

defineDot(Vector3, Vector3)
defineDot(Normal, Vector3)
defineDot(Vector3, Normal)
defineDot(Point, Vector3)
defineDot(Vector3, Point)

proc Dot*(this, other: Vector2): float32=
    result = this.u * other.u + this.v * other.v

proc `*`*(this, other: Vector2): float32 = 
        result = this.Dot(other)

template defineCross(type1: typedesc, type2: typedesc, rettype: typedesc) =
    proc Cross*(this: type1, other: type2): rettype =
        result.x = this.y * other.z - this.z * other.y
        result.y = this.z * other.x - this.x * other.z
        result.z = this.x * other.y - this.y * other.x

defineCross(Vector3, Vector3, Vector3)
defineCross(Normal, Vector3, Vector3)
defineCross(Vector3, Normal, Vector3)
defineCross(Normal, Normal, Vector3)
## ----------------------------------------  Norm  ----------------------------------------------

template defineNorm(type1: typedesc)=
    proc squareNorm*(a: type1): float32=
        result = pow(a.x,2) + pow(a.y,2) + pow(a.z,2)
    proc norm*(a: type1): float32=
        result = sqrt(square_norm(a))
    
defineNorm(Vector3)
defineNorm(Point)
defineNorm(Normal)

proc squareNorm*(a: Vector2): float32=
    result = pow(a.u,2) + pow(a.v,2)

proc norm*(a: Vector2): float32 =
    result = sqrt(square_norm(a))

## ------------------------------------  Other operators  ---------------------------------------

template defineNegative(type1: typedesc) =
    proc neg*(a: type1): type1 =
        result.x = -a.x
        result.y = -a.y
        result.z = -a.z

defineNegative(Vector3)
defineNegative(Normal)
defineNegative(Point)


proc neg*(a: Vector2): Vector2=
    result = newVector2(-a.u, -a.v)




# convert
template defineConvert(type1: typedesc, rettype: typedesc) =
    proc convert*(a: type1, t: typedesc[rettype]): rettype =
        result.x = a.x
        result.y = a.y
        result.z = a.z

defineConvert(Vector3, Normal)
defineConvert(Point, Vector3)
defineConvert(Vector3, Point)
defineConvert(Normal, Vector3)
defineConvert(Normal, Point)

template defineEqualities(type1: typedesc) =
    proc `==`*(this, other: type1): bool=
        return this.x == other.x and this.y == other.y and this.z == other.z
    
    proc `!=`*(this, other: type1): bool=
        return this.x != other.x or this.y != other.y or this.z != other.z

    proc isClose*(this, other: type1, eps: float32 = 1e-4): bool=
        return IsEqual(this.x, other.x, eps) and IsEqual(this.y, other.y, eps) and IsEqual(this.z, other.z, eps)

    proc isNotClose*(this, other: type1): bool=
        return not(IsEqual(this.x, other.x) or IsEqual(this.y, other.y) or IsEqual(this.z, other.z))

defineEqualities(Vector3)
defineEqualities(Point)
defineEqualities(Normal)

# normalize
template defineNormalize(type1: typedesc)=     #returns normalized Vector3 or Normal 
    proc normalize*(a: type1): type1=
        result.x = a.x/a.norm()
        result.y = a.y/a.norm()
        result.z = a.z/a.norm()

    proc normalizeInplace*(a: var type1): void=
        a.x = a.x/a.norm()
        a.y = a.y/a.norm()
        a.z = a.z/a.norm()

    proc IsNormalized*(a: type1): bool=
        return (a.x * a.x + a.y * a.y * a.z * a.z).IsEqual(1.0)

defineNormalize(Vector3)
defineNormalize(Normal)
defineNormalize(Point)

proc normalize*(a: Vector2): Vector2=
    result.u = a.u/a.norm()
    result.v = a.v/a.norm()




proc `==`*(this, other: Vector2): bool =
    return this.u == other.u and this.v == other.v

proc `!=`*(this, other: Vector2): bool=
        return this.u != other.u or this.v != other.v

proc isClose*(this, other: Vector2, eps: float32 = 1e-5): bool=
        return IsEqual(this.u, other.u, eps) and IsEqual(this.v, other.v, eps)

proc isNotClose*(this, other: Vector2): bool=
    return not(IsEqual(this.u, other.v) or IsEqual(this.u, other.v))


macro defineGetitem(type1: untyped): untyped=
    ## Get item for variable of type type1 (with x,y,z components)
    ## Called through [] operator
    ## 
    ## Example:
    ## var v: Vector3 = newVector3(1,2,3)
    ## --> assert v[1] == 2
    result = nnkStmtList.newTree(
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode("[]")
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                newIdentNode("float32"),
                nnkIdentDefs.newTree(
                    newIdentNode("this"),
                    newIdentNode($type1),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("index"),
                    newIdentNode("int"),
                    newEmptyNode()
                )
            ),
            nnkPragma.newTree(
                newIdentNode("inline")
            ),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkCaseStmt.newTree(
                    newIdentNode("index"),
                    nnkOfBranch.newTree(
                        newLit(0),
                        nnkStmtList.newTree(
                            nnkReturnStmt.newTree(
                                nnkDotExpr.newTree(
                                    newIdentNode("this"),
                                    newIdentNode("x")
                                )
                            )
                        )
                    ),
                    nnkOfBranch.newTree(
                        newLit(1),
                        nnkStmtList.newTree(
                            nnkReturnStmt.newTree(
                                nnkDotExpr.newTree(
                                    newIdentNode("this"),
                                    newIdentNode("y")
                                )
                            )
                        )
                    ),
                    nnkOfBranch.newTree(
                        newLit(2),
                        nnkStmtList.newTree(
                            nnkReturnStmt.newTree(
                                nnkDotExpr.newTree(
                                    newIdentNode("this"),
                                    newIdentNode("z")
                                )
                            )
                        )
                    ),
                    nnkElse.newTree(
                        nnkStmtList.newTree(
                            nnkRaiseStmt.newTree(
                                nnkCall.newTree(
                                    nnkDotExpr.newTree(
                                    newIdentNode("ValueError"),
                                    newIdentNode("newException")
                                    ),
                                    newLit("Invalid access index")
                                )
                            )
                        )
                    )
                )
            )
        )
    )


macro defineSetitem(type1: untyped): untyped=
    ## Set item for variable of type type1 (with x,y,z components)
    ## Called through []= operator
    ## 
    ## Example:
    ## var v: Vector3 = newVector3(1,2,3)
    ## --> v[1] = 3.2
    result = nnkStmtList.newTree(
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode("[]=")
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                newIdentNode("void"),
                nnkIdentDefs.newTree(
                    newIdentNode("this"),
                    nnkVarTy.newTree(
                        newIdentNode($type1)
                    ),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("index"),
                    newIdentNode("int"),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("value"),
                    newIdentNode("float"),
                    newEmptyNode()
                )
            ),
            nnkPragma.newTree(
                newIdentNode("inline")
            ),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkCaseStmt.newTree(
                    newIdentNode("index"),
                    nnkOfBranch.newTree(
                        newLit(0),
                        nnkStmtList.newTree(
                            nnkAsgn.newTree(
                            nnkDotExpr.newTree(
                                newIdentNode("this"),
                                newIdentNode("x")
                            ),
                            newIdentNode("value")
                            )
                        )
                    ),
                    nnkOfBranch.newTree(
                        newLit(1),
                        nnkStmtList.newTree(
                            nnkAsgn.newTree(
                            nnkDotExpr.newTree(
                                newIdentNode("this"),
                                newIdentNode("y")
                            ),
                            newIdentNode("value")
                            )
                        )
                    ),
                    nnkOfBranch.newTree(
                        newLit(2),
                        nnkStmtList.newTree(
                            nnkAsgn.newTree(
                            nnkDotExpr.newTree(
                                newIdentNode("this"),
                                newIdentNode("z")
                            ),
                            newIdentNode("value")
                            )
                        )
                    ),
                    nnkElse.newTree(
                        nnkStmtList.newTree(
                            nnkRaiseStmt.newTree(
                                nnkCall.newTree(
                                    nnkDotExpr.newTree(
                                    newIdentNode("ValueError"),
                                    newIdentNode("newException")
                                    ),
                                    newLit(fmt"Invalid access index for {$type1}")
                                )
                            )
                        )
                    )
                )
            )
        )
    )


defineGetitem(Vector3)
defineGetitem(Point)
defineGetitem(Normal)

defineSetitem(Vector3)
defineSetitem(Point)
defineSetitem(Normal)

macro toString(type1: untyped): untyped=
    ## ToString method writes a type1 (with x,y,z components) as a string
    ## Called with $ operator
    ##
    ## Example: echo $newVector3(1,2,3)
    result = nnkStmtList.newTree(
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode("$")
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                newIdentNode("string"),
                nnkIdentDefs.newTree(
                    newIdentNode("this"),
                    newIdentNode($type1),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkReturnStmt.newTree(
                    nnkInfix.newTree(
                        newIdentNode("&"),
                        nnkPrefix.newTree(
                            newIdentNode("$"),
                            newIdentNode($type1)
                        ),
                        nnkInfix.newTree(
                            newIdentNode("%"),
                            newLit("($1,$2,$3)"),
                            nnkBracket.newTree(
                                nnkPrefix.newTree(
                                    newIdentNode("$"),
                                    nnkDotExpr.newTree(
                                    newIdentNode("this"),
                                    newIdentNode("x")
                                    )
                                ),
                                nnkPrefix.newTree(
                                    newIdentNode("$"),
                                    nnkDotExpr.newTree(
                                    newIdentNode("this"),
                                    newIdentNode("y")
                                    )
                                ),
                                nnkPrefix.newTree(
                                    newIdentNode("$"),
                                    nnkDotExpr.newTree(
                                    newIdentNode("this"),
                                    newIdentNode("z")
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )

toString(Vector3)      
toString(Point)  
toString(Normal)  


proc `[]`*(self: Vector2, index: int): float32=
    case index:
        of 0:
            return self.u
        of 1:
            return self.v
        else:
            raise ValueError.newException("Invalid index access for Vector2")

proc `[]=`*(self: var Vector2, index: int, val: float32): void=
    case index:
        of 0:
            self.u = val
        of 1:
            self.v = val
        else:
            raise ValueError.newException("Invalid index access for Vector2")

template definePermute(type1: typedesc)=
    proc Permute*(a: type1, x,y,z: int): type1=
        result.x = a[x]
        result.y = a[y]
        result.z = a[z]

definePermute(Vector3)
definePermute(Normal)
definePermute(Point)


## ----------------------------------------  Vector3 Specific  ----------------------------------------------
proc Dot*(_:typedesc[Vector3], this, other: Vector3): float32 {.inline.} = 
    ## Returns the dot product (float32) between two vectors.
    ## Static method
    ##
    ## Example: let dot = Vector3.Dot(newVector3(1,2,3), newVector3(4,5,6))
    result = this.x * other.x + this.y * other.y + this.z * other.z

macro defineDistance(type1: untyped): void =
    ## Define a distance between objects of type type1
    ## Use: Distance(pointA, pointB)
    nnkStmtList.newTree(
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                newIdentNode("Distance")
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                newIdentNode("float32"),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    newIdentNode("b"),
                    newIdentNode($type1),
                    newEmptyNode()
                )
            ),
            nnkPragma.newTree(
                newIdentNode("inline")
            ),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkLetSection.newTree(
                    nnkIdentDefs.newTree(
                        newIdentNode("diff_x"),
                        newEmptyNode(),
                        nnkInfix.newTree(
                            newIdentNode("-"),
                            nnkDotExpr.newTree(
                                newIdentNode("a"),
                                newIdentNode("x")
                            ),
                            nnkDotExpr.newTree(
                                newIdentNode("b"),
                                newIdentNode("x")
                            )
                        )
                    ),
                    nnkIdentDefs.newTree(
                        newIdentNode("diff_y"),
                        newEmptyNode(),
                        nnkInfix.newTree(
                                newIdentNode("-"),
                                nnkDotExpr.newTree(
                                newIdentNode("a"),
                                newIdentNode("y")
                            ),
                            nnkDotExpr.newTree(
                                newIdentNode("b"),
                                newIdentNode("y")
                            )
                        )
                    ),
                    nnkIdentDefs.newTree(
                        newIdentNode("diff_z"),
                        newEmptyNode(),
                        nnkInfix.newTree(
                            newIdentNode("-"),
                            nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("z")
                            ),
                            nnkDotExpr.newTree(
                            newIdentNode("b"),
                            newIdentNode("z")
                            )
                        )
                    )
                ),
                nnkAsgn.newTree(
                    newIdentNode("result"),
                    nnkCall.newTree(
                        newIdentNode("float32"),
                        nnkCall.newTree(
                            newIdentNode("sqrt"),
                            nnkInfix.newTree(
                                newIdentNode("+"),
                                nnkInfix.newTree(
                                    newIdentNode("+"),
                                    nnkInfix.newTree(
                                        newIdentNode("*"),
                                        newIdentNode("diff_x"),
                                        newIdentNode("diff_x")
                                    ),
                                    nnkInfix.newTree(
                                        newIdentNode("*"),
                                        newIdentNode("diff_y"),
                                        newIdentNode("diff_y")
                                    )
                                ),
                                nnkInfix.newTree(
                                    newIdentNode("*"),
                                    newIdentNode("diff_z"),
                                    newIdentNode("diff_z")
                                )
                            )
                        )
                    )
                )
            )
        )
    )

defineDistance(Vector3) # Vector3 distance if considered
defineDistance(Point) # Point has a distance from the origin


proc Cross*(_:typedesc[Vector3], this, other: Vector3): Vector3 {.inline.}=
    ## Returns the cross product (Vector3) between two vectors.
    ## Static method
    ##
    ## Example: let cross = Vector3.Cross(newVector3(1,2,3), newVector3(4,5,6))
    result.x = this.y * other.z - this.z * other.y
    result.y = this.z * other.x - this.x * other.z
    result.z = this.x * other.y - this.y * other.x

proc Angle*(_:typedesc[Vector3], a, b: Vector3, kEpsilonNormalSqrt: float32 = 1e-15): float32 {.inline.}=
    ## Computes the angle (float32) between two vectors.
    ## Static method
    ##
    ## Example: let angle = Vector3.Angle(newVector3(1,2,3), newVector3(4,5,6))
    var denominator: float32 = float(sqrt(a.square_norm() * b.square_norm()))
    if (denominator < kEpsilonNormalSqrt):
        return 0.0
    var dot: float32 = Dot(a, b) / denominator.clamp(-1.0, 1.0)
    return float(radToDeg(arccos(dot)))

proc Angle*(_: typedesc[Vector2], a,b: Vector2, kEpsilonNormalSqrt: float32 = 1-15): float32 {.inline.}=
    var denominator: float32 = float(sqrt(a.square_norm() * b.square_norm()))
    if (denominator < kEpsilonNormalSqrt):
        return 0.0
    var dot: float32 = Dot(a, b) / denominator.clamp(-1.0, 1.0)
    return float(radToDeg(arccos(dot)))

#template defineStaticDistance()

proc Slerp*(_: typedesc[Vector3], fromV, toV: Vector3, t: float32): Vector3=
    ## Gives the vector between fromV and toV at percentage t.

    
    # Dot product - the cosine of the angle between 2 vectors.
    var dot: float32 = Dot(fromV, toV)

    # Clamp it to be in the range of Acos()
    dot = clamp(dot, -1.0, 1.0)

    # Acos(dot) returns the angle between start and end,
    # And multiplying that by percent returns the angle between
    # start and the final result.
    var 
        theta: float32 = arccos(dot) * t
        relativeVec: Vector3 = toV - fromV * dot
    relativeVec.normalizeInplace()

    # Orthonormal basis
    return ((fromV*cos(theta)) + (relativeVec * sin(theta)));

proc radToDeg*(vec: Vector3): Vector3=
    result = newVector3(radToDeg(vec.x), radToDeg(vec.y), radToDeg(vec.z))

proc radToDeg*(vec: Vector2): Vector2=
    result = newVector2(radToDeg(vec.u), radToDeg(vec.v))

# base vectors
proc up*(_: typedesc[Vector3]): Vector3 {.inline.}=
    result = newVector3(0.0, 1.0, 0.0)
proc down*(_: typedesc[Vector3]): Vector3 {.inline.}=
    result = newVector3(0.0, -1.0, 0.0)
proc right*(_: typedesc[Vector3]): Vector3 {.inline.}=
    result = newVector3(1.0, 0.0, 0.0)
proc left*(_: typedesc[Vector3]): Vector3 {.inline.}=
    result = newVector3(-1.0, 0.0, 0.0)
proc forward*(_: typedesc[Vector3]): Vector3 {.inline.}=
    result = newVector3(0.0, 0.0, 1.0)
proc backward*(_: typedesc[Vector3]): Vector3 {.inline.}=
    result = newVector3(0.0, 0.0, -1.0)

proc right*(_: typedesc[Vector2]): Vector2 {.inline.}=
    result = newVector3(1.0, 0.0)
proc left*(_: typedesc[Vector2]): Vector2 {.inline.}=
    result = newVector3(-1.0, 0.0)
proc up*(_: typedesc[Vector2]): Vector2 {.inline.}=
    result = newVector3(0.0, 1.0)
proc down*(_: typedesc[Vector2]): Vector2 {.inline.}=
    result = newVector3(0.0, -1.0)