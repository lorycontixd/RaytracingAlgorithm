import geometry, transformation, rayhit, exception, ray, rayhit
import std/[math, typetraits, options, strutils]

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
    if not id.contains("SPHERE"):
        raise ValueError.newException("Sphere id must contain SPHERE keyword.")
    result = Sphere(id: id, origin: origin, radius: radius, transform: transform)

proc newPlane*(id: string = "PLANE_0", origin: Vector3 = newVector3(), transform: Transformation = newTransformation()): Plane =
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

method rayIntersect*(s: Shape, r: Ray): Option[RayHit] {.base, noSideEffect, raises: [AbstractMethodError].}=
    raise AbstractMethodError.newException("Shape.ray_intersection is an abstract method and cannot be called.")

method rayIntersect*(s: Sphere, r: Ray): Option[RayHit]=
    var hit: RayHit = newRayHit()
    var
        inversed_ray: Ray = r.Transform(s.transform)  #r.Transform.inverse
        origin_vec: Vector3 = inversed_ray.origin.convert(Vector3)

        a = r.dir.squareNorm()  #inversed_ray.dir
        b = origin_vec.Dot(inversed_ray.dir) #2*
        c = origin_vec.squareNorm() - 1
    
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

method rayIntersect*(self: Plane, r: Ray): Option[RayHit] {.raises: [AbstractMethodError].}=
    raise AbstractMethodError.newException("Method is not yet implemented.")
    
        


            

    
