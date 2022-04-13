import geometry, transformation

type
    Ray* = object
        origin*: Point
        dir*: Vector
        tmin*: float32 
        tmax*: float32 
        depth*: int 

proc NewRay*(origin: Point, dir: Vector): Ray=
    result = Ray(
        origin: origin, 
        dir: dir, 
        tmin: 1e-10, 
        tmax: Inf, 
        depth: 0
        )

proc is_close*(self, other: Ray, epsilon: float32 = 1e-5): bool {.inline.} = 
    ### To verify that two Rays have same origin and direction 
    return self.origin == other.origin and self.dir == other.dir 

proc at*(self: Ray, t: float32): Point =
    return self.origin + self.dir * t

proc transform(self: Ray, transformation: Transformation): Ray =
    ### Transforms a ray: returns a new Ray whose origin and direction are the transformation of the original ones
    result = Ray(
        origin : transformation * self.origin,
        dir : transformation * self.dir,
        tmin : self.tmin,
        tmax : self.tmax,
        depth : self.depth
    )