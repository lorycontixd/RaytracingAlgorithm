
import RaytracingAlgorithm/[hdrimage, camera, color, geometry, utils, logger, shape, ray, transformation, world, rayhit, imagetracer, exception, renderer]
import std/[segfaults, parsecfg, os, streams, times, options, parseopt, tables, marshal, strutils, strformat]
import cligen

proc render(width: int = 800, height: int = 600, camera: string = "perspective", output_filename = "output", pfm_output=true, png_output=false): auto=
    logLevel = Level.debug
    const
        sphere_count: int = 10
        radius: float32 = 1/10

    var cam: Camera
    if camera.toLower() == "perspective":
        cam = newPerspectiveCamera(width, height, transform=Transformation.translation(newVector3(-1.0, 0.0, 0.0)))
    elif camera.toLower() == "orthogonal":
        cam = newOrthogonalCamera(width, height)
    else:
        raise TestError.newException("Invalid camera passed to main.")
    debug(fmt"Instantiating {camera} camera with screen size {width}x{height}")
    var
        world: World = newWorld()
        hdrImage: HdrImage = newHdrImage(width, height)
        imagetracer: ImageTracer = newImageTracer(hdrImage, cam)
        onoff: OnOffRenderer = newOnOffRenderer(world, Color.black(), Color.white())
        scale_tranform: Transformation = Transformation.scale(newVector3(0.1, 0.1, 0.1))

    debug(fmt"Using renderer: OnOffRenderer")
    #[
    world.Add(newSphere("SPHERE_0", newPoint(0.5, 0.5, 0.5), radius=radius))
    world.Add(newSphere("SPHERE_1", newPoint(0.5, 0.5, -0.5), radius=radius))
    world.Add(newSphere("SPHERE_2", newPoint(0.5, -0.5, 0.5), radius=radius))
    world.Add(newSphere("SPHERE_3", newPoint(0.5, -0.5, -0.5), radius=radius))
    world.Add(newSphere("SPHERE_4", newPoint(-0.5, 0.5, 0.5), radius=radius))
    world.Add(newSphere("SPHERE_5", newPoint(-0.5, 0.5, -0.5), radius=radius))
    world.Add(newSphere("SPHERE_6", newPoint(-0.5, -0.5, -0.5), radius=radius))
    world.Add(newSphere("SPHERE_7", newPoint(-0.5, -0.5, 0.5), radius=radius))
    ]#

    world.Add(newSphere("SPHERE_0", Transformation.translation( newVector3(0.5, 0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_1", Transformation.translation( newVector3(0.5, 0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_2", Transformation.translation( newVector3(0.5, -0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_3", Transformation.translation( newVector3(0.5, -0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_4", Transformation.translation( newVector3(-0.5, 0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_5", Transformation.translation( newVector3(-0.5, 0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_6", Transformation.translation( newVector3(-0.5, -0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_7", Transformation.translation( newVector3(-0.5, -0.5, 0.5)) * scale_tranform))

    #echo $$onoff.world
    #world.Add(newSphere(origin=newPoint(5.0, 0.0, 0.0), radius=100))

    imagetracer.fireAllRays(onoff.Get())

    var strmWrite = newFileStream("output.pfm", fmWrite)
    hdrImage.write_pfm(strmWrite)

    hdrImage.normalize_image(1.0)
    hdrImage.clamp_image()
    hdrImage.write_png("output.png", 1.0)

    

proc pfm2png(yippee: int, myFlts: seq[float], verb=false) = discard
    # to implement

when isMainModule:
    addLogger( open( joinPath(getCurrentDir(), "main.log"), fmWrite)) # For file logging
    #addLogger( stdout ) # For console logging

    info("Running RaytracingAlgorithm on version ",getPackageVersion())
    debug("Parsing command-line arguments")

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

    