import geometry, transformation

type
    Ray* = object
        origin*: Point
        dir*: Vector3
        tmin*: float32 
        tmax*: float32 
        depth*: int 
    
proc newRay*(): Ray=
    result = Ray(
        origin: newPoint(0,0,0),
        dir: Vector3.forward(),
        tmin: 1e-10,
        tmax: Inf,
        depth:0
    )

proc newRay*(origin:Point, direction: Vector3): Ray=
    result = Ray(
        origin: origin, 
        dir: direction, 
        tmin: 1e-10, 
        tmax: Inf, 
        depth: 0
    )

proc newRay*(origin:Point, direction: Vector3, tmin: float32): Ray=
    assert tmin >= 0.0
    result = Ray(
        origin: origin, 
        dir: direction, 
        tmin: tmin, 
        tmax: Inf, 
        depth: 0
    )

proc newRay*(origin:Point, direction: Vector3, tmin, tmax: float32, depth: int): Ray=
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

proc at*(self: Ray, t: float32): Point =
    return self.origin + self.dir * t

proc `[]`*(self:Ray, t: float32): Point=
    return self.at(t)

proc `==`*(self, other: Ray): bool=
    return self.origin == other.origin and self.dir == other.dir and self.tmin == other.tmin and self.tmax == other.tmax and self.depth == other.depth

proc `isClose`*(self, other: Ray, epsilon: float32 = 1e-4): bool=
    if self.tmax != Inf and other.tmax != Inf:
        return self.origin.isClose(other.origin, epsilon) and self.dir.isClose(other.dir, epsilon) and self.tmin.IsEqual(other.tmin, epsilon) and self.tmax.IsEqual(other.tmax, epsilon) and self.depth == other.depth
    else:
        return self.origin.isClose(other.origin, epsilon) and self.dir.isClose(other.dir, epsilon) and self.tmin.IsEqual(other.tmin, epsilon) and self.depth == other.depth
proc Transform*(self: Ray, transformation: Transformation): Ray =
    result = Ray(
        origin : transformation * self.origin,
        dir : transformation * self.dir,
        tmin : self.tmin,
        tmax : self.tmax,
        depth : self.depth
    )
