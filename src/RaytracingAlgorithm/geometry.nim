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

macro define_empty_constructors(type1: typedesc): typed =
    let source = fmt"""
proc new{$type1}*(): {$type1} =
    result = {$type1}(x: 0.0, y: 0.0, z: 0.0)
"""
    result = parseStmt(source)

macro define_constructors(type1: typedesc): typed =
    let source = fmt"""
proc new{$type1}*(x,y,z: float32): {$type1} =
    result = {$type1}(x: x, y: y, z: z)
"""
    result = parseStmt(source)

macro define_copy_constructors(type1: typedesc): typed =
    let source = fmt"""
proc new{$type1}*(other: {$type1}): {$type1} =
    result = {$type1}(x: other.x, y: other.y, z: other.z)
"""
    result = parseStmt(source)

define_empty_constructors(Point)
define_empty_constructors(Vector)
define_empty_constructors(Normal)
define_constructors(Point)
define_constructors(Vector)
define_constructors(Normal)
define_copy_constructors(Point)
define_copy_constructors(Vector)
define_copy_constructors(Normal)


## --------------------------------  Sum + Subtraction  ------------------------------------------

template define_operations(fname: untyped, type1: typedesc, type2: typedesc, rettype: typedesc) =
    proc fname*(a: type1, b: type2): rettype =
        result.x = fname(a.x, b.x)
        result.y = fname(a.y, b.y)
        result.z = fname(a.z, b.z)

define_operations(`+`, Vector, Vector, Vector)
define_operations(`-`, Vector, Vector, Vector)
define_operations(`+`, Vector, Point, Point)
define_operations(`-`, Vector, Point, Point)
define_operations(`+`, Point, Vector, Point)
define_operations(`-`, Point, Vector, Point)
define_operations(`-`, Point, Point, Vector)
define_operations(`+`, Normal, Normal, Normal)
define_operations(`-`, Normal, Normal, Normal)

## ---------------------------------------  Products  ------------------------------------------

template define_product(type1: typedesc) =
    # Product with scalar
    proc `*`*(a: type1, b: float32): type1 =
        result.x = a.x * b
        result.y = a.y * b
        result.z = a.z * b

define_product(Vector)
define_product(Point)
define_product(Normal)

template define_dot(type1: typedesc, type2: typedesc) = 
    proc Dot*(this: type1, other: type2): float32 = 
        result = this.x * other.x + this.y * other.y + this.z * other.z
    
    proc `*`*(this: type1, other: type2): float32 = 
        result = this.Dot(other)

define_dot(Vector, Vector)
define_dot(Normal, Vector)
define_dot(Vector, Normal)


template define_cross(type1: typedesc, type2: typedesc, rettype: typedesc) =
    proc Cross*(this: type1, other: type2): rettype =
        result.x = this.y * other.z - this.z * other.y
        result.y = this.z * other.x - this.x * other.z
        result.z = this.x * other.y - this.y * other.x

define_cross(Vector, Vector, Vector)
define_cross(Normal, Vector, Vector)
define_cross(Vector, Normal, Vector)
define_cross(Normal, Normal, Vector)

## ----------------------------------------  Norm  ----------------------------------------------

template define_norm(type1: typedesc)=
    proc square_norm*(a: type1): float32=
        result = pow(a.x,2) + pow(a.y,2) + pow(a.z,2)
    proc norm*(a: type1): float32=
        result = sqrt(square_norm(a))
    
define_norm(Vector)
define_norm(Normal)

## ------------------------------------  Other operators  ---------------------------------------

template define_normalize(type1: typedesc)=     #returns normalized Vector or Normal 
    proc normalize*(a: type1): type1=
        result.x = result.x/a.norm()
        result.y = result.y/a.norm()
        result.z = result.z/a.norm()

define_normalize(Vector)
define_normalize(Normal)

template define_negative(type1: typedesc) =
    proc neg*(a: type1): type1 =
        result.x = -a.x
        result.y = -a.y
        result.z = -a.z

define_negative(Vector)
define_negative(Normal)

template define_convert(type1: typedesc, rettype: typedesc) =
    proc convert*(a: type1): rettype =
        result.x = a.x
        result.y = a.y
        result.z = a.z

define_convert(Vector, Normal)
define_convert(Point, Vector)

proc IsEqual*(x,y: float32, epsilon:float32=1e-5): bool {.inline.}=
    return abs(x - y) < epsilon

template define_equalities(type1: typedesc) =
    proc `==`*(this, other: type1): bool=
        return IsEqual(this.x, other.x) and IsEqual(this.y, other.y) and IsEqual(this.z, other.z)
    
    proc `!=`*(this, other: type1): bool=
        return not(IsEqual(this.x, other.x) and IsEqual(this.y, other.y) and IsEqual(this.z, other.z))


macro define_getitem(type1: untyped): untyped=
    ## Get item for variable of type type1
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


macro define_setitem(type1: untyped): untyped=
    ## Set item for variable of type type1
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

define_equalities(Vector)
define_equalities(Point)
define_equalities(Normal)

define_getitem(Vector)
define_getitem(Point)
define_getitem(Normal)

define_setitem(Vector)
define_setitem(Point)
define_setitem(Normal)

macro tostring(type1: untyped): untyped=
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

tostring(Vector)      
tostring(Point)  
tostring(Normal)  


## ----------------------------------------  Vector3 Specific  ----------------------------------------------
proc Dot*(_:typedesc[Vector], this, other: Vector): float32 {.inline.} = 
    result = this.x * other.x + this.y * other.y + this.z * other.z

proc Cross*(_:typedesc[Vector], this, other: Vector): Vector {.inline.}=
    result.x = this.y * other.z - this.z * other.y
    result.y = this.z * other.x - this.x * other.z
    result.z = this.x * other.y - this.y * other.x

proc Distance*(_:typedesc[Vector], a,b: Vector): float32 {.inline.}=
    let
        diff_x = a.x - b.x
        diff_y = a.y - b.y
        diff_z = a.z - b.z
    result = float(sqrt(diff_x * diff_x + diff_y * diff_y + diff_z * diff_z))

proc Angle*(_:typedesc[Vector], a, b: Vector, kEpsilonNormalSqrt: float = 1e-15): float32 {.inline.}=
    raise NotImplementedError.newException("Not yet implemented: Angle")
    var denominator: float32 = float(sqrt(a.square_norm() * b.square_norm()))
    if (denominator < kEpsilonNormalSqrt):
        return 0.0
    var dot: float32 = clamp(Vector.Dot(a, b) / denominator, -1.0 .. 1.0    );
    return float(arccos(dot)) * radToDeg