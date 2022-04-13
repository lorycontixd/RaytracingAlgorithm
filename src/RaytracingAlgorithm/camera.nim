import geometry

type
    Camera* = ref object of RootObj
        aspectRatio: float32

    OthogonalCamera* = ref object of Camera
    PerspectiveCamera* = ref object of Camera

method fire_ray(c: Camera): void {.base.} =
    quit "to override!"

method fire_ray(self: OthogonalCamera, u,v: float32): void {.inline.} =
    var origin: Point = newPoint(-1.0, (1.0 - 2.0 * u) * self.aspectRatio, 2.0*v-1)