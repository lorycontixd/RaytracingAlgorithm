
import RaytracingAlgorithm/[hdrimage, camera, color, geometry, utils, logger, shape, ray, transformation, world, rayhit, imagetracer, exception, screen, renderer]
import std/[segfaults, parsecfg, os, streams, times, options, parseopt, tables, marshal, strutils, strformat]
import cligen

proc render(width: int = 800, height: int = 600, camera: string = "perspective", output_filename = "output", pfm_output=true, png_output=false): auto=
    const
        sphere_count: int = 10

    var cam: Camera
    if camera.toLower() == "perspective":
        cam = newPerspectiveCamera(width, height, transform=Transformation.translation(newVector3(1.0, 0.0, 0.0)))
    elif camera.toLower() == "orthogonal":
        cam = newOrthogonalCamera(width, height, transform=Transformation.translation(newVector3(0.0, 0.0, 0.0)))
    else:
        raise TestError.newException("Invalid camera passed to main.")

    var
        world: World = newWorld()
        hdrImage: HdrImage = newHdrImage(width, height)
        imagetracer: ImageTracer = newImageTracer(hdrImage, cam)
        onoff: OnOffRenderer = newOnOffRenderer(world, Color.black(), Color.white())
    
    for i in countup(0, sphere_count-1):
        let id = fmt"SPHERE_{i}"
        world.Add(newSphere(id, newVector3(float32(i), float(i), 0.0)))
    
    imagetracer.fireAllRays(onoff.Get())

    var strmWrite = newFileStream("output.pfm", fmWrite)
    imagetracer.image.write_pfm(strmWrite)

    imagetracer.image.normalize_image(1.0)
    imagetracer.image.clamp_image()
    imagetracer.image.write_png("output.png", 1.0)

    

proc pfm2png(yippee: int, myFlts: seq[float], verb=false) = discard
    # to implement

when isMainModule:
    addLogger( open( joinPath(getCurrentDir(), "main.log"), fmWrite))
    info("Running RaytracingAlgorithm on version ",getPackageVersion())
    debug("Creating variables")

    dispatchMulti(
        [render, help = {
            "width" : "Screen width in pixels",
            "height" : "Screen height in pixels",
            "camera": "Select the viewer camera for scene rendering [orthogonal/perspective]",
            "output_filename": "Name of the rendered output image",
            "pfm_output": "Save a PFM image",
            "png_output": "Save a PNG"
        }],
        [pfm2png ] # pfm2png options to add
    )

    