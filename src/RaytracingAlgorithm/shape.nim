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
    

proc newPlane*(id: string = "PLANE_0", origin: Point = newPoint(), transform: Transformation = newTransformation()): Plane =
    if not id.contains("PLANE"):
        raise ValueError.newException("Plane id must contain PLANE keyword.")
    result = Plane(id: id, origin: origin, transform: transform)

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

    if not s.aabb.RayIntersect(inversed_ray):
        return none(RayHit)

    var
        a = inversed_ray.dir.squareNorm()
        b = 2.0 * origin_vec.Dot(inversed_ray.dir) 
        c = origin_vec.squareNorm() - 1
    
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
    #hit.hitshape = s
    result = some(hit)

method rayIntersect*(self: Plane, r: Ray, debug: bool = false): Option[RayHit] {.raises: [NotImplementedError].} =
    raise NotImplementedError.newException("Plane.rayIntersect: function not yet implemented.")
        

    
