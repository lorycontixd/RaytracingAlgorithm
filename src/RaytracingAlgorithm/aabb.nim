#[
    - AABB stands for axis-aligned bounding boxes. 
    - AABB consists of a non-rotating box around the object in order to quickly determine
    eventual intersections with rays or overlaps with other objects.
    - The object's box can be used to quickly check if a ray could intersect the object.
    In case the ray intersects the object's bounding box, then it might also intersect
    the object itself, while if the ray misses the bounding box, it surely will not
    intersect the object.
    - The box is defined by two points, the minimum point and the maximum point,
    respectively defined by the minimum/maximum values for each coordinate of the object.
    - The advantage of using AABB is to gain computational performance by not calculating object-ray
    intersections using rays that can miss the object. Therefore, if AABB checks pass,
    more checks are performed for intersection/collision.
]#

import geometry, exception, mathutils, ray
import std/[bitops, strformat]

type
    AABB* = ref object of RootObj
        pMin*, pMax*: Point

func newAABB*(): AABB= discard

func newAABB*(p: Point): AABB {.inline.}=
    ## constructor for a new AABB from a point
    ## Parameters
    ##      p (Point) : point for the bounding box
    ## Returns
    ##      The bounding box defined by the point, assumed as minimum and maximum
    return AABB(pMin: p, pMax: p)

func newAABB*(p1, p2: Point): AABB {.inline.}=
    ## Creates a new AABB object starting from two points (bottom & top)
    ## Parameters
    ##      p1 (Point): minimum point for the bounding box
    ##      p2 (Point): maximum point for the bounding box
    ## Returns
    ##      The bounding box defined by the two points
    let pmin = newPoint(min(p1.x, p2.x), min(p1.y, p2.y), min(p1.z, p2.z))
    let pmax = newPoint(max(p1.x, p2.x), max(p1.y, p2.y), max(p1.z, p2.z))
    return AABB(pMin: pmin, pMax: pmax)

# -----------------  Operators  ---------------------
func `[]`*(self: AABB, index: int): Point {.inline.}=
    ## Access operator for a bounding box. Gets the equivalent point of `index`.
    ## Parameters
    ##      self (AABB): The bounding box to be accessed.
    ##      index (int): The index of the queried point (0 or 1)
    ## Returns
    ##      The minimum/maximum point of the bounding box based on `index`
    ## Raises
    ##      IndexError: The index is too small/large
    if index==0:
        return self.pMin
    elif index==1:
        return self.pMax
    else:
        raise newException(exception.IndexError, "Invalid indexing value for AABB")

func `==`*(lhs, rhs: AABB): bool {.inline.}=
    ## Equality operator for two AABBs. Two bounding boxes are equivalent if
    ## the minimum and maximum point of both AABBs overlap.
    ## Parameters
    ##      lhs (AABB): left-hand side AABB
    ##      rhs (AABB): right-hand side AABB
    ## Returns
    ##      Whether the two AABBS are equivalent
    return lhs.pMin.isClose(rhs.pMin) and lhs.pMax.isClose(rhs.pMax)

func `!=`*(lhs, rhs: AABB): bool {.inline.}=
    ## Inequality operator for two AABBs. Opposite of equality operator.
    return not (lhs == rhs)

func `$`*(self: AABB): string {.inline.}=
    ##??String operator for AABB. Formattedly prints AABB info to string.
    ## Parameters
    ##      self (AABB): bounding box to be converted to string
    ## Returns
    ##      Formatted string with AABB information.
    return fmt"AABB( pMin: {$self.pMin}, pMax: {$self.pMax} )"

# --------------------  Methods  ------------------------

func Corner*(self: AABB, corner: int): Point {.inline.}=
    ## Returns the coordinates of one of the eight corners of the box.
    ## Parameters
    ##      self (AABB): Bounding box
    ##      corner (int): index of the corner to be fetched
    ## Returns
    ##      (Point)
    return newPoint(
        self[bitand(corner,1)].x,
        self[bitand(corner,2)].y,
        self[bitand(corner,4)].z
    )

func Diagonal*(self: AABB): Vector3=
    ## Returns the vector along the box diagonal (from min point to max point)
    ## Parameters
    ##      self (AABB): Bounding box
    ## Returns
    ##      The vector (Vector3) diagonal of the box
    return (self.pMax - self.pMin).convert(Vector3)

func Expand*(self: var AABB, delta: float32): void=
    ## Expands the box by a scalar factor along all directions.
    ## This means the minimum & maximum points are shifted by `delta`
    ## in all directions.
    ## Parameters
    ##      self (var AABB): Bounding box to be expanded
    ##      delta (float32): factor of box expansion
    self.pMin = self.pMin - newVector3(delta, delta, delta)
    self.pMax = self.pMax + newVector3(delta, delta, delta)

func IsPointInside*(self: AABB, p: Point): bool {.inline.}=
    ## Checks if a point is inside the given bounding box.
    ## Parameters
    ##      self (AABB): Bounding box
    ##      p (Point): point to be checked
    ## Returns
    ##      Boolean that states if the given point is inside the bounding box.
    return (p.x >= self.pMin.x and p.x <= self.pMax.x) and (p.y >= self.pMin.y and p.y <= self.pMax.y) and (p.z >= self.pMin.z and p.z <= self.pMax.z)

func Intersect*(self, other: AABB): AABB=
    ## Checks if two bounding boxes intersect and returns the intersecting box.
    ## This function is typically used for physical colliders.
    ## Parameters
    ##      self (AABB): Instance of a bounding box.
    ##      other (AABB): Other bounding box.
    ## Returns
    ##      The intersecting bounding box between two bounding boxes.
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
    ## Linearly interpolates a point inside of a bounding box.
    ## Parameters
    ##      self (AABB): Bounding box
    ##      p (var Point): The interpolation parameter inside the box.
    ## Returns
    ##      The interpolated point
    return newPoint(
        Lerp(self.pMin.x, self.pMax.x, p.x),
        Lerp(self.pMin.y, self.pMax.y, p.y),
        Lerp(self.pMin.z, self.pMax.z, p.z)
    )

func Overlaps*(self: AABB, other: AABB): bool=
    ## Checks if two bounding boxes are overlapping.
    ## This function is useful for checking physical collisions.
    ## Parameters
    ##      self (AABB): Instance of a bounding box.
    ##      other (AABB): Other bounding box.
    ## Returns
    ##      Boolean that encodes whether the two bounding boxes are overlapping.
    let
        x = (self.pMax.x >= other.pMin.x) and (self.pMin.x <= other.pMax.x)
        y = (self.pMax.y >= other.pMin.y) and (self.pMin.y <= other.pMax.y)
        z = (self.pMax.z >= other.pMin.z) and (self.pMin.z <= other.pMax.z)
    return x and y and z

func RayIntersect*(self: AABB, inversed_ray: Ray): bool=
    ## Calculate whether the ray intersects the bounding box.
    ## Parameters
    ##      self (AABB): Bounding box
    ##      inversed_ray (Ray): Ray to calculate intersection of. The ray must already have all transformations applied.
    ## Returns
    ##      Boolean that states whether the ray and the bounding box intersect.
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
    ## Prints a formatted string of the bounding box.
    echo fmt"AABB(pMin: {$self.pMin}, pMax: {$self.pMax})"

func SurfaceArea*(self: AABB): float32=
    ##??Calculates the surface area of a bounding box.
    ##??Parameters
    ##      self (AABB): Bounding box
    ## Returns
    ##      The surface area of the box.
    let d = self.Diagonal()
    return 2 * (d.x * d.y + d.x * d.z + d.y * d.z)

func Union*(self: AABB, p: Point): AABB=
    ## Returns the union between a bounding box and a point
    ## ex: minPoint.x = minimun (boundingbox.minimumPoint.x, point.x)
    ## Parameters:
    ##      self (AABB) : bounding box
    ##      p (Point)
    ## Returns
    ##      newAABB : new bounding box, resulting from the union
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
    ## Returns the union between two bounding boxes
    ## ex: minPoint.x = minimun (boundingbox1.minimumPoint.x, boundingbox2.minimumPoint.x)
    ## Parameters:
    ##      self (AABB) : first bounding box
    ##      other (AABB) : second bounding box
    ## Returns
    ##      newAABB : new bounding box, resulting from the union
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
    ## Returns the volume of the bounding box
    ## Parameters
    ##      self (AABB)
    ## Returns
    ##      (float32) : volume
    let d = self.Diagonal()
    return d.x * d.y * d.z

## Funcs that depend on other funcs

func BoundToSphere*(self: AABB, center: var Point, radius: var float32): void {.inline.}=
    ## Creates a sphere from a bounding box
    ## Parameters
    ##      self (AABB) : bounding box
    ##      center (var Point) : center of the sphere
    ##      radius (var float) : radius of the sphere
    ## Returns
    ##      computes the center e the radius of the sphere
    center = (self.pMin + self.pMax) / 2.0
    if self.IsPointInside(center):
        radius = Distance(center, self.pMax)
    else:
        radius = float32(0.0)

## ---------------------------------------  STATIC METHODS  -----------------------------------------

func Expand*(_: typedesc[AABB], b: AABB, delta: float32): AABB=
    ## static method for 'Expand' function
    return b.Expand(delta)

func Diagonal*(_: typedesc[AABB], b: AABB): Vector3=
    ## static method for 'Diagonal' function
    return b.Diagonal()

func Intersect*(_: typedesc[AABB], b1, b2: AABB): AABB=
    ## static method for 'Intersect' function
    return b1.Intersect(b2)

func Union*(_: typedesc[AABB], b: AABB, point: Point): AABB=
    ## static method for 'Union' function
    return b.Union(point)

func Union*(_: typedesc[AABB], b1, b2: AABB): AABB=
    ## static method for 'Union' function
    return b1.Union(b2)