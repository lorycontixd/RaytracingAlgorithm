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

## --- Constructors

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

## --- Sum & Subtraction

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

## --- Products

template define_product(type1: typedesc, type2: typedesc, rettype: typedesc) =
    proc `*`*(a: type1, b: type2): float32 =
        result = a.x * b.x + a.y * b.y + a.z * b.z



## --- Norm

template define_norm(type1: typedesc)=
    proc norm*(a: type1): float32=
        result = sqrt(pow(a.x,2) + pow(a.y,2) + pow(a.z,2))
    
define_norm(Vector)
define_norm(Point)

