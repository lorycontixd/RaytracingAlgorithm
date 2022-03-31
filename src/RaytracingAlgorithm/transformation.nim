import geometry, utils
import neo

type
    Vector = geometry.Vector
    Transformation* = object
        m*, inverse*: Matrix[float32]

proc newTransormation*(): Transformation=
    result = Transformation(m:eye(4, float32), inverse:eye(4, float32))    #identity matrix


proc inverse*(t: Transformation): Transformation=
    result = Transformation(m:t.inverse, inverse:t.m)

template define_dot(type1: typedesc)=  
    proc `*`*(t: Transformation, other: type1): type1=
        if (type1 = V)
        let vec = t.m * other.v    #product matrix*vector 
        assert size(vec) == 4
        result = type1(x: vec[0], y:vec[1], z:vec[2])     #assign elements of vec to our class type

define_dot(Vector)
define_dot(Point)
define_dot(Normal)

proc translation*(_: typedesc[Transformation], vector: Vector): Transformation=
    result = newTransormation()
    result.m = matrix(@[
        @[1.0, 0.0, 0.0, vector.x],
        @[0.0, 1.0, 0.0, vector.y],
        @[0.0, 0.0, 1.0, vector.z],
        @[0.0, 0.0, 0.0, 1.0],
    ])
    result.inverse = matrix(@[
        @[1.0, 0.0, 0.0, -vector.x],
        @[0.0, 1.0, 0.0, -vector.y],
        @[0.0, 0.0, 1.0, -vector.z],
        @[0.0, 0.0, 0.0, 1.0],
    ])


