import neo
import std/[math, macros, typetraits, strformat, strutils]
import exception

type
    Vector* = object
        x*, y*, z*: float32

    Point* = object
        x*, y*, z*: float32
    
    Normal* = object
        x*, y*, z*: float32

## --------------------------------  CONSTRUCTORS  ------------------------------------------

macro defineEmptyConstructors(type1: typedesc): typed =
    let source = fmt"""
proc new{$type1}*(): {$type1} =
    result = {$type1}(x: 0.0, y: 0.0, z: 0.0)
"""
    result = parseStmt(source)

macro defineConstructors(type1: typedesc): typed =
    let source = fmt"""
proc new{$type1}*(x,y,z: float32): {$type1} =
    result = {$type1}(x: x, y: y, z: z)
"""
    result = parseStmt(source)

macro defineCopyConstructors(type1: typedesc): typed =
    let source = fmt"""
proc new{$type1}*(other: {$type1}): {$type1} =
    result = {$type1}(x: other.x, y: other.y, z: other.z)
"""
    result = parseStmt(source)

defineEmptyConstructors(Point)
defineEmptyConstructors(Vector)
defineEmptyConstructors(Normal)
defineConstructors(Point)
defineConstructors(Vector)
defineConstructors(Normal)
defineCopyConstructors(Point)
defineCopyConstructors(Vector)
defineCopyConstructors(Normal)


## --------------------------------  Sum + Subtraction  ------------------------------------------

template defineOperations(fname: untyped, type1: typedesc, type2: typedesc, rettype: typedesc) =
    proc fname*(a: type1, b: type2): rettype =
        result.x = fname(a.x, b.x)
        result.y = fname(a.y, b.y)
        result.z = fname(a.z, b.z)

defineOperations(`+`, Vector, Vector, Vector)
defineOperations(`-`, Vector, Vector, Vector)
defineOperations(`+`, Vector, Point, Point)
defineOperations(`-`, Vector, Point, Point)
defineOperations(`+`, Point, Vector, Point)
defineOperations(`-`, Point, Vector, Point)
defineOperations(`-`, Point, Point, Vector)
defineOperations(`+`, Normal, Normal, Normal)
defineOperations(`-`, Normal, Normal, Normal)

## ---------------------------------------  Products  ------------------------------------------

template defineProduct(type1: typedesc) =
    # Product with scalar
    proc `*`*(a: type1, b: float32): type1 =
        result.x = a.x * b
        result.y = a.y * b
        result.z = a.z * b

defineProduct(Vector)
defineProduct(Point)
defineProduct(Normal)

template defineDot(type1: typedesc, type2: typedesc) = 
    proc Dot*(this: type1, other: type2): float32 = 
        result = this.x * other.x + this.y * other.y + this.z * other.z
    
    proc `*`*(this: type1, other: type2): float32 = 
        result = this.Dot(other)

defineDot(Vector, Vector)
defineDot(Normal, Vector)
defineDot(Vector, Normal)


template defineCross(type1: typedesc, type2: typedesc, rettype: typedesc) =
    proc Cross*(this: type1, other: type2): rettype =
        result.x = this.y * other.z - this.z * other.y
        result.y = this.z * other.x - this.x * other.z
        result.z = this.x * other.y - this.y * other.x

defineCross(Vector, Vector, Vector)
defineCross(Normal, Vector, Vector)
defineCross(Vector, Normal, Vector)
defineCross(Normal, Normal, Vector)

## ----------------------------------------  Norm  ----------------------------------------------

template defineNorm(type1: typedesc)=
    proc squareNorm*(a: type1): float32=
        result = pow(a.x,2) + pow(a.y,2) + pow(a.z,2)
    proc norm*(a: type1): float32=
        result = sqrt(square_norm(a))
    
defineNorm(Vector)
defineNorm(Normal)

## ------------------------------------  Other operators  ---------------------------------------

template defineNormalize(type1: typedesc)=     #returns normalized Vector or Normal 
    proc normalize*(a: type1): type1=
        result.x = a.x/a.norm()
        result.y = a.y/a.norm()
        result.z = a.z/a.norm()

defineNormalize(Vector)
defineNormalize(Normal)

template defineNegative(type1: typedesc) =
    proc neg*(a: type1): type1 =
        result.x = -a.x
        result.y = -a.y
        result.z = -a.z

defineNegative(Vector)
defineNegative(Normal)

template defineConvert(type1: typedesc, rettype: typedesc) =
    proc convert*(a: type1): rettype =
        result.x = a.x
        result.y = a.y
        result.z = a.z

defineConvert(Vector, Normal)
defineConvert(Point, Vector)

proc IsEqual*(x,y: float32, epsilon:float32=1e-5): bool {.inline.}=
    return abs(x - y) < epsilon

template defineEqualities(type1: typedesc) =
    proc `==`*(this, other: type1): bool=
        return this.x == other.x and this.y == other.y and this.z == other.z
    
    proc `!=`*(this, other: type1): bool=
        return this.x != other.x or this.y != other.y or this.z != other.z

    proc isClose*(this, other: type1, eps: float32 = 1e-5): bool=
        return IsEqual(this.x, other.x, eps) and IsEqual(this.y, other.y, eps) and IsEqual(this.z, other.z, eps)

    proc isNotClose*(this, other: type1): bool=
        return not(IsEqual(this.x, other.x) or IsEqual(this.y, other.y) or IsEqual(this.z, other.z))

defineEqualities(Vector)
defineEqualities(Point)
defineEqualities(Normal)


macro defineGetitem(type1: untyped): untyped=
    ## Get item for variable of type type1 (with x,y,z components)
    ## Called through [] operator
    ## 
    ## Example:
    ## var v: Vector = newVector(1,2,3)
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
    ## var v: Vector = newVector(1,2,3)
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


defineGetitem(Vector)
defineGetitem(Point)
defineGetitem(Normal)

defineSetitem(Vector)
defineSetitem(Point)
defineSetitem(Normal)

macro toString(type1: untyped): untyped=
    ## ToString method writes a type1 (with x,y,z components) as a string
    ## Called with $ operator
    ##
    ## Example: echo $newVector(1,2,3)
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

toString(Vector)      
toString(Point)  
toString(Normal)  


## ----------------------------------------  Vector3 Specific  ----------------------------------------------
proc Dot*(_:typedesc[Vector], this, other: Vector): float32 {.inline.} = 
    ## Returns the dot product (float32) between two vectors.
    ## Static method
    ##
    ## Example: let dot = Vector.Dot(newVector(1,2,3), newVector(4,5,6))
    result = this.x * other.x + this.y * other.y + this.z * other.z

macro defineDistance(type1: untyped): void =
    ## Define a distance between objects of type type1
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

defineDistance(Vector) # Vector distance if considered
defineDistance(Point) # Point has a distance from the origin

proc Cross*(_:typedesc[Vector], this, other: Vector): Vector {.inline.}=
    ## Returns the cross product (Vector) between two vectors.
    ## Static method
    ##
    ## Example: let cross = Vector.Cross(newVector(1,2,3), newVector(4,5,6))
    result.x = this.y * other.z - this.z * other.y
    result.y = this.z * other.x - this.x * other.z
    result.z = this.x * other.y - this.y * other.x
    

proc Angle*(_:typedesc[Vector], a, b: Vector, kEpsilonNormalSqrt: float = 1e-15): float32 {.inline.}=
    ## Computes the angle (float32) between two vectors.
    ## Static method
    ##
    ## Example: let angle = Vector.Angle(newVector(1,2,3), newVector(4,5,6))
    var denominator: float32 = float(sqrt(a.square_norm() * b.square_norm()))
    if (denominator < kEpsilonNormalSqrt):
        return 0.0
    var dot: float32 = clamp(Vector.Dot(a, b) / denominator, -1.0 .. 1.0    );
    return float(radToDeg(arccos(dot)))

proc radToDeg*(v: Vector): Vector=
    result = newVector(radToDeg(v.x), radToDeg(v.y), radToDeg(v.z))

proc up*(_: typedesc[Vector]): Vector {.inline.}=
    result = newVector(0.0, 1.0, 0.0)
proc down*(_: typedesc[Vector]): Vector {.inline.}=
    result = newVector(0.0, -1.0, 0.0)
proc right*(_: typedesc[Vector]): Vector {.inline.}=
    result = newVector(1.0, 0.0, 0.0)
proc left*(_: typedesc[Vector]): Vector {.inline.}=
    result = newVector(-1.0, 0.0, 0.0)
proc forward*(_: typedesc[Vector]): Vector {.inline.}=
    result = newVector(0.0, 0.0, 1.0)
proc backward*(_: typedesc[Vector]): Vector {.inline.}=
    result = newVector(0.0, 0.0, -1.0)