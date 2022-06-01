import geometry, transformation, rayhit, exception, ray, material, aabb, matrix, stats, utils, triangles, mathutils, color
import std/[math, options, strutils, times, strformat]


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

    Triangle* = ref object of Shape
        mesh*: TriangleMesh
        vertices*: array[3, int]
        normalIndices*: array[3, int]
        textureIndices*: array[3, int]
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
    if scaling[0,0] != scaling[1,1] or scaling[1,1] != scaling[2,2]:
        raise NotImplementedError.newException("Asymmetrical spheres have not yet been implemented!")
    let radius = scaling[0,0]
    result = Sphere(id: id, transform: transform, material: material, origin: o, radius: radius, aabb: newAABB(newPoint(o.x-radius, o.y-radius, o.z-radius), newPoint( o.x+radius, o.y+radius, o.z+radius)))
    
proc newPlane*(id: string = "PLANE_0", transform: Transformation = newTransformation(), material: Material = newMaterial()): Plane =
    if not id.contains("PLANE"):
        raise ValueError.newException("Plane id must contain PLANE keyword.")
    result = Plane(id: id, transform: transform, material: material, origin: ExtractTranslation(transform.m).convert(Point))

proc newCylinder*(id: string = "CYLINDER_0", transform: Transformation, material: Material = newMaterial()): Cylinder=
    if not id.contains("CYLINDER"):
        raise ValueError.newException("Cylinder id must contain CYLINDER keyword.")
    result = Cylinder(id: id, transform: transform, material: material, aabb: newAABB(newPoint(), newPoint()))

proc newTriangle*(id: string = "TRIANGLE_0", transform: Transformation = newTransformation(), mesh: TriangleMesh, triNumber: int = 0, material: Material = newMaterial()): Triangle=
    if not id.contains("TRIANGLE"):
        raise ValueError.newException("Triangle id must contain CYLINDER keyword.")
    var
        v: array[3, int] = [mesh.vertexIndices[3 * triNumber], mesh.vertexIndices[3 * triNumber + 1], mesh.vertexIndices[3 * triNumber + 2]]
        vn: array[3, int] = [mesh.normalIndices.get()[3 * triNumber], mesh.normalIndices.get()[3 * triNumber + 1], mesh.normalIndices.get()[3 * triNumber + 2]]
        vt: array[3, int] = [mesh.textureIndices.get()[3 * triNumber], mesh.textureIndices.get()[3 * triNumber + 1], mesh.textureIndices.get()[3 * triNumber + 2]]
    var aabb: AABB = Union( newAABB(transform * mesh.vertexPositions[v[0]], transform * mesh.vertexPositions[v[1]]), mesh.vertexPositions[v[2]])
    result = Triangle(id: id, transform: transform, origin: ExtractTranslation(transform.m).convert(Point), material: material, mesh: mesh, vertices: v, normalIndices: vn, textureIndices: vt, aabb: aabb)

proc CreateTriangleMesh*(mesh: TriangleMesh): seq[Triangle] {.inline.}=
    for i in  0..mesh.nTriangles-1:
        result.add(  newTriangle(transform=mesh.transform, mesh=mesh, triNumber=i, material= mesh.material))

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

#### Triangles
func GetUV(self: Triangle): seq[Vector2]=
    if (self.mesh.uvs.isSome):
        let
            uvs = self.mesh.uvs.get()
            a = uvs[self.textureIndices[0]]
            b = uvs[self.textureIndices[1]]
            c = uvs[self.textureIndices[2]]
        return @[a,b,c]
    else:
        return @[newVector2(0.0, 0.0), newVector2(1.0, 0.0), newVector2(1.0, 1.0)]

#[
func PolygonToTriangles*(nFaces: int, faces: seq[int], vertexIndex: seq[int], vertices: seq[Point]): TriangleMesh=
    var k, maxVertIndex, numTris: int = 0
    # detect number of triangles
    for i in 0..nFaces-1:
        numTris += faces[i] - 2
        for j in 0..faces[i]-1:
            if vertexIndex[k + j] > maxVertIndex:
                maxVertIndex = vertexIndex[k + j]
        k += faces[i]
    maxVertIndex += 1

    var newVertices: seq[ Point]
    for i in 0..maxVertIndex-1:
        newVertices.add(vertices[i])

    var triangleIndices: seq[int] # numtris * 3
    var l, k2: int = 0
    for i in 0..nFaces-1:
        for j in 0..faces[i] - 3:
            triangleIndices.add(vertexindex[k2])
            triangleIndices.add(vertexindex[k2 + j + 1])
            triangleIndices.add(vertexindex[k2 + j + 2])
            l += 3
        k2 += faces[i]

    return newTriangleMesh(
        transform=newTransformation(),
        nTriangles=numTris,
        nVertices=maxVertIndex,
        vertexIndices=triangleIndices,
        points=newVertices
    )
]#




#####  ---- Ray Intersection
method rayIntersect*(s: Shape, r: Ray, debug: bool = false): Option[RayHit] {.base.}=
    ## Abstract method for shape.rayIntersect which computes the intersection between a ray and the shape.
    ## This is an abstract method, do not call it directly.
    raise AbstractMethodError.newException("Shape.ray_intersection is an abstract method and cannot be called.")

method rayIntersect*(s: Sphere, r: Ray, debug: bool = false): Option[RayHit] {.injectProcName.} =
    let start = now()
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
    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 2)
    return some(hit)

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


method rayIntersect*(self: Cylinder, ray: Ray, debug: bool = false): Option[RayHit] {.injectProcName.}=
    let start = now()
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
    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 2)
    return some(hit)

method rayIntersect*(self: Triangle, ray: Ray, debug: bool = false): Option[RayHit] = 
    ## Moller-Trumbore Algorithm
    var
        #invray: Ray = ray.Transform(self.transform.Inverse()) ## Inversed ray
        invray = ray
        vertex0: Vector3 = self.mesh.vertexPositions[self.vertices[0]].convert(Vector3)
        vertex1: Vector3 = self.mesh.vertexPositions[self.vertices[1]].convert(Vector3)
        vertex2: Vector3 = self.mesh.vertexPositions[self.vertices[2]].convert(Vector3)
        edge1, edge2, h, s, q: Vector3
        a, f, u, v: float32
    
    edge1 = vertex1 - vertex0
    edge2 = vertex2 - vertex0
    h = invray.dir.Cross(edge2)
    a = edge1.Dot(h)
    if a.IsEqual(0.0): # Ray is parallel to triangle
        return none(RayHit)
    f = 1.0 / a
    s = invray.origin.convert(Vector3) - vertex0
    u = f * s.Dot(h)
    if (u < 0.0 or u > 1.0):
        return none(RayHit)
    q = s.Cross(edge1)
    v = f * invray.dir.Dot(q)
    if (v < 0.0 or u + v > 1.0):
        return none(RayHit)
    let uvs = self.GetUV()
    var
        minu: float32 = min(uvs[0].u, min(uvs[1].u, uvs[2].u))
        minv: float32 = min(uvs[0].v, min(uvs[1].v, uvs[2].v))
        maxu: float32 = max(uvs[0].u, max(uvs[1].u, uvs[2].u))
        maxv: float32 = max(uvs[0].v, max(uvs[1].v, uvs[2].v))
    var t: float32 = f * edge2.Dot(q)
    if t > 0.0:
        #echo "uv: ",u," - ",v
        var hit: RayHit = newRayHit(
            invray.origin + t * invray.dir,
            edge1.Cross(edge2).convert(Normal),
            #newVector2(u,v),
            newVector2(
                Lerp(minu, maxu, u),
                Lerp(minv, maxv, v)
            ),
            t,
            invray,
            self.mesh.material
        )
        return some(hit)
    else:
        return none(RayHit)

