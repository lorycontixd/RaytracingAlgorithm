import geometry, transformation, ray, exception

type
    CameraType* = enum
        Orthogonal, Perspective

    Camera* = ref object of RootObj
        aspectRatio*: float32
        transform*: Transformation
        camType*: CameraType

    OrthogonalCamera* = ref object of Camera
    PerspectiveCamera* = ref object of Camera
        distance*: float32

# -------------------------------- Constructors -------------------------------------

proc newOrthogonalCamera*(width: int = 800, height: int = 800, transform: Transformation = newTransformation()): OrthogonalCamera {.inline.}=
    result = OrthogonalCamera(aspectRatio:float(width/height), transform: transform, camType: CameraType.Orthogonal)

proc newPerspectiveCamera*(width: int = 800, height: int = 800, distance: float32=1.0, transform: Transformation = newTransformation()): PerspectiveCamera {.inline.}=
    result = PerspectiveCamera(aspectRatio:float(width/height), transform: transform, distance:distance, camType: CameraType.Perspective)

proc newOrthogonalCamera*(aspectratio: float32, transform: Transformation = newTransformation()): OrthogonalCamera {.inline.}=
    result = OrthogonalCamera(aspectRatio:aspectratio, transform: transform)

proc newPerspectiveCamera*(aspectratio: float32, distance: float32=1.0, transform: Transformation = newTransformation()): PerspectiveCamera {.inline.}=
    result = PerspectiveCamera(aspectRatio:aspectratio, transform: transform, distance:distance)

# -------------------------------- Methods -------------------------------------

method fireRay*(c: Camera, u,v:float32): Ray {.base, inline, raises:[AbstractMethodError, ValueError].} =
    raise AbstractMethodError.newException("Camera.fireRay is an abstract method and cannot be called.")

method fireRay*(self: OrthogonalCamera, u,v: float32): Ray {.inline.} =
    var origin: Point = newPoint(-1.0, (1.0 - 2.0 * u) * self.aspectRatio, 2.0*v-1)
    var direction: Vector3 = Vector3.right()
    var ray: Ray = newRay(origin, direction, 0.1)
    result = ray.Transform(self.transform)

method fireRay*(self: PerspectiveCamera, u,v: float32): Ray {.inline.} =
    var origin: Point = newPoint(-self.distance, 0.0, 0.0)
    var direction: Vector3 = newVector3(self.distance, (1.0 - 2.0 * u) * self.aspectRatio, 2.0 * v - 1)
    var ray: Ray = newRay(origin, direction, 0.01, 1000000)
    result = ray.Transform(self.transform)