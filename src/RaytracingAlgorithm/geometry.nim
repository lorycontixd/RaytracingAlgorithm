import neo
import std/[math, macros, typetraits, strformat]

type
    Vector* = object
        x*, y*, z*: float32

    Point* = object
        x*, y*, z*: float32
    
    Normal* = object
        x*, y*, z*: float32

    Transformation* = object
        m*, inverse*: Matrix[float32]

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
define_operations(`+`, Normal, Normal, Normal)
define_operations(`-`, Normal, Normal, Normal)

## ---------------------------------------  Products  ------------------------------------------

template define_product(type1: typedesc) =
    # Cross
    proc `*`*(a: type1, b: float32): type1 =
        result.x = a.x * b
        result.y = a.y * b
        result.z = a.z * b

define_product(Vector)
define_product(Point)
define_product(Normal)

proc dot*(this, other: Vector): float32 {.inline.} = 
    result = this.x * other.x + this.y * other.y + this.z * other.z

proc `*`*(this, other: Vector): float32 {.inline.} =
    result = this.dot(other)

proc cross*(this, other: Vector): Vector {.inline.}=
    result.x = this.y * other.z - this.z * other.y
    result.y = this.z * other.x - this.x * other.z
    result.z = this.x * other.y - this.y * other.x

## ------------------------------------  Other operators  ---------------------------------------
template define_equalities(type1: typedesc) =
    proc IsEqual*(x,y: float32, epsilon:float32=1e-5): bool {.inline.}=
        return abs(x - y) < epsilon

    proc `==`*(this, other: type1): bool=
        return IsEqual(this.x, other.x) and IsEqual(this.y, other.y) and IsEqual(this.z, other.z)
    
    proc `!=`*(this, other: type1): bool=
        return not this == other

template define_getitem(type1: typedesc) =
    proc `[]`*(this: type1, index: int): float32 {.inline.}=
        case index:
        of 0:
            return this.x
        of 1:
            return this.y
        of 2:
            return this.z
        else:
            # raise
            return

template define_setitem(type1: typedesc) =
    proc `[]=`* (this:type1, index: int, value: float32) =
        # setter
        case index
        of 0:
            this.x = value
        of 1:
            this.y = value
        of 2: 
            this.z = value
        else:
            # raise
            return
    
    proc set*(this:type1, index: int, value: float32) =
        this[index] = value

define_equalities(Vector)
define_equalities(Point)
define_equalities(Normal)

define_getitem(Vector)
define_getitem(Point)
define_getitem(Normal)

define_setitem(Vector)
define_setitem(Point)
define_setitem(Normal)

#[
macro define_tostring(type1: typedesc): typed=
    let source = fmt"""
proc `$`*(this: {$type1}): string =
    result = {$this} & "(fmt""
"""
        result = parseStmt(source)
]#    
## ----------------------------------------  Norm  ----------------------------------------------

template define_norm(type1: typedesc)=
    proc square_norm*(a: type1): float32=
        result = pow(a.x,2) + pow(a.y,2) + pow(a.z,2)
    proc norm*(a: type1): float32=
        result = sqrt(square_norm(a))
    
define_norm(Vector)
define_norm(Point)

