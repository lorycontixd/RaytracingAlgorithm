import geometry, ray, material#, shape
from utils import IsEqual

type
    RayHit* = object # class for intersections between a ray and a shape
        world_point*: Point # point of world hit by ray
        normal*: Normal # normal of the surface hit
        surface_point*: Vector2 # position of the hit point on the surface of the object
        t*: float32 # distance of the hit from the origin of the ray
        ray*: Ray # ray hitting the surface
        material*: Material # surface material
        #hitshape*: Shape
# -------------------------------- Constructors -------------------------------------

proc newRayHit*(): RayHit=
    ## constructor for RayHit
    ## Parameters
    ##      /
    ## Returns
    ##      (RayHit) : a ray hitting the surface object in the origin of the world
    result = RayHit(
        world_point: newPoint(0.0, 0.0, 0.0),
        normal: newNormal(0.0, 0.0, 0.0),
        surface_point: newVector2(0.0, 0.0),
        t: 0.0,
        ray: newRay()
    )

proc newRayHit*(world_point: Point, normal: Normal, surface_point: Vector2, t: float32, ray: Ray, mat: Material): RayHit=
    ## constructor for RayHit
    ## Parameters
    ##       world_point (Point) : point of world hit by ray
    ##       normal (Normal) : normal of the surface hit
    ##       surface_point (Vector2) : position of the hit point on the surface of the object
    ##       t (float32) : distance of the hit from the origin of the ray
    ##       ray (Ray) : ray hitting the surface
    ##       mat (Material) : surface material
    ## Results
    ##      (RayHit)
    result = RayHit(
        world_point: world_point,
        normal: normal,
        surface_point: surface_point,
        t: t,
        ray: ray,
        material: mat
    )

# -------------------------------- Getters & Setters -------------------------------------

func GetPoint*(self: RayHit): Point=
    ## Returns the point of world hit by ray
    ## Parameters
    ##      self (RayHit): rayhit object
    ## Returns
    ##      world_point (Point): world point hit by ray  
    return self.world_point

func GetNormal*(self: RayHit): Normal=
    ## Returns the normal to the surface hit by ray
    ## Parameters
    ##      self (RayHit): rayhit object
    ## Returns
    ##      normal (Normal): normal of the surface hit by ray  
    return self.normal

func GetSurfacePoint*(self: RayHit): Vector2=
    ## Returns the point of the surface hit by ray
    ## Parameters
    ##      self (RayHit): rayhit object
    ## Returns
    ##      surface_point (Vector2): surface point hit by ray  
    return self.surface_point

func GetDistance*(self: RayHit): float32=
    ## Returns the distance of the hit from the origin of the ray
    ## Parameters
    ##      self (RayHit): rayhit object
    ## Returns
    ##      t (float): distance run by the ray before the hit 
    return self.t

# -------------------------------- Operators -------------------------------------

proc `==`*(self, other: RayHit): bool =
    ## Verifies whether two RayHit are the same or not 
    ## Parameters
    ##      self, other (RayHit): rayhit to be checked
    ## Returns
    ##      (bool): True (the two RayHit are the same) , False (else)
    return self.world_point == other.world_point and self.normal == other.normal and self.surface_point == other.surface_point and self.t == other.t and self.ray == other.ray

proc isClose*(self, other: RayHit): bool=
    ## Verifies whether two RayHit represent the same hit or not
    ## ## Parameters
    ##      self, other (RayHit): rayhit to be checked
    ## Returns
    ##      (bool): True (the two RayHit are close) , False (else)
    return self.world_point.isClose(other.world_point) and self.normal.isClose(other.normal) and self.surface_point.isClose(other.surface_point) and self.t.IsEqual(other.t) and self.ray.isClose(other.ray)