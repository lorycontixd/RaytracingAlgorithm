import neo
import std/[math, macros, typetraits, strformat, strutils]
import exception

type
    Vector3* = object
        x*, y*, z*: float32

    Vector2* = object
        u*, v*: float32

    Point* = object
        x*, y*, z*: float32
    
    Normal* = object
        x*, y*, z*: float32

## --------------------------------  CONSTRUCTORS  ------------------------------------------

macro defineEmptyConstructors(type1: typedesc): void =
    let source = fmt"""
proc new{$type1}*(): {$type1} =
    result = {$type1}(x: 0.0, y: 0.0, z: 0.0)
"""
    result = parseStmt(source)

proc newVector2*(): Vector2=
    result = Vector2(u: 0.0, v: 0.0)

macro defineConstructors(type1: typedesc): void =
    let source = fmt"""
proc new{$type1}*(x,y,z: float32): {$type1} =
    result = {$type1}(x: x, y: y, z: z)
"""
    result = parseStmt(source)

proc newVector2*(u,v: float32): Vector2=
    result = Vector2(u: u, v: v)

macro defineCopyConstructors(type1: typedesc): void =
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
define_copy_constructors(Point)
define_copy_constructors(Vector3)
define_copy_constructors(Normal)


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
defineOperations(`-`, Point, Point, Vector3)
defineOperations(`+`, Normal, Normal, Normal)
defineOperations(`-`, Normal, Normal, Normal)

## ---------------------------------------  Products  ------------------------------------------

template define_product(type1: typedesc) =
    # Product with scalar
    proc `*`*(a: type1, b: float32): type1 =
        result.x = a.x * b
        result.y = a.y * b
        result.z = a.z * b

define_product(Vector3)
define_product(Point)
define_product(Normal)

template define_dot(type1: typedesc, type2: typedesc) = 
    proc Dot*(this: type1, other: type2): float32 = 
        result = this.x * other.x + this.y * other.y + this.z * other.z
    
    proc `*`*(this: type1, other: type2): float32 = 
        result = this.Dot(other)

define_dot(Vector3, Vector3)
define_dot(Normal, Vector3)
define_dot(Vector3, Normal)


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
defineNorm(Normal)

## ------------------------------------  Other operators  ---------------------------------------

template defineNormalize(type1: typedesc)=     #returns normalized Vector3 or Normal 
    proc normalize*(a: type1): type1=
        result.x = a.x/a.norm()
        result.y = a.y/a.norm()
        result.z = a.z/a.norm()

defineNormalize(Vector3)
defineNormalize(Normal)

template defineNegative(type1: typedesc) =
    proc neg*(a: type1): type1 =
        result.x = -a.x
        result.y = -a.y
        result.z = -a.z

defineNegative(Vector3)
defineNegative(Normal)

template defineConvert(type1: typedesc, rettype: typedesc) =
    proc convert*(a: type1): rettype =
        result.x = a.x
        result.y = a.y
        result.z = a.z

defineConvert(Vector3, Normal)
defineConvert(Point, Vector3)

proc IsEqual*(x,y: float32, epsilon:float32=1e-5): bool {.inline.}=
    return abs(x - y) < epsilon

template defineEqualities(type1: typedesc) =
    proc `==`*(this, other: type1): bool=
        return IsEqual(this.x, other.x) and IsEqual(this.y, other.y) and IsEqual(this.z, other.z)
    
    proc `!=`*(this, other: type1): bool=
        return not(IsEqual(this.x, other.x) and IsEqual(this.y, other.y) and IsEqual(this.z, other.z))

defineEqualities(Vector3)
defineEqualities(Point)
defineEqualities(Normal)


macro defineGetitem(type1: untyped): untyped=
    ## Get item for variable of type type1 (with x,y,z components)
    ## Called through [] operator
    ## 
    ## Example:
    ## var v: Vector3 = newVector(1,2,3)
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
    ## var v: Vector3 = newVector(1,2,3)
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

toString(Vector3)      
toString(Point)  
toString(Normal)  


## ----------------------------------------  Vector3 Specific  ----------------------------------------------
proc Dot*(_:typedesc[Vector3], this, other: Vector3): float32 {.inline.} = 
    ## Returns the dot product (float32) between two vectors.
    ## Static method
    ##
    ## Example: let dot = Vector3.Dot(newVector(1,2,3), newVector(4,5,6))
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

defineDistance(Vector3) # Vector3 distance if considered
defineDistance(Point) # Point has a distance from the origin

proc Cross*(_:typedesc[Vector3], this, other: Vector3): Vector3 {.inline.}=
    ## Returns the cross product (Vector3) between two vectors.
    ## Static method
    ##
    ## Example: let cross = Vector3.Cross(newVector(1,2,3), newVector(4,5,6))
    result.x = this.y * other.z - this.z * other.y
    result.y = this.z * other.x - this.x * other.z
    result.z = this.x * other.y - this.y * other.x
    

proc Angle*(_:typedesc[Vector3], a, b: Vector3, kEpsilonNormalSqrt: float = 1e-15): float32 {.inline.}=
    ## Computes the angle (float32) between two vectors.
    ## Static method
    ##
    ## Example: let angle = Vector3.Angle(newVector(1,2,3), newVector(4,5,6))
    raise NotImplementedError.newException("Not yet implemented: Angle")
    var denominator: float32 = float(sqrt(a.square_norm() * b.square_norm()))
    if (denominator < kEpsilonNormalSqrt):
        return 0.0
    var dot: float32 = clamp(Vector3.Dot(a, b) / denominator, -1.0 .. 1.0    );
    return float(arccos(dot)) * radToDeg