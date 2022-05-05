import camera, geometry, quaternion


type
    Animation* = ref object
        start_pos*: Vector3
        end_pos*: Vector3
        world*: World
        duration_sec*: int
        framerate*: int
        nframes*: int
    

proc newAnimation*(cam: Camera, world: var World, duration_sec: int = 10, framerate: int = 60): Animation=
    result = Animation(camera: cam, world: world, duration_sec: duration_sec, framerate: framerate, nframes: duration_sec*framerate)

proc Play(self: Animation): void=
    for i in countup(0, self.nframes-1):

    