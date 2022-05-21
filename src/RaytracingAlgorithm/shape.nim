import geometry, transformation, rayhit, exception, ray, material, aabb, matrix
import std/[math, options, strutils]


type
    Shape* = ref object of RootObj
        id*: string
        origin*: Point
        transform*: Transformation
        material*: Material
        aabb*: AABB
    
    Sphere* = ref object of Shape
        radius*: float32
    
    Plane* = ref object of Shape

    Cylinder* = ref object of Shape
        radius*: float32
        height*: float32


# -------------------------------- Constructors -------------------------------------

proc newSphere*(id: string, origin: Point, radius: float32 ): Sphere =
    if not id.contains("SPHERE"):
        raise ValueError.newException("Sphere id must contain SPHERE keyword.")
    result = Sphere(id: id, origin: origin, radius: radius)

proc newSphere*(id: string = "SPHERE_0", transform: Transformation = newTransformation(), material: Material = newMaterial()): Sphere =
    if not id.contains("SPHERE"):
        raise ValueError.newException("Sphere id must contain SPHERE keyword.")
    let o = ExtractTranslation(transform.m).convert(Point)
    let scaling = ExtractScale(transform.m)
    if scaling[0][0] != scaling[1][1] or scaling[1][1] != scaling[2][2]:
        raise NotImplementedError.newException("Asymmetrical spheres have not yet been implemented!")
    let radius = scaling[0][0]
    result = Sphere(id: id, transform: transform, material: material, origin: o, radius: radius, aabb: newAABB(newPoint(o.x-radius, o.y-radius, o.z-radius), newPoint( o.x+radius, o.y+radius, o.z+radius)))
    
proc newPlane*(id: string = "PLANE_0", transform: Transformation = newTransformation(), material: Material = newMaterial()): Plane =
    if not id.contains("PLANE"):
        raise ValueError.newException("Plane id must contain PLANE keyword.")
    result = Plane(id: id, transform: transform, material: material, origin: ExtractTranslation(transform.m).convert(Point))

proc newCylinder*(id: string = "CYLINDER_0", transform: Transformation, material: Material = newMaterial()): Cylinder=
    if not id.contains("CYLINDER"):
        raise ValueError.newException("Cylinder id must contain CYLINDER keyword.")
    result = Cylinder(id: id, transform: transform, material: material, aabb: newAABB(newPoint(), newPoint()))
# -------------------------------------- Private methods ------------------------------------
proc sphereNormal(p: Point, dir: Vector3): Normal= 
    var n: Normal = newNormal(p.x, p.y, p.z)
    if p.convert(Vector3).Dot(dir) < 0.0:
        return n
    else:
        return n.neg()

proc sphereWorldToLocal(p: Point): Vector2=
    let
        u = arctan2(p.y, p.z) / (2.0 * PI)   #p.x not p.z ??
        v = arccos(p.z) / PI ## divided by radius ??
    if u >= 0.0:
        result = newVector2(u,v)
    else:
        result = newVector2(u+1.0, v)

proc cylinderWorldToLocal(p: Point): Vector2 =
    let
        u = arctan2(p.y, p.z) / (2.0 * PI)   #p.x not p.z ??
        v = arccos(p.z) / PI ## divided by radius ??
    if u >= 0.0:
        result = newVector2(u,v)
    else:
        result = newVector2(u+1.0, v)

###### --------------------------------------------- Methods --------------------------------------------


#####  ---- Ray Intersection
method rayIntersect*(s: Shape, r: Ray, debug: bool = false): Option[RayHit] {.base.}=
    ## Abstract method for shape.rayIntersect which computes the intersection between a ray and the shape.
    ## This is an abstract method, do not call it directly.
    raise AbstractMethodError.newException("Shape.ray_intersection is an abstract method and cannot be called.")

method rayIntersect*(s: Sphere, r: Ray, debug: bool = false): Option[RayHit] {.gcsafe.} =
    var hit: RayHit = newRayHit()
    var
        firsthit_t: float32
        inversed_ray: Ray = r.Transform(s.transform.Inverse())
        origin_vec: Vector3 = inversed_ray.origin.convert(Vector3)

    var
        a = inversed_ray.dir.squareNorm()
        b = 2.0 * origin_vec.Dot(inversed_ray.dir) 
        c = origin_vec.squareNorm() - s.radius * s.radius
    
        delta = b * b - 4.0 * a * c

    if delta <= 0.0:
        return none(RayHit)

    let
        sqrt_delta = sqrt(delta)
        tmin = (- b - sqrt_delta) / (2.0 * a)
        tmax = (- b + sqrt_delta) / (2.0 * a)

    
    if (tmin > inversed_ray.tmin and tmin < inversed_ray.tmax):
        firsthit_t = tmin
    elif (tmax > inversed_ray.tmin and tmax < inversed_ray.tmax):
        firsthit_t = tmax
    else:
        return none(RayHit)

    let hitpoint = inversed_ray[firsthit_t]
    hit.world_point = s.transform * hitpoint
    hit.t = firsthit_t
    hit.normal = s.transform * sphereNormal(hitpoint, inversed_ray.dir) 
    hit.surface_point = sphereWorldToLocal(hitpoint)
    hit.ray = r
    hit.material = s.material
    #hit.hitshape = s
    result = some(hit)

method rayIntersect*(self: Plane, ray: Ray, debug: bool = false): Option[RayHit] =
    let inv_ray = ray.Transform(Inverse(self.transform))
    if abs(inv_ray.dir.z) < 1e-5:
        return none(RayHit)

    let t = -inv_ray.origin.z / inv_ray.dir.z

    if (t <= inv_ray.tmin) or (t >= inv_ray.tmax):
        return none(RayHit)

    let hit_point = inv_ray.at(t)

    var normalZ: float32
    if inv_ray.dir.z < 0.0:
        normalZ = float32(1.0)
    else:
        normalZ = float32(-1.0)

    return some(newRayHit(
        self.transform * hit_point,
        self.transform * newNormal(0.0, 0.0, normalZ),
        newVector2(hit_point.x - floor(hit_point.x), hit_point.y - floor(hit_point.y)),
        t,
        ray,
        self.material,
    ))


method rayIntersect*(self: Cylinder, ray: Ray, debug: bool = false): Option[RayHit] =
    var hit: RayHit = newRayHit()
    var
        firsthit_t: float32
        inversed_ray: Ray = ray.Transform(self.transform.Inverse())
        origin_vec: Vector3 = inversed_ray.origin.convert(Vector3)

    #if not s.aabb.RayIntersect(inversed_ray):
    #    return none(RayHit)

    var
        a = pow(inversed_ray.dir.x,2.0) 
        b = 2.0 * (inversed_ray.dir.x * origin_vec.x + inversed_ray.dir.y * origin_vec.y)
        c = pow(origin_vec.x, 2.0) + pow(origin_vec.y, 2.0) - 1 # - radius ^ 2
        delta = b * b - 4.0 * a * c

    if delta <= 0.0:
        return none(RayHit)

    let
        sqrt_delta = sqrt(delta)
        tmin = (- b - sqrt_delta) / (2.0 * a)
        tmax = (- b + sqrt_delta) / (2.0 * a)

    if (tmin > inversed_ray.tmin and tmin < inversed_ray.tmax):
        firsthit_t = tmin
    elif (tmax > inversed_ray.tmin and tmax < inversed_ray.tmax):
        firsthit_t = tmax
    else:
        return none(RayHit)

    let hitpoint = inversed_ray[firsthit_t]
    hit.world_point = self.transform * hitpoint
    hit.t = firsthit_t
    #hit.normal = self.transform * sphereNormal(hitpoint, inversed_ray.dir) 
    hit.surface_point = cylinderWorldToLocal(hitpoint)
    hit.ray = ray
    hit.material = self.material
    #hit.hitshape = s
    result = some(hit)