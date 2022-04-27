import geometry, transformation, rayhit, exception, ray, rayhit
import std/[segfaults, math, typetraits, options]

type
    Shape* = ref object of RootObj
        id*: string
        origin*: Vector3
        transform*: Transformation
    
    Sphere* = ref object of Shape
        radius*: float32
    
    Plane* = ref object of Shape

## constructors

proc newSphere*(id: string = "SPHERE_0", origin: Vector3 = newVector3(), radius: float32 = 1.0, transform: Transformation = newTransformation()): Sphere =
    result = Sphere(id: id, origin: origin, radius: radius, transform: transform)

proc newPlane*(id: string = "PLANE_0", origin: Vector3 = newVector3(), transform: Transformation = newTransformation()): Plane =
    result = Plane(id: id, origin: origin, transform: transform)


## private funcs
proc sphereNormal(p: Point, dir: Vector3): Normal= 
    var n: Normal = newNormal(p.x, p.y, p.z)
    if p.convert(Vector3).Dot(dir) < 0.0:
        return n
    else:
        return n.neg()

proc sphereWorldToLocal(p: Point): Vector2=
    let
        u = arctan2(p.y, p.z) / (2.0 * PI)
        v = arccos(p.z) / PI
    if u >= 0.0:
        result = newVector2(u,v)
    else:
        result = newVector2(u+1.0, v)

## ray intersection

method rayIntersect*(s: Shape, r: Ray): RayHit {.base, raises: [AbstractMethodError].}=
    raise AbstractMethodError.newException("Shape.ray_intersection is an abstract method and cannot be called.")

method rayIntersect*(s: Sphere, r: Ray): Option[RayHit] {.base.}=
    var hit: RayHit = newRayHit()
    var
        inversed_ray: Ray = r.Transform(s.transform)
        origin_vec: Vector3 = inversed_ray.origin.convert(Vector3)
    
    let
        a = r.dir.squareNorm()
        b = r.origin.Dot(inversed_ray.dir)
        c = r.origin.squareNorm() - 1
    
        delta = b * b - 4.0 * a * c

    if delta <= 0.0:
        return none(RayHit)

    let
        sqrt_delta = sqrt(delta)
        tmin = (- b - sqrt_delta) / (2.0 * a)
        tmax = (-b + sqrt_delta) / (2.0 * a)
    
    if (tmin > inversed_ray.tmin and tmin < inversed_ray.tmax):
        hit.t = tmin
    elif (tmax > inversed_ray.tmin and tmax < inversed_ray.tmax):
        hit.t = tmax
    else:
        return none(RayHit)

    let hitpoint = inversed_ray[hit.t]
    hit.world_point = s.transform * hitpoint
    hit.normal = s.transform * sphereNormal(hitpoint, inversed_ray.dir) 
    hit.surface_point = sphereWorldToLocal(hitpoint)
    hit.ray = r
    result = some(hit)

method rayIntersect*(self: Plane, r: Ray): RayHit {.raises: [AbstractMethodError].}=
    raise AbstractMethodError.newException("Method is not yet implemented.")
    
        


            

    
