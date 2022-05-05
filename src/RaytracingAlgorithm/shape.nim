import geometry, transformation, rayhit, exception, ray, rayhit
import std/[math, typetraits, options, strutils, strformat]

type
    Shape* = ref object of RootObj
        id*: string
        origin*: Point
        transform*: Transformation
    
    Sphere* = ref object of Shape
        radius*: float32
    
    Plane* = ref object of Shape

## constructors

proc newSphere*(id: string = "SPHERE_0", origin: Point = newPoint(), radius: float32 = 1.0): Sphere =
    if not id.contains("SPHERE"):
        raise ValueError.newException("Sphere id must contain SPHERE keyword.")
    result = Sphere(id: id, origin: origin, radius: radius)

proc newSphere*(id: string = "SPHERE_0", transform: Transformation = newTransformation()): Sphere =
    if not id.contains("SPHERE"):
        raise ValueError.newException("Sphere id must contain SPHERE keyword.")
    result = Sphere(id: id, transform: transform)
    

proc newPlane*(id: string = "PLANE_0", origin: Point = newPoint(), transform: Transformation = newTransformation()): Plane =
    if not id.contains("PLANE"):
        raise ValueError.newException("Plane id must contain PLANE keyword.")
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
        u = arctan2(p.y, p.z) / (2.0 * PI)   #p.x non p.z
        v = arccos(p.z) / PI
    if u >= 0.0:
        result = newVector2(u,v)
    else:
        result = newVector2(u+1.0, v)

## ray intersection

method rayIntersect*(s: Shape, r: Ray, debug: bool = false): Option[RayHit] {.base, noSideEffect.}=
    raise AbstractMethodError.newException("Shape.ray_intersection is an abstract method and cannot be called.")

method rayIntersect*(s: Sphere, r: Ray, debug: bool = false): Option[RayHit]=
    var hit: RayHit = newRayHit()
    var
        firsthit_t: float32
        inversed_ray: Ray = r.Transform(s.transform.Inverse())
        origin_vec: Vector3 = inversed_ray.origin.convert(Vector3)

        a = inversed_ray.dir.squareNorm()
        b = 2.0 * origin_vec.Dot(inversed_ray.dir) 
        c = origin_vec.squareNorm() - 1
    
        delta = b * b - 4.0 * a * c
    if debug:
        echo "transform: ",s.transform
        echo "Inv: ",s.transform.Inverse()
        echo "Original Ray: ",r
        echo "Inversed Ray", inversed_ray
        echo "origin_vec: ",origin_vec
        echo fmt"a: {a}"
        echo fmt"b: {b}"
        echo fmt"c: {c}"

    if delta <= 0.0:
        return none(RayHit)

    let
        sqrt_delta = sqrt(delta)
        tmin = (- b - sqrt_delta) / (2.0 * a)
        tmax = (- b + sqrt_delta) / (2.0 * a)
    
    if debug:
        echo "sqrt_delta: ",sqrt_delta
        echo "tvals: ",tmin, " -- ",tmax
    
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
    result = some(hit)

method rayIntersect*(self: Plane, r: Ray): Option[RayHit] {.raises: [AbstractMethodError].}=
    raise AbstractMethodError.newException("Method is not yet implemented.")
    
        


            

    
