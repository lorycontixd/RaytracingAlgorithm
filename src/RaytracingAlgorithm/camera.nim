import geometry, transformation, ray, exception

type
    CameraType* = enum # abstract class representing an observer
        Orthogonal, Perspective

    Camera* = ref object of RootObj
        aspectRatio*: float32 # (width/height) of the screen, usually 16/9
        transform*: Transformation #to apply to camera
        camType*: CameraType # orthogoanl or perspective

    OrthogonalCamera* = ref object of Camera
    PerspectiveCamera* = ref object of Camera
        distance*: float32 # distance between the observer (Camera) and the screen

# -------------------------------- Constructors -------------------------------------

proc newOrthogonalCamera*(width: int = 800, height: int = 600, transform: Transformation = newTransformation()): OrthogonalCamera {.inline.}=
    ## constructor for orthogonal camera
    ## Parameters
    ##      width, height (int=800, int=600): Width and height of the camera screen
    ##      transform (Transformation) : default: Identity
    ## Returns
    ##      (OrthogonalCamera)
    result = OrthogonalCamera(aspectRatio:float(width/height), transform: transform, camType: CameraType.Orthogonal)

proc newPerspectiveCamera*(width: int = 800, height: int = 600, distance: float32=1.0, transform: Transformation = newTransformation()): PerspectiveCamera {.inline.}=
    ## constructor for perspective camera
    ## Parameters
    ##      width, height (int, int): default_value: 800/600
    ##      distance (float32): default_value: 1.0
    ##      transform (Transformation) : default: Identity
    ## Returns
    ##      (PerspectiveCamera)
    result = PerspectiveCamera(aspectRatio:float(width/height), transform: transform, distance:distance, camType: CameraType.Perspective)

proc newOrthogonalCamera*(aspectratio: float32, transform: Transformation = newTransformation()): OrthogonalCamera {.inline.}=
    ## constructor for orthogonal camera
    ## Parameters
    ##      aspectratio (float32)
    ##      transform (Transformation) : default: Identity
    ## Returns
    ##      (OrthogonalCamera)
    result = OrthogonalCamera(aspectRatio:aspectratio, transform: transform)

proc newPerspectiveCamera*(aspectratio: float32, distance: float32=1.0, transform: Transformation = newTransformation()): PerspectiveCamera {.inline.}=
    ## constructor for perspective camera
    ## Parameters
    ##      aspectratio (float32)
    ##      distance (float32): default_value: 1.0
    ##      transform (Transformation) : default: Identity
    ## Returns
    ##      (PerspectiveCamera)
    result = PerspectiveCamera(aspectRatio:aspectratio, transform: transform, distance:distance)

# -------------------------------- Methods -------------------------------------

# NB: we use (x,y,z) for spatial coordinates and (u,v) for pixels' coordinates
#
#             (1, 0)                          (1,1)
#               +------------------------------+
#               |                              |
#               |                              |
#               |                              |
#               +------------------------------+
#            (0, 0)                          (1, 0)
#


method fireRay*(c: Camera, u,v:float32): Ray {.base, inline, raises:[AbstractMethodError, ValueError].} =
    ## Fires a ray through the camera. This is an abstract method
    raise AbstractMethodError.newException("Camera.fireRay is an abstract method and cannot be called.")

method fireRay*(self: OrthogonalCamera, u,v: float32): Ray {.inline.} =
    ## Method for ORTHOGONAL camera
    ## Fires a ray through the camera's screen at position (u,v)
    ## Parameters
    ##      self (OrthogonalCamera)
    ##      u,v (flaot) : coordinates of screen's point hit by ray
    ## Results
    ##      (Ray)
    var origin: Point = newPoint(-1.0, (1.0 - 2.0 * u) * self.aspectRatio, 2.0*v-1)
    var direction: Vector3 = Vector3.right()
    var ray: Ray = newRay(origin, direction, 0.1)
    result = ray.Transform(self.transform)

method fireRay*(self: PerspectiveCamera, u,v: float32): Ray {.inline.} =
    ## Method for PERSPECTIVE camera
    ## Fires a ray through the camera's screen at position (u,v)
    ## Parameters
    ##      self (OrthogonalCamera)
    ##      u,v (flaot) : coordinates of screen's point hit by ray
    ## Results
    ##      (Ray)
    var origin: Point = newPoint(-self.distance, 0.0, 0.0)
    var direction: Vector3 = newVector3(self.distance, (1.0 - 2.0 * u) * self.aspectRatio, 2.0 * v - 1)
    var ray: Ray = newRay(origin, direction, 0.01, 1000000)
    result = ray.Transform(self.transform)