import geometry, transformation, rayhit, exception, ray, material, aabb, matrix, stats, utils, triangles, mathutils, color, animator
import std/[math, options, strutils, times, strformat, sequtils, algorithm]


type
    Shape* = ref object of RootObj # abstract class for generic 3D shapes
        id*: string # name 
        origin*: Point
        transform*: Transformation
        material*: Material
        aabb*: AABB
        animator*: Animator
    
    Sphere* = ref object of Shape # 3D unit sphere centered on the origin of the axes
        radius*: float32
    
    Plane* = ref object of Shape # 3D infinite plane parallel to the x and y axis and passing through the origin
    
    Cube* = ref object of Shape

    Triangle* = ref object of Shape
        vertices*: array[3, Point]

    MeshTriangle* = ref object of Shape
        mesh*: TriangleMesh
        vertices*: array[3, int]
        normalIndices*: Option[array[3, int]]
        textureIndices*: Option[array[3, int]]
# -------------------------------- Constructors -------------------------------------

proc newSphere*(id: string, origin: Point, radius: float32 ): Sphere =
    ## constructor for sphere
    result = Sphere(id: id, origin: origin, radius: radius)

proc newSphere*(id: string = "SPHERE_0", transform: Transformation = newTransformation(), material: Material = newMaterial()): Sphere =
    ## constructor for sphere
    let o = ExtractTranslation(transform.m).convert(Point)
    let scaling = ExtractScale(transform.m)
    if scaling[0,0] != scaling[1,1] or scaling[1,1] != scaling[2,2]:
        raise NotImplementedError.newException("Asymmetrical spheres have not yet been implemented!")
    let radius = scaling[0,0]
    result = Sphere(id: id, transform: transform, material: material, origin: o, radius: radius, aabb: newAABB(newPoint(o.x-radius, o.y-radius, o.z-radius), newPoint( o.x+radius, o.y+radius, o.z+radius)), animator: newAnimator(id, transform))
    
proc newPlane*(id: string = "PLANE_0", transform: Transformation = newTransformation(), material: Material = newMaterial()): Plane =
    ## constructor for Plane
    result = Plane(id: id, transform: transform, material: material, origin: ExtractTranslation(transform.m).convert(Point), animator: newAnimator(id, transform))

proc newCube*(id: string = "CUBE_0", transform: Transformation = newTransformation(), material: Material = newMaterial()): Cube=
    result = Cube(id: id, transform: transform, material: material, origin: ExtractTranslation(transform.m).convert(Point), animator: newAnimator(id, transform))

proc newTriangle*(id: string = "TRIANGLE_0", transform: Transformation = newTransformation(), vertices: array[3, Point], mat: Material): Triangle=
    let o = newPoint(
        (vertices[0].x + vertices[1].x + vertices[2].x) / 3.0,
        (vertices[0].y + vertices[1].y + vertices[2].y) / 3.0,
        (vertices[0].z + vertices[1].z + vertices[2].z) / 3.0,
    )
    result = Triangle(id: id, transform: transform, material: mat, vertices: vertices, origin: o)

proc newMeshTriangle*(id: string = "TRIANGLE_0", transform: Transformation = newTransformation(), mesh: TriangleMesh, triNumber: int = 0, material: Material = newMaterial()): MeshTriangle=
    ## constructor for triangle
    var
        v: array[3, int] = [mesh.vertexIndices[3 * triNumber], mesh.vertexIndices[3 * triNumber + 1], mesh.vertexIndices[3 * triNumber + 2]]
        vn, vt: Option[array[3,int]] = none(array[3,int])
    if mesh.normalIndices.isSome:
        vn = some([mesh.normalIndices.get()[3 * triNumber], mesh.normalIndices.get()[3 * triNumber + 1], mesh.normalIndices.get()[3 * triNumber + 2]])
    if mesh.textureIndices.isSome:
        vt = some([mesh.textureIndices.get()[3 * triNumber ], mesh.textureIndices.get()[3 * triNumber + 1], mesh.textureIndices.get()[3 * triNumber + 2]])
    var aabb: AABB = Union( newAABB(transform * mesh.vertexPositions[v[0]], transform * mesh.vertexPositions[v[1]]), mesh.vertexPositions[v[2]])
    result = MeshTriangle(id: id, transform: transform, origin: ExtractTranslation(transform.m).convert(Point), material: material, mesh: mesh, vertices: v, normalIndices: vn, textureIndices: vt, aabb: aabb, animator: newAnimator(id, transform))

proc CreateTriangleMesh*(mesh: TriangleMesh): seq[MeshTriangle] {.inline.}=
    ## Creates a mesh of triangles
    for i in  0..mesh.nTriangles-1:
        result.add( newMeshTriangle(id=fmt"TRIANGLE_{i}",transform=mesh.transform, mesh=mesh, triNumber=i, material= mesh.material))

# -------------------------------------- Private methods ------------------------------------
proc sphereNormal(p: Point, dir: Vector3): Normal= 
    ## Returns the normal to a sphere
    ## Parameters
    ##      p (Point): point on the sphere where the Normal is origonated
    ##      dir (Vector3): direction of observation
    ## Returns
    ##      (Normal)
    var n: Normal = newNormal(p.x, p.y, p.z)
    if p.convert(Vector3).Dot(dir) < 0.0:
        return n
    else:
        return n.neg()

proc cubeNormal(point:Point, ray_dir:Vector3): Normal=
    var normal: Normal
    if point.x == 0 or point.x == 1:
        normal = newNormal(1.0, 0.0, 0.0)
    elif point.y == 0 or point.y == 1:
        normal = newNormal(0.0, 1.0, 0.0)
    elif point.z == 0 or point.z == 1:
        normal = newNormal(0.0, 0.0, 1.0)
    else :
        normal = newNormal(9,9,9)
    
    if result * ray_dir >= 0.0:
        normal = normal * -1.0
    return normal

proc sphereWorldToLocal(p: Point, radius: float32): Vector2=
    let
        u = arctan2(p.y, p.x) / (2.0 * PI)   #p.x not p.z ??
        v = arccos(p.z) / PI ## divided by radius ??
    if u >= 0.0:
        result = newVector2(u,v)
    else:
        result = newVector2(u+1.0, v)

proc cubeWorldToLocal(point: var Point): Vector2=
    var
        u,v: float32
        omx: float32 = 1.0 - point.x # one minus x
    if (point.z > 0.0) and (point.z < 1.0):
        v = Lerp(1.0/3.0, 2.0/3.0, point.z)
    elif (point.z.IsEqual(0.0)):
        v = Lerp(1.0/3.0, 0.0, point.x)
    elif (point.z.IsEqual(1.0)):
        v = Lerp(2.0/3.0, 1.0, point.x)
    else:
        raise ValueError.newException("Cube z point is either < 0 or > 1")

    
    if point.y.IsEqual(0.0):
        u = Lerp(0.0, 1.0/4.0, omx)
    elif point.y.IsEqual(1.0):
        u = Lerp(0.5, 3.0/4.0, point.x)
    elif point.y < 1.0 and point.y > 0.0:
        if point.x.IsEqual(0.0):
            u = Lerp(1.0/4.0, 0.5, point.y)
        elif point.x.IsEqual(1.0):
            u = Lerp(3.0/4.0, 1.0, omx)
        else:
            if point.z > 0 and point.z < 1.0:
                raise ValueError.newException("Point in the middle of the cube.")
    else:
        raise ValueError.newException("Cube y point is either < 0 or > 1")    
    return newVector2(u,1.0 - v)

###### --------------------------------------------- Methods --------------------------------------------

#### Triangles
proc GetUV(self: MeshTriangle): seq[Vector2]=
    ## Returns (u,v) coordinates of the triangle's vertexes
    ## Parameters
    ##      self (MeshTriangle)
    ## Returns
    ##      (seq[Vector2])
    if (self.mesh.uvs.isSome):
        let
            uvs = self.mesh.uvs.get()
            a = uvs[self.textureIndices.get()[0]]
            b = uvs[self.textureIndices.get()[1]]
            c = uvs[self.textureIndices.get()[2]]
        #echo self.id," - ",@[a,b,c]
        return @[a,b,c]
    else:
        return @[newVector2(0.0, 0.0), newVector2(1.0, 0.0), newVector2(1.0, 1.0)]

proc Area*(self: MeshTriangle): float32=
    ## Returns the area of a triangle
    ## Parameters
    ##      self (MeshTriangle)
    ## Returns
    ##      (float32)
    let
        v0 = self.mesh.vertexPositions[self.vertices[0]].convert(Vector3)
        v1 = self.mesh.vertexPositions[self.vertices[1]].convert(Vector3)
        v2 = self.mesh.vertexPositions[self.vertices[2]].convert(Vector3)
    return 0.5 * Cross(v1 - v0, v2 - v0).norm()

#####  ---- Ray Intersection
method rayIntersect*(s: Shape, r: Ray, debug: bool = false): Option[RayHit] {.base.}=
    ## Abstract method for shape.rayIntersect which computes the intersection between a ray and the shape.
    ## This is an abstract method, do not call it directly.
    raise AbstractMethodError.newException("Shape.ray_intersection is an abstract method and cannot be called.")

method rayIntersect*(s: Sphere, r: Ray, debug: bool = false): Option[RayHit] {.injectProcName.} =
    ## Checks if a ray intersects the sphere
    ## Parameters
    ##      s (Sphere)
    ##      r (Ray)
    ## Returns   
    ##     (Option[RayHit]): a `RayHit` if an intersection is found or `None` (else)
    #let start = now()
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
    hit.surface_point = sphereWorldToLocal(hitpoint, s.radius)
    hit.ray = r
    hit.material = s.material
    #let endTime = now() - start
    #mainStats.AddCall(procName, endTime, 2)
    return some(hit)


method rayIntersect*(self: Plane, ray: Ray, debug: bool = false): Option[RayHit] =
    ## Checks if a ray intersects the plane
    ## Parameters
    ##      self (Plane)
    ##      r (Ray)
    ## Returns   
    ##     (Option[RayHit]): a `RayHit` if an intersection is found or `None` (else)
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

method rayIntersect*(self: Cube, ray: Ray, debug: bool = false): Option[RayHit] =
    let
        inverse_ray= ray.Transform(self.transform.Inverse())
        origin_vec = inverse_ray.origin.convert(Vector3)
    
    var
        tx = @[- inverse_ray.origin.x / inverse_ray.dir.x , (1.0 - inverse_ray.origin.x) / inverse_ray.dir.x]
        ty = @[- inverse_ray.origin.y / inverse_ray.dir.y , (1.0 - inverse_ray.origin.y) / inverse_ray.dir.y]
    sort( tx, system.cmp[float32] )
    sort( ty, system.cmp[float32] )

    var
        t_min: float32 = tx[0]
        t_max: float32 = tx[1]
        ty_min: float32 = ty[0]
        ty_max: float32 = ty[1]

    if (t_min > t_ymax) or (t_ymin > t_max):
        return none(RayHit)

    t_min = max(t_min, t_ymin)
    t_max = min(t_max, t_ymax)

    var tz = @[- inverse_ray.origin.z / inverse_ray.dir.z , (1.0 - inverse_ray.origin.z) / inverse_ray.dir.z]
    sort(tz)
    var
        tz_min: float32 = tz[0]
        tz_max: float32 = tz[1]

    if (t_min > t_zmax) or (t_zmin > t_max):
        return none(RayHit)

    t_min = max(t_min, t_zmin)
    t_max = min(t_max, t_zmax)
        
    var hit_point: Point
    if (inverse_ray.tmin <= t_min and t_min <= inverse_ray.tmax):
        hit_point = at(inverse_ray, t_min)
        return some(newRayHit(self.transform * hit_point, self.transform * cubeNormal(hit_point, inverse_ray.dir), cubeWorldToLocal(hit_point), t_min, ray, self.material))
    elif (inverse_ray.tmin <= t_max and t_max <= inverse_ray.tmax):
        hit_point = at(inverse_ray, t_max)
        return some(newRayHit(self.transform * hit_point, self.transform * cubeNormal(hit_point, inverse_ray.dir), cubeWorldToLocal(hit_point), t_max, ray, self.material))
    else:
        return none(RayHit)


method rayIntersect*(self: Triangle, ray: Ray, debug: bool = false): Option[RayHit] =
    ## Checks if a ray intersects the triangle
    ## Parameters
    ##      self (MeshTriangle)
    ##      r (Ray)
    ## Returns   
    ##     (Option[RayHit]): a `RayHit` if an intersection is found or `None` (else)
    var hit: RayHit = newRayHit()
    var
        firsthit_t: float32
        inversed_ray: Ray = ray.Transform(self.transform.Inverse())
        origin_vec: Vector3 = inversed_ray.origin.convert(Vector3)
        a: Point = self.vertices[0]
        b: Point = self.vertices[1]
        c: Point = self.vertices[2]
    let det = newMatrix(@[
        @[(b.x - a.x).float32, c.x - a.x, inversed_ray.dir.x, 0.0],
        @[(b.y - a.y).float32, c.y - a.y, inversed_ray.dir.y, 0.0],
        @[(b.z - a.z).float32, c.z - a.z, inversed_ray.dir.z, 0.0],
        @[0.0'f32, 0.0, 0.0, 1.0]
    ]).Determinant()
    if det == 0.0:
        # Ray is parallel to triangle's plane
        return none(RayHit)

    var
        dBeta: float32 = newMatrix(@[
            @[origin_vec.x - a.x, c.x - a.x, inversed_ray.dir.x, 0.0],
            @[origin_vec.y - a.y, c.y - a.y, inversed_ray.dir.y, 0.0],
            @[origin_vec.z - a.z, c.z - a.z, inversed_ray.dir.z, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0]
        ]).Determinant()

        dGamma: float32 = newMatrix(@[
            @[b.x - a.x, origin_vec.x - a.x, inversed_ray.dir.x, 0.0],
            @[b.y - a.y, origin_vec.y - a.y, inversed_ray.dir.y, 0.0],
            @[b.z - a.z, origin_vec.z - a.z, inversed_ray.dir.z, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0]
        ]).Determinant()
        
        dT: float32 = newMatrix(@[
            @[b.x - a.x, c.x - a.x, origin_vec.x - a.x, 0.0],
            @[b.y - a.y, c.y - a.y, origin_vec.y - a.y, 0.0],
            @[b.z - a.z, c.z - a.z, origin_vec.z - a.z, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0]
        ]).Determinant()

    let
        beta = dBeta / det
        gamma = dGamma / det
        t = -dT / det
    if t < inversed_ray.tmin or t > inversed_ray.tmax:
        return none(RayHit)
    if beta < 0 or beta > 1:
        return none(RayHit)
    if gamma < 0 or gamma > 1:
        return none(RayHit)
    let w = 1 - beta - gamma

    hit.world_point = newPoint(
        beta * a.x + gamma * b.x + w * c.x,
        beta * a.y + gamma * b.y + w * c.y,
        beta * a.z + gamma * b.z + w * c.z
    )
    hit.normal = (b-a).convert(Vector3).Cross((c-a).convert(Vector3)).convert(Normal)
    hit.surface_point = newVector2(beta, gamma)
    hit.t = t
    hit.ray = inversed_ray
    hit.material = self.material
    return some(hit)
    

method rayIntersect*(self: MeshTriangle, ray: Ray, debug: bool = false): Option[RayHit] =
    ## Checks if a ray intersects the triangle
    ## Parameters
    ##      self (MeshTriangle)
    ##      r (Ray)
    ## Returns   
    ##     (Option[RayHit]): a `RayHit` if an intersection is found or `None` (else)
    var hit: RayHit = newRayHit()
    var
        firsthit_t: float32
        inversed_ray: Ray = ray.Transform(self.transform.Inverse())
        origin_vec: Vector3 = inversed_ray.origin.convert(Vector3)
        a: Point = self.mesh.vertexPositions[self.vertices[0]]
        b: Point = self.mesh.vertexPositions[self.vertices[1]]
        c: Point = self.mesh.vertexPositions[self.vertices[2]]
    if not (self.mesh.aabb.RayIntersect(inversed_ray)):
        return none(RayHit)
    
    let det = newMatrix(@[
        @[(b.x - a.x).float32, c.x - a.x, inversed_ray.dir.x, 0.0],
        @[(b.y - a.y).float32, c.y - a.y, inversed_ray.dir.y, 0.0],
        @[(b.z - a.z).float32, c.z - a.z, inversed_ray.dir.z, 0.0],
        @[0.0'f32, 0.0, 0.0, 1.0]
    ]).Determinant()
    if det == 0.0:
        # Ray is parallel to triangle's plane
        return none(RayHit)

    var
        dBeta: float32 = newMatrix(@[
            @[origin_vec.x - a.x, c.x - a.x, inversed_ray.dir.x, 0.0],
            @[origin_vec.y - a.y, c.y - a.y, inversed_ray.dir.y, 0.0],
            @[origin_vec.z - a.z, c.z - a.z, inversed_ray.dir.z, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0]
        ]).Determinant()

        dGamma: float32 = newMatrix(@[
            @[b.x - a.x, origin_vec.x - a.x, inversed_ray.dir.x, 0.0],
            @[b.y - a.y, origin_vec.y - a.y, inversed_ray.dir.y, 0.0],
            @[b.z - a.z, origin_vec.z - a.z, inversed_ray.dir.z, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0]
        ]).Determinant()
        
        dT: float32 = newMatrix(@[
            @[b.x - a.x, c.x - a.x, origin_vec.x - a.x, 0.0],
            @[b.y - a.y, c.y - a.y, origin_vec.y - a.y, 0.0],
            @[b.z - a.z, c.z - a.z, origin_vec.z - a.z, 0.0],
            @[0.0'f32, 0.0, 0.0, 1.0]
        ]).Determinant()

    let
        beta = dBeta / det
        gamma = dGamma / det
        t = -dT / det
    if t < inversed_ray.tmin or t > inversed_ray.tmax:
        return none(RayHit)
    if beta < 0 or beta > 1:
        return none(RayHit)
    if gamma < 0 or gamma > 1:
        return none(RayHit)
    let w = 1 - beta - gamma

    hit.world_point = newPoint(
        beta * a.x + gamma * b.x + w * c.x,
        beta * a.y + gamma * b.y + w * c.y,
        beta * a.z + gamma * b.z + w * c.z
    )
    hit.normal = (b-a).convert(Vector3).Cross((c-a).convert(Vector3)).convert(Normal)
    hit.surface_point = newVector2(beta, gamma)
    hit.t = t
    hit.ray = inversed_ray
    hit.material = self.mesh.material
    return some(hit)

