method rayIntersect*(self: Triangle, r: Ray, debug: bool = false): Option[RayHit] = 
    var ray: Ray = r.Transform(self.transform.Inverse()) ## Inversed ray
    var
        pp0 = self.mesh.vertexPositions[self.vertices[0]] - ray.origin.convert(Vector3)
        pp1 = self.mesh.vertexPositions[self.vertices[1]] - ray.origin.convert(Vector3)
        pp2 = self.mesh.vertexPositions[self.vertices[2]] - ray.origin.convert(Vector3)
        v = newVector3(abs(ray.dir.x), abs(ray.dir.y), abs(ray.dir.z))
        p0, p1, p2: Point
    # permutation
    var kz : int
    if v.x > v.y:
        if v.x > v.z:
            kz = 0
        else:
            kz = 2
    else:
        if v.y > v.z:
            kz = 1
        else:
            kz = 2
    var kx: int = kz + 1
    if kx == 3:
        kx = 0
    var ky: int = kx + 1
    if ky == 3:
        ky = 0
    var d: Vector3 = Permute(ray.dir, kx, ky, kz)
    p0 = Permute(pp0, kx, ky, kz)
    p1 = Permute(pp1, kx, ky, kz)
    p2 = Permute(pp2, kx, ky, kz)

    # apply shear transformation to new vertex positions
    let
        sx = -d.x / d.z
        sy = -d.y / d.z
        sz = 1.0 / d.z
    p0.x = p0.x + sx * p0.z
    p0.y = p0.y + sy * p0.z
    p1.x = p0.x + sx * p0.z
    p1.y = p1.y + sy * p0.z
    p2.x = p2.x + sx * p0.z
    p2.y = p2.y + sy * p0.z

    # edge function coefficients
    let
        e0 = p1.x * p2.y - p1.y * p2.x
        e1 = p2.x * p0.y - p2.y * p0.x
        e2 = p0.x * p1.y - p0.y * p1.x
    
    #if e0 == 0.0 or e1 == 0.0 or e2 == 0.0:
    if (e0 < 0.0 or e1 < 0.0 or e2 < 0.0) and (e0 > 0.0 or e1 > 0.0 or e2 > 0.0):
        echo "e0: ",e0,"  e1: ",e1,"  e2: ",e2
        return none(RayHit)
    let det = e0 + e1 + e2
    if det == 0.0:
        echo "b"
        return none(RayHit)

    p0.z = p0.z * sz
    p1.z = p1.z * sz
    p2.z = p2.z * sz
    var tScaled: float32 = e0 * p0.z + e1 * p1.z + e2 * p2.z

    if det < 0 and (tScaled >= 0 or tScaled < ray.tmax * det):
        return none(RayHit)
    if det > 0 and (tScaled >= 0 or tScaled > ray.tmax * det):
        return none(RayHit)
    
    # barycentric coordinates and t value for intersection
    let
        invDet = 1.0 / det
        b0 = e0 * invDet
        b1 = e1 * invDet
        b2 = e2 * invDet
        t = tScaled * invDet

    var
        uv: seq[Vector2] = self.GetUV()
        duv02: Vector2 = uv[0] - uv[2]
        duv12: Vector2 = uv[1] - uv[2]
        dp02: Vector3 = (p0 - p2).convert(Vector3)
        dp12: Vector3 = (p1 - p2).convert(Vector3)
        determinant: float32 = duv02[0] * duv12[1] - duv02[1] * duv12[0]
        dpdu, dpdv: Vector3
        normal: Normal = normalize(Cross( (p2 - p0).convert(Vector3), (p1 - p0).convert(Vector3))).convert(Normal)
    if determinant == 0.0:
        let (a, b, e3) = CreateOnbFromZ(normal)
        dpdu = a
        dpdv = b
    else:
        let invdet = 1.0 / determinant
        dpdu = (duv12[1] * dp02 - duv02[1] * dp12) * invdet
        dpdv = (-duv12[0] * dp02 - duv02[0] * dp12) * invdet
    
    var
        pHit: Point = b0 * p0 + b1 * p1 + b2 * p2
        uvHit: Vector2 = b0 * uv[0] + b1 * uv[1] + b2 * uv[2]
    
    var hit: RayHit = newRayHit(
        pHit,
        normal,
        uvHit,
        t,
        ray,
        newMaterial()
    )
]#



#[
method rayIntersect*(self: Triangle, r: Ray, debug: bool = false): Option[RayHit] {.injectProcName.} = 
    # Compute plane normal
    var
        ray: Ray = r.Transform(self.transform.Inverse()) ## Inversed ray
        res: RayHit = newRayHit()
        v0v1: Vector3 = (self.mesh.vertexPositions[self.vertices[1]] - self.mesh.vertexPositions[self.vertices[0]]).convert(Vector3)
        v0v2: Vector3 = (self.mesh.vertexPositions[self.vertices[2]] - self.mesh.vertexPositions[self.vertices[0]]).convert(Vector3)
        n: Normal = Cross(v0v1, v0v2).convert(Normal)
        nNorm: float32 = n.norm()z

    ### Step1: Find p

    # Check if ray and plane are parallel
    let ndotray = Dot(n, ray.dir)
    if ndotray.IsEqual(0.0):
        # parallel -> no intersection
        return none(RayHit)
    let d = Dot(n.convert(Vector3).neg(), self.mesh.vertexPositions[self.vertices[0]])
    let t = -Dot(n, ray.origin.convert(Vector3)) + d / ndotray
    # Check if intersection is behind the ray
    if t < 0.0:
        return none(RayHit)
    # compute intersection point
    var p: Point = ray.origin + t * ray.dir

    ## Step 2: inside-outside test
    var C: Vector3 # vector perpendicular to triangle plane

    # Edge 0
    var
        e0: Vector3 = (self.mesh.vertexPositions[self.vertices[1]] - self.mesh.vertexPositions[self.vertices[0]]).convert(Vector3)
        vp0: Vector3 = (p - self.mesh.vertexPositions[self.vertices[0]]).convert(Vector3)
    C = Cross(e0, vp0)
    if (Dot(n, C) < 0.0):
        # p is on the right side
        return none(RayHit)

    #Edge 1
    var
        e1: Vector3 = (self.mesh.vertexPositions[self.vertices[2]] - self.mesh.vertexPositions[self.vertices[1]]).convert(Vector3)
        vp1: Vector3 = (p - self.mesh.vertexPositions[self.vertices[1]]).convert(Vector3)
    C = Cross(e1, vp1)
    if (Dot(n, C) < 0.0):
        # p is on the right side
        return none(RayHit)

    #Edge 2
    var
        e2: Vector3 = (self.mesh.vertexPositions[self.vertices[0]] - self.mesh.vertexPositions[self.vertices[2]]).convert(Vector3)
        vp2: Vector3 = (p - self.mesh.vertexPositions[self.vertices[2]]).convert(Vector3)
    C = Cross(e2, vp2)
    if (Dot(n, C) < 0.0):
        # p is on the right side
        return none(RayHit)

    res.world_point = p
    res.normal = n
    res.surface_point = newVector2(0.0, 0.0)