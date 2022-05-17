import  geometry, ray#, shape

type
    RayHit* = object
        world_point*: Point
        normal*: Normal
        surface_point*: Vector2
        t*: float32
        ray*: Ray
        #hitshape*: Shape
# -------------------------------- Constructors -------------------------------------

proc newRayHit*(): RayHit=
    result = RayHit(
        world_point: newPoint(0.0, 0.0, 0.0),
        normal: newNormal(0.0, 0.0, 0.0),
        surface_point: newVector2(0.0, 0.0),
        t: 0.0,
        ray: newRay()
    )

proc newRayHit*(world_point: Point, normal: Normal, surface_point: Vector2, t: float32, ray: Ray): RayHit=
    result = RayHit(
        world_point: world_point,
        normal: normal,
        surface_point: surface_point,
        t: t,
        ray: ray
        #hitshape: hitshape
    )

# -------------------------------- Getters & Setters -------------------------------------

func GetPoint*(self: RayHit): Point=
    return self.world_point

func GetNormal*(self: RayHit): Normal=
    return self.normal

func GetSurfacePoint*(self: RayHit): Vector2=
    return self.surface_point

func GetDistance*(self: RayHit): float32=
    return self.t

# -------------------------------- Operators -------------------------------------

proc `==`*(self, other: RayHit): bool =
    ### To verify that two Vector2d are the same or not 
    return self.world_point == other.world_point and self.normal == other.normal and self.surface_point == other.surface_point and self.t == other.t and self.ray == other.ray

proc isClose*(self, other: RayHit): bool=
    ### To verify that two RayHit represent the same hit or not
    return self.world_point.isClose(other.world_point) and self.normal.isClose(other.normal) and self.surface_point.isClose(other.surface_point) and self.t.IsEqual(other.t) and self.ray.isClose(other.ray)