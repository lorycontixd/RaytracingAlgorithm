import geometry, exception, mathutils
import std/[math, bitops]

type
    Bounds3* = ref object of RootObj
        pMin*, pMax*: Point

func newBounds3*(): Bounds3= discard

func newBounds3*(p: Point): Bounds3=
    return Bounds3(pMin: p, pMax: p)

func newBounds3*(p1, p2: Point): Bounds3=
    let pmin = newPoint(min(p1.x, p2.x), min(p1.y, p2.y), min(p1.z, p2.z))
    let pmax = newPoint(max(p1.x, p2.x), max(p1.y, p2.y), max(p1.z, p2.z))
    return Bounds3(pMin: pmin, pMax: pmax)

# -----------------  Operators  ---------------------
func `[]`*(self: Bounds3, index: int): Point=
    if index==0:
        return self.pMin
    elif index==1:
        return self.pMax
    else:
        raise newException(IndexError, "Invalid indexing value for Bounds3")

func `==`*(lhs, rhs: Bounds3): bool=
    return lhs.pMin.isClose(rhs.pMin) and lhs.pMax.isClose(rhs.pMax)

func `!=`*(lhs, rhs: Bounds3): bool=
    return not (lhs == rhs)

# --------------------  Methods  ------------------------

func Corner*(self: Bounds3, corner: int): Point=
    ##
    return newPoint(
        self[bitand(corner,1)].x,
        self[bitand(corner,2)].y,
        self[bitand(corner,4)].z
    )

func IsPointInside(self: Bounds3, p: Point): bool=
    return (p.x >= self.pMin.x and p.x <= self.pMax.x) and (p.y >= self.pMin.y and p.y <= self.pMax.y) and (p.z >= self.pMin.z and p.z <= self.pMax.z)

func Intersect*(self, other: Bounds3): Bounds3=
    ##
    return newBounds3(
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

func Lerp*(self: Bounds3, p: Point): Point3 {.inline.}=
    ##
    return newPoint(
        Lerp(self.pMin.x, self.pMax.x, p.x),
        Lerp(self.pMin.y, self.pMax.y, p.y),
        Lerp(self.pMin.z, self.pMax.z, p.z)
    )

func Union*(self: Bounds3, newpoint: Point): Bounds3=
    return newBounds3(
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

func Union*(self: Bounds3, other: Bounds3): Bounds3=
    ##
    return newBounds3(
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