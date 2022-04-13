import geometry, transformation

type
    Ray* = object
        origin*: Point
        dir*: Vector
        tmin*: float32 
        tmax*: float32 
        depth*: int 

proc NewRay*(self: Ray): Ray=
    result = Ray(
        origin: self.origin, 
        dir: self.dir, 
        tmin: 1e-10, 
        tmax: Inf, 
        depth: 0
        )

proc is_close*(self, other: Ray, epsilon: float32 = 1e-5): bool {.inline.} =  
    return self.origin == other.origin and self.dir == other.dir 

proc at*(self: Ray, t: float32): Point =
    return self.origin + self.dir * t

proc transform(self: Ray, transformation: Transformation): Ray =
    result = Ray(
        origin : transformation * self.origin,
        dir : transformation * self.dir,
        tmin : self.tmin,
        tmax : self.tmax,
        depth : self.depth
    )