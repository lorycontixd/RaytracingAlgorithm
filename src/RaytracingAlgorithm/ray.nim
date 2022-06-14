import geometry, transformation
from utils import IsEqual
import std/[strformat]

type
    Ray* = ref object # light ray propagating in space
        origin*: Point # origin point of the ray
        dir*: Vector3 # direction of ray propagation
        tmin*: float32 # the minimum distance travelled by ray is tmin * dir
        tmax*: float32 # the maximum distance travelled by ray is tmax * dir
        depth*: int #  number of times the ray has been refelcted/refracted
    
proc newRay*(): Ray=
    ## constructor for Ray
    ## Parameters
    ##      \
    ## Returns
    ##      (Ray) : a ray object with 
    ##                  - origin in (0,0,0)
    ##                  - direction : axis x
    ##                  - tmin : set to 10^(-10)
    ##                  - tmax : set to infinite
    ##                  - depth : set to 0
    result = Ray(
        origin: newPoint(0,0,0),
        dir: Vector3.right(),
        tmin: 1e-10,
        tmax: Inf,
        depth:0
    )

proc newRay*(origin:Point, direction: Vector3): Ray=
    ## constructor for Ray
    ## Parameters
    ##      origin (Point): origin point of the ray
    ##      direction (Vector3): direction of ray propagation
    ## Returns
    ##      (Ray) : a ray object with 
    ##                  - origin in origin
    ##                  - direction : direction
    ##                  - tmin : set to 10^(-10)
    ##                  - tmax : set to infinite
    ##                  - depth : set to 0
    result = Ray(
        origin: origin, 
        dir: direction, 
        tmin: 1e-10, 
        tmax: Inf, 
        depth: 0
    )

proc newRay*(origin:Point, direction: Vector3, tmin: float32): Ray=
    ## constructor for Ray
    ## Parameters
    ##      origin (Point): origin point of the ray
    ##      direction (Vector3): direction of ray propagation
    ##      tmin (float32):  (minimum distance travelled by ray) / direction
    ## Returns
    ##      (Ray) : a ray object with 
    ##                  - origin in origin
    ##                  - direction : direction
    ##                  - tmin : tmin
    ##                  - tmax : set to infinite
    ##                  - depth : set to 0
    assert tmin >= 0.0
    result = Ray(
        origin: origin, 
        dir: direction, 
        tmin: tmin, 
        tmax: Inf, 
        depth: 0
    )

proc newRay*(origin:Point, direction: Vector3, tmin, tmax: float32): Ray=
    ## constructor for Ray
    ## Parameters
    ##      origin (Point): origin point of the ray
    ##      direction (Vector3): direction of ray propagation
    ##      tmin, tmax (float32):  (minimum-maximum distance travelled by ray) / direction
    ## Returns
    ##      (Ray) : a ray object with 
    ##                  - origin in origin
    ##                  - direction : direction
    ##                  - tmin : tmin
    ##                  - tmax : tmax
    ##                  - depth : set to 0
    assert tmin >= 0.0
    result = Ray(
        origin: origin, 
        dir: direction, 
        tmin: tmin, 
        tmax: tmax, 
        depth: 0
    )

proc newRay*(origin:Point, direction: Vector3, tmin, tmax: float32, depth: int): Ray=
    ## constructor for Ray
    ## Parameters
    ##      origin (Point): origin point of the ray
    ##      direction (Vector3): direction of ray propagation
    ##      tmin, tmax (float32):  (minimum-maximum distance travelled by ray) / direction
    ##      depth (int): number of times the ray has been refelcted/refracted
    ## Returns
    ##      (Ray) : a ray object with 
    ##                  - origin in origin
    ##                  - direction : direction
    ##                  - tmin : tmin
    ##                  - tmax : tmax
    ##                  - depth : depth
    assert tmin >= 0.0
    result = Ray(
        origin: origin, 
        dir: direction, 
        tmin: tmin, 
        tmax: tmax, 
        depth: depth
    )

proc newRay*(other: Ray): Ray=
    ## Creats a Ray equal to 'other'
    ## Parameters
    ##      other (Ray): Ray object
    ## Returns
    ##      (Ray): a new ray with all parameters set equals to 'other' ones
    result = Ray(
        origin: other.origin, 
        dir: other.dir, 
        tmin: other.tmin, 
        tmax: other.tmax, 
        depth: other.depth
    )

proc at*(self: Ray, t: float32): Point =
    ## Computes the point of ray's path, whose distance from ray's origin is equal to 't'
    ## measured in units of ray's direction
    ## Parameters
    ##      self (Ray)
    ##      t (float32)
    ## Returns
    ##      (Point): point of ray's path
    return self.origin + self.dir * t

proc `[]`*(self:Ray, t: float32): Point=
    ## Computes the point of ray's path, whose distance from ray's origin is equal to 't'
    ## measured in units of ray's direction
    ## Parameters
    ##      self (Ray)
    ##      t (float32)
    ## Returns
    ##      (Point): point of ray's path
    return self.at(t)

proc `==`*(self, other: Ray): bool =
    ## Verifies whether two rays are equal or not
    ## Parameters
    ##      self, other (Ray): rays to be checked
    ## Returns
    ##      (bool): True (if self and other are equals) , False (else)
    return self.origin == other.origin and self.dir == other.dir and self.tmin == other.tmin and self.tmax == other.tmax and self.depth == other.depth

proc `$`*(self: Ray): string=
    return fmt"Ray(origin:{$self.origin}, dir:{$self.dir}, tmin: {$self.tmin}, tmax: {$self.tmax}, depth: {$self.depth})"

proc `isClose`*(self, other: Ray, epsilon: float32 = 1e-4): bool=
    if self.tmax != Inf and other.tmax != Inf:
        return self.origin.isClose(other.origin, epsilon) and self.dir.isClose(other.dir, epsilon) and self.tmin.IsEqual(other.tmin, epsilon) and self.tmax.IsEqual(other.tmax, epsilon) and self.depth == other.depth
    else:
        return self.origin.isClose(other.origin, epsilon) and self.dir.isClose(other.dir, epsilon) and self.tmin.IsEqual(other.tmin, epsilon) and self.depth == other.depth

proc Transform*(self: Ray, transformation: Transformation): Ray =
    result = Ray(
        origin : transformation * self.origin,
        dir :  transformation * self.dir,
        tmin : self.tmin,
        tmax : self.tmax,
        depth : self.depth
    )
