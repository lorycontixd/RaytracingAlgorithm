import geometry, exception, mathutils, ray
import std/[bitops, strformat]

type
    AABB* = ref object of RootObj
        pMin*, pMax*: Point

func newAABB*(): AABB= discard

func newAABB*(p: Point): AABB {.inline.}=
    return AABB(pMin: p, pMax: p)

func newAABB*(p1, p2: Point): AABB {.inline.}=
    let pmin = newPoint(min(p1.x, p2.x), min(p1.y, p2.y), min(p1.z, p2.z))
    let pmax = newPoint(max(p1.x, p2.x), max(p1.y, p2.y), max(p1.z, p2.z))
    return AABB(pMin: pmin, pMax: pmax)

# -----------------  Operators  ---------------------
func `[]`*(self: AABB, index: int): Point {.inline.}=
    if index==0:
        return self.pMin
    elif index==1:
        return self.pMax
    else:
        raise newException(exception.IndexError, "Invalid indexing value for AABB")

func `==`*(lhs, rhs: AABB): bool {.inline.}=
    return lhs.pMin.isClose(rhs.pMin) and lhs.pMax.isClose(rhs.pMax)

func `!=`*(lhs, rhs: AABB): bool {.inline.}=
    return not (lhs == rhs)

func `$`*(self: AABB): string {.inline.}=
    return fmt"AABB( pMin: {$self.pMin}, pMax: {$self.pMax} )"

# --------------------  Methods  ------------------------

func Corner*(self: AABB, corner: int): Point {.inline.}=
    ##
    return newPoint(
        self[bitand(corner,1)].x,
        self[bitand(corner,2)].y,
        self[bitand(corner,4)].z
    )

func Diagonal*(self: AABB): Vector3=
    return (self.pMax - self.pMin).convert(Vector3)

func Expand*(self: var AABB, delta: float32): void=
    self.pMin = self.pMin - newVector3(delta, delta, delta)
    self.pMax = self.pMax + newVector3(delta, delta, delta)

func IsPointInside*(self: AABB, p: Point): bool {.inline.}=
    return (p.x >= self.pMin.x and p.x <= self.pMax.x) and (p.y >= self.pMin.y and p.y <= self.pMax.y) and (p.z >= self.pMin.z and p.z <= self.pMax.z)

func Intersect*(self, other: AABB): AABB=
    ##
    return newAABB(
        newPoint(
            min(self.pMin.x, other.pMin.x),
            min(self.pMin.y, other.pMin.y),
            min(self.pMin.z, other.pMin.z)
        ),
        newPoint(
            max(self.pMax.x, other.pMax.x),
            max(self.pMax.y, other.pMax.y),
            max(self.pMax.z, other.pMax.z)
        )
    )

func Lerp*(self: AABB, p: var Point): Point {.inline.}=
    ##
    return newPoint(
        Lerp(self.pMin.x, self.pMax.x, p.x),
        Lerp(self.pMin.y, self.pMax.y, p.y),
        Lerp(self.pMin.z, self.pMax.z, p.z)
    )

func Overlaps*(self: AABB, other: AABB): bool=
    let
        x = (self.pMax.x >= other.pMin.x) and (self.pMin.x <= other.pMax.x)
        y = (self.pMax.y >= other.pMin.y) and (self.pMin.y <= other.pMax.y)
        z = (self.pMax.z >= other.pMin.z) and (self.pMin.z <= other.pMax.z)
    return x and y and z

func RayIntersect*(self: AABB, inversed_ray: Ray, debug: bool = false): bool=
    var origin: Point = inversed_ray.origin

    var
        invD: Vector3 = 1.0 / inversed_ray.dir
        t0s: Vector3 = (self.pMin - origin).ComponentProduct(invD)
        t1s: Vector3 = (self.pMax - origin).ComponentProduct(invD)

        invDSE: seq[bool] = @[invD[0]<0.0, invD[1]<0.0, invD[2]<0.0]
  
    for a in countup(0,2):
        if (invDSE[a]):
            let temp = t1s[a]
            t1s[a] = t0s[a]
            t0s[a] = temp

        let
            tmin = max(inversed_ray.tmin, t0s[a])
            tmax = min(inversed_ray.tmax, t1s[a])

        if (tmax <= tmin):
            return false

    return true;

proc Show*(self: AABB): void=
    echo fmt"AABB(pMin: {$self.pMin}, pMax: {$self.pMax})"

func SurfaceArea*(self: AABB): float32=
    let d = self.Diagonal()
    return 2 * (d.x * d.y + d.x * d.z + d.y * d.z)

func Union*(self: AABB, p: Point): AABB=
    return newAABB(
        newPoint(
            min(self.pMin.x, p.x),
            min(self.pMin.y, p.y),
            min(self.pMin.z, p.z)
        ),
        newPoint(
            max(self.pMax.x, p.x),
            max(self.pMax.y, p.y),
            max(self.pMax.z, p.z)
        )
    )

func Union*(self: AABB, other: AABB): AABB=
    ##
    return newAABB(
        newPoint(
            min(self.pMin.x, other.pMin.x),
            min(self.pMin.y, other.pMin.y),
            min(self.pMin.z, other.pMin.z)
        ),
        newPoint(
            max(self.pMax.x, other.pMax.x),
            max(self.pMax.y, other.pMax.y),
            max(self.pMax.z, other.pMax.z)
        )
    )

func Volume*(self: AABB): float32=
    let d = self.Diagonal()
    return d.x * d.y * d.z

## Funcs that depend on other funcs

func BoundToSphere*(self: AABB, center: var Point, radius: var float32): void {.inline.}=
    center = (self.pMin + self.pMax) / 2.0
    if self.IsPointInside(center):
        radius = Distance(center, self.pMax)
    else:
        radius = float32(0.0)

## ---------------------------------------  STATIC METHODS  -----------------------------------------

func Expand*(_: typedesc[AABB], b: AABB, delta: float32): AABB=
    return b.Expand(delta)

func Diagonal*(_: typedesc[AABB], b: AABB): Vector3=
    return b.Diagonal()

func Intersect*(_: typedesc[AABB], b1, b2: AABB): AABB=
    return b1.Intersect(b2)

func Union*(_: typedesc[AABB], b: AABB, point: Point): AABB=
    return b.Union(point)

func Union*(_: typedesc[AABB], b1, b2: AABB): AABB=
    return b1.Union(b2)