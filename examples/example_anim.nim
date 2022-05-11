
import RaytracingAlgorithm/[hdrimage, camera, color, geometry, utils, logger, shape, ray, transformation, world, rayhit, imagetracer, exception, renderer, animation]
import std/[segfaults, parsecfg, os, streams, times, options, parseopt, tables, marshal, strutils, strformat]

const
    sphere_count: int = 10
    radius: float32 = 1/10

var cam: Camera
if camera.toLower() == "perspective":
    cam = newPerspectiveCamera(width, height, transform=Transformation.translation(newVector3(-1.0, 0.0, 0.0)))
elif camera.toLower() == "orthogonal":
    cam = newOrthogonalCamera(width, height, transform=Transformation.translation(newVector3(-1.0, 0.0, 0.0)))
else:
    raise TestError.newException("Invalid camera passed to main.")
var
    world: World = newWorld()
    hdrImage: HdrImage = newHdrImage(width, height)
    imagetracer: ImageTracer = newImageTracer(hdrImage, cam)
    onoff: OnOffRenderer = newOnOffRenderer(world, Color.black(), Color.white())
    scale_tranform: Transformation = Transformation.scale(newVector3(0.1, 0.1, 0.1))

world.Add(newSphere("SPHERE_0", Transformation.translation( newVector3(0.5, 0.5, 0.5)) * scale_tranform))
world.Add(newSphere("SPHERE_1", Transformation.translation( newVector3(0.5, 0.5, -0.5)) * scale_tranform))
world.Add(newSphere("SPHERE_2", Transformation.translation( newVector3(0.5, -0.5, 0.5)) * scale_tranform))
world.Add(newSphere("SPHERE_3", Transformation.translation( newVector3(0.5, -0.5, -0.5)) * scale_tranform))
world.Add(newSphere("SPHERE_4", Transformation.translation( newVector3(-0.5, 0.5, 0.5)) * scale_tranform))
world.Add(newSphere("SPHERE_5", Transformation.translation( newVector3(-0.5, 0.5, -0.5)) * scale_tranform))
world.Add(newSphere("SPHERE_6", Transformation.translation( newVector3(-0.5, -0.5, -0.5)) * scale_tranform))
world.Add(newSphere("SPHERE_7", Transformation.translation( newVector3(-0.5, -0.5, 0.5)) * scale_tranform))


