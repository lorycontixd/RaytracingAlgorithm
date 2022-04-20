import geometry, transformation, ray

type
    Camera* = ref object of RootObj
        aspectRatio*: float32
        transform*: Transformation

    OrthogonalCamera* = ref object of Camera
    PerspectiveCamera* = ref object of Camera
        distance*: float32


proc newOrthogonalCamera*(aspectratio: float32, transform: Transformation = newTransformation()): OrthogonalCamera {.inline.}=
    result = OrthogonalCamera(aspectRatio:aspectratio, transform: transform)

proc newPerspectiveCamera*(aspectratio: float32, distance: float32=1.0, transform: Transformation = newTransformation()): PerspectiveCamera {.inline.}=
    result = PerspectiveCamera(aspectRatio:aspectratio, transform: transform, distance:distance)

method fireRay*(c: Camera, u,v:float32): Ray {.base.} =
    quit "to override!"

method fireRay*(self: OrthogonalCamera, u,v: float32): Ray {.inline.} =
    var origin: Point = newPoint(-1.0, (1.0 - 2.0 * u) * self.aspectRatio, 2.0*v-1)
    var direction: Vector = Vector.right()
    var ray: Ray = newRay(origin, direction, 1.0)
    result = ray.Transform(self.transform)

method fireRay*(self: PerspectiveCamera, u,v: float32): Ray {.inline.} =
    var origin: Point = newPoint(-self.distance, 0.0, 0.0)
    var direction: Vector = newVector(self.distance, (1.0 - 2.0 * u) * self.aspectRatio, 2.0 * v - 1)
    var ray: Ray = newRay(origin, direction, 1.0)
    result = ray.Transform(self.transform)