import geometry, transformation

type
    Ray* = object
        origin*: Point
        dir*: Vector
        tmin*: float32 
        tmax*: float32 
        depth*: int 
    
proc newRay*(): Ray=
    result = Ray(
        origin: newPoint(0,0,0),
        dir: Vector.forward,
        tmin: 1e-10,
        tmax: Inf,
        depth:0
    )

proc newRay*(origin:Point, direction: Vector): Ray=
    result = Ray(
        origin: origin, 
        dir: direction, 
        tmin: 1e-10, 
        tmax: Inf, 
        depth: 0
    )

proc newRay*(origin:Point, direction: Vector, tmin: float32): Ray=
    assert tmin >= 0.0
    result = Ray(
        origin: origin, 
        dir: direction, 
        tmin: tmin, 
        tmax: Inf, 
        depth: 0
    )

proc newRay*(origin:Point, direction: Vector, tmin, tmax: float32, depth: int): Ray=
    assert tmin >= 0.0
    result = Ray(
        origin: origin, 
        dir: direction, 
        tmin: tmin, 
        tmax: tmax, 
        depth: depth
    )

proc newRay*(other: Ray): Ray=
    result = Ray(
        origin: other.origin, 
        dir: other.dir, 
        tmin: other.tmin, 
        tmax: other.tmax, 
        depth: other.depth
    )

proc isClose*(self, other: Ray, epsilon: float32 = 1e-5): bool {.inline.} = 
    ### To verify that two Rays have same origin and direction 
    return self.origin == other.origin and self.dir == other.dir 

proc at*(self: Ray, t: float32): Point =
    return self.origin + self.dir * t

proc `[]`*(self:Ray, t: float32): Point=
    return self.at(t)

proc Transform*(self: Ray, transformation: Transformation): Ray =
    result = Ray(
        origin : transformation * self.origin,
        dir : transformation * self.dir,
        tmin : self.tmin,
        tmax : self.tmax,
        depth : self.depth
    )
