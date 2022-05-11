import camera, geometry, exception
import std/[strutils, hashes]

type
    Screen* = object
        width: int
        height: int
        camera*: Camera
        aspectRatio: float32
    
proc newScreen*(width, height: int): Screen =
    result = Screen(width: width, height: height, camera: newPerspectiveCamera(width, height), aspectRatio: float(width/height))

proc newScreen*(width, height: int, cam: string): Screen=
    var newcam: Camera
    if cam.toLower() == "perspective":
        newcam = newPerspectiveCamera(width, height)
    elif cam.toLower() == "orthogonal":
        newCam = newOrthogonalCamera(width, height)
    else:
        raise TestError.newException("Invalid camera passed to screen constructor.")
    result = Screen(width: width, height: height, camera: newPerspectiveCamera(width, height), aspectRatio: float(width/height))

proc GetAspectRatio*(screen: Screen): float32=
    assert IsEqual(screen.aspectRatio, float(screen.width/screen.height))
    return screen.aspectRatio

proc GetWidth*(screen: Screen): int=
    return screen.width

proc SetWidth*(screen: var Screen, w: int): void=
    screen.width = w
    screen.aspectRatio = float(screen.width / screen.height)

proc GetHeight*(screen: Screen): int=
    return screen.height

proc SetHeight*(screen: var Screen, h: int): void=
    screen.height = h
    screen.aspectRatio = float(screen.width / screen.height)