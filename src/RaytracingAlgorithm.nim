
import RaytracingAlgorithm/[hdrimage, animation, camera, color, geometry, utils, logger, shape, ray, transformation, world, rayhit, imagetracer, exception, renderer]
import std/[segfaults, parsecfg, os, streams, times, options, parseopt, tables, marshal, strutils, strformat, locks]
import cligen

proc render(width: int = 800, height: int = 600, camera: string = "perspective", output_filename = "output", pfm_output=true, png_output=false): auto=
    ## 
    
    logLevel = Level.debug
    const
        sphere_count: int = 10
        radius: float32 = 0.1

    var cam: Camera
    if camera.toLower() == "perspective":
        cam = newPerspectiveCamera(width, height, transform=Transformation.translation(newVector3(-1.0, 0.0, 0.0)))
    elif camera.toLower() == "orthogonal":
        cam = newOrthogonalCamera(width, height, transform=Transformation.translation(newVector3(-1.0, 0.0, 0.0)))
    else:
        raise TestError.newException("Invalid camera passed to main.")
    debug(fmt"Instantiating {camera} camera with screen size {width}x{height}")
    var
        world: World = newWorld()
        hdrImage: HdrImage = newHdrImage(width, height)
        imagetracer: ImageTracer = newImageTracer(hdrImage, cam)
        onoff: OnOffRenderer = newOnOffRenderer(world, Color.black(), Color.white())
        scale_tranform: Transformation = Transformation.scale(newVector3(0.1, 0.1, 0.1))
    
    debug("Starting rendering script at ",now())
    debug(fmt"Using renderer: OnOffRenderer")

    world.Add(newSphere("SPHERE_0", Transformation.translation( newVector3(0.5, 0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_1", Transformation.translation( newVector3(0.5, 0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_2", Transformation.translation( newVector3(0.5, -0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_3", Transformation.translation( newVector3(0.5, -0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_4", Transformation.translation( newVector3(-0.5, 0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_5", Transformation.translation( newVector3(-0.5, 0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_6", Transformation.translation( newVector3(-0.5, -0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_7", Transformation.translation( newVector3(-0.5, -0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_8", Transformation.translation( newVector3(-0.5, 0.0, -0.5)) * scale_tranform))

    ### Save image!!
    imagetracer.fireAllRays(onoff.Get())
    var strmWrite = newFileStream("output.pfm", fmWrite)
    imagetracer.image.write_pfm(strmWrite)
    imagetracer.image.normalize_image(1.0)
    imagetracer.image.clamp_image()
    imagetracer.image.write_png("output.png", 1.0)



proc animate(width: int = 800, height: int = 600, camera: string = "perspective", dontDeleteFrames: bool = false): void=
    let start = cpuTime()
    logLevel = Level.debug
    debug("Starting animating script at ",now())
    var
        world: World = newWorld()
        scale_tranform: Transformation = Transformation.scale(newVector3(0.1, 0.1, 0.1))
    debug(fmt"Using renderer: OnOffRenderer")

    world.Add(newSphere("SPHERE_0", Transformation.translation( newVector3(0.5, 0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_1", Transformation.translation( newVector3(0.5, 0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_2", Transformation.translation( newVector3(0.5, -0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_3", Transformation.translation( newVector3(0.5, -0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_4", Transformation.translation( newVector3(-0.5, 0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_5", Transformation.translation( newVector3(-0.5, 0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_6", Transformation.translation( newVector3(-0.5, -0.5, -0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_7", Transformation.translation( newVector3(-0.5, -0.5, 0.5)) * scale_tranform))
    world.Add(newSphere("SPHERE_8", Transformation.translation( newVector3(-0.5, 0.0, -0.5)) * scale_tranform))

    var animator: Animation = newAnimation(
        Transformation.translation(-2.0, 0.0, 0.0) * Transformation.rotationX(90.0),
        Transformation.translation(-2.0, 0.0, 0.0) * Transformation.rotationX(180.0),
        CameraType.Perspective,
        width, height,
        world,
        4,
        10
    )
    animator.Play()
    animator.Save(dontDeleteFrames)
    let endTIme = cpuTime() - start
    info(fmt"Animation executed in {endTime}")


 
proc pfm2png(factor: float32 = 0.7, gamma:float32 = 1.0, input_filename: string, output_filename:string){.inline.} =
    if not input_filename.endsWith(".pfm"):
        raise InvalidFormatError.newException(fmt"Invalid input file for conversion: {input_filename}. Must be PFM file.")
    if not output_filename.endsWith(".png"):
        raise InvalidFormatError.newException(fmt"Invalid output file for conversion: {output_filename}. Must be PNG file.")
    var image : HdrImage = newHdrImage()
    var fileStream: FileStream = newFileStream(input_filename, fmRead)
    image.read_pfm(fileStream)
    debug("File" ,input_filename, "has been read from disk")
    info("Created HdrImage from inputfile ", input_filename, " for pfm2png conversion")

    let luminosity = image.average_luminosity()
    image.normalize_image(factor, some(luminosity))
    image.clamp_image()

    image.write_png(output_filename)
    debug("File", output_filename, "has been written to disk")



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
        [pfm2png, help = {
            "factor" : "Multiplicative factor",
            "gamma" : "Exponent for gamma-correction",
            "input_filename" : "PFM file name in input  ",
            "output_filename" : "PNG file name in output"
        }],
        [animate] 
    )

    
