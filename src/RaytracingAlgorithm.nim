import RaytracingAlgorithm/[hdrimage, animation, camera, color, geometry, utils, logger, shape, ray, transformation, world, imagetracer, exception, renderer, pcg, material, stats, triangles, parser, scene, postprocessing]
import std/[segfaults, os, streams, times, options, tables, strutils, strformat, threadpool, marshal]
import cligen

proc demo(name: string, width: int = 800, height: int = 600): auto =
    logLevel = Level.debug
    case name:
        of "9-spheres": 
            let start = cpuTime()
            info("Starting rendering of '9-spheres' demo scene")
            const
                sphere_count: int = 10
                radius: float32 = 0.1

            var cam: Camera = newPerspectiveCamera(width, height, transform=Transformation.translation(newVector3(-1.0, 0.0, 0.0)))
            debug(fmt"Instantiating perspective camera with screen size {width}x{height}")
            var
                world: World = newWorld()
                hdrImage: HdrImage = newHdrImage(width, height)
                tracer: ImageTracer = newImageTracer(hdrImage, cam)
                onoff: OnOffRenderer = newOnOffRenderer(world, Color.black(), Color.white())
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

            ### Save image!!
            tracer.fireAllRays(onoff.Get())
            var strmWrite = newFileStream("output.pfm", fmWrite)
            tracer.image.write_pfm(strmWrite)
            var tonemapping: ToneMapping = newToneMapping(1.0)
            tonemapping.eval(tracer.image)
            tracer.image.write_png("output.png", 1.0)
            let endTime = cpuTime() - start
            mainStats.closeStats()
            mainStats.Show()

        of "materials":
            info("Starting rendering of 'materials' demo scene")
            let start = now()
            var cam: Camera = newPerspectiveCamera(width, height, transform=Transformation.translation(newVector3(-1.0, 0.0, 1.0)))
            var
                w: World = newWorld()
                img: HdrImage = newHdrImage(width, height)
                pcg: PCG = newPCG()
                tracer:  ImageTracer = newImageTracer(img, cam)
                render: Renderer = newPathTracer(w, Color.blue(), pcg, 5, 6, 4)
                scale_tranform: Transformation = Transformation.scale(newVector3(0.1, 0.1, 0.1)) * Transformation.rotationY(-10.0)

            var
                sky_material = newMaterial(
                    newDiffuseBRDF(newUniformPigment(Color.black())),
                    newUniformPigment(newColor(1.0, 0.9, 0.5)) # ielou
                )

                ground_material = newMaterial(
                    newDiffuseBRDF(newCheckeredPigment(newColor(0.3, 0.5, 0.1), newColor(0.1, 0.2, 0.5)))
                )

                sphere_material = newMaterial(
                    #newDiffuseBRDF(newUniformPigment(newColor(0.3, 0.4, 0.8)))
                    newPhongBRDF(newUniformPigment(newColor(0.3, 0.4, 0.8)) , 2500.0, 0.4, 0.6 )
                    #newSpecularBRDF(newUniformPigment(newColor(0.3, 0.4, 0.8)))
                    #newCookTorranceBRDF(newUniformPigment(newColor(0.3, 0.4, 0.8)), ndf = CookTorranceNDF.GGX)
                )

                mirror_material = newMaterial(
                    newSpecularBRDF(newUniformPigment(newColor(0.6, 0.2, 0.3)))
                )
            w.Add(newSphere("SPHERE_0", Transformation.scale(200.0, 200.0, 200.0) * Transformation.translation(0.0, 0.0, 0.4), sky_material))
            w.Add(newPlane("PLANE_0", Transformation.translation(0.0, 0.0, 0.0), ground_material))
            w.Add(newSphere("SPHERE_1", Transformation.translation(0.0, 0.0, 1.5), sphere_material))
            w.Add(newSphere("SPHERE_2", Transformation.translation(1.0, 2.5, 0.0), mirror_material)) 
            tracer.fireAllRays(render.Get(), true, 1)
            var strmWrite = newFileStream("output.pfm", fmWrite)
            
            tracer.image.write_pfm(strmWrite)
            var tonemapping: ToneMapping = newToneMapping(1.0)
            var blur: GaussianBlur = newGaussianBlur(1)
            tonemapping.eval(tracer.image)
            blur.eval(tracer.image)
            tracer.image.write_png("output.png", 1.0)
            let endTime = now() - start
            echo $endTIme

        of "mesh":
            info("Starting rendering of 'mesh' demo scene")
            let start = now()
            var cam: Camera = newPerspectiveCamera(width, height, transform=Transformation.translation(newVector3(-1.0, 0.0, 1.0)))
            var
                w: World = newWorld()
                img: HdrImage = newHdrImage(width, height)
                pcg: PCG = newPCG()
                tracer:  ImageTracer = newImageTracer(img, cam)

                #render: Renderer = newPathTracer(w, Color.blue(), pcg, 2, 2, 2)
                render: Renderer = newFlatRenderer(w, Color.black())
                #render: Renderer = newPointlightRenderer(w, Color.black(), Color.blue())
                scale_tranform: Transformation = Transformation.scale(newVector3(0.1, 0.1, 0.1)) * Transformation.rotationY(-10.0)

            var
                key_mesh: TriangleMesh = newTriangleMeshOBJ(newTransformation(), "../media/objs/key/key.obj")
                key_triangles: seq[MeshTriangle] = CreateTriangleMesh(key_mesh)
                key_mat_img = newHdrImage()
                strm: FileStream = newFileStream("../media/objs/key/keyB_tx.pfm", fmRead)
            key_mat_img.read_pfm(strm)


            var
                sky_material = newMaterial(
                    newDiffuseBRDF(newUniformPigment(Color.black())),
                    newUniformPigment(newColor(1.0, 0.9, 0.5)) # ielou
                )

                ground_material = newMaterial(
                    newDiffuseBRDF(newCheckeredPigment(newColor(0.3, 0.5, 0.1), newColor(0.1, 0.2, 0.5)))
                )

                sphere_material = newMaterial(
                    #newDiffuseBRDF(newUniformPigment(newColor(0.3, 0.4, 0.8)))
                    #newPhongBRDF(newUniformPigment(newColor(0.3, 0.4, 0.8)) , 600.0, 0.1, 0.9 )
                    #newSpecularBRDF(newUniformPigment(newColor(0.3, 0.4, 0.8)))
                    newCookTorranceBRDF(newUniformPigment(newColor(0.3, 0.4, 0.8)), ndf = CookTorranceNDF.GGX)
                )

                mirror_material = newMaterial(
                    newSpecularBRDF(newUniformPigment(newColor(0.6, 0.2, 0.3)))
                )

                keypigment = newImagePigment(key_mat_img)
                keymaterial = newMaterial(newDiffuseBRDF(newUniformPigment()), keypigment)
            
            for t in key_triangles:
                w.Add(t)
            tracer.fireAllRays(render.Get())
            var strmWrite = newFileStream("output.pfm", fmWrite)
            tracer.image.write_pfm(strmWrite)
            var tonemapping: ToneMapping = newToneMapping(1.0)
            tonemapping.eval(tracer.image)
            tracer.image.write_png("output.png", 1.0)
            let endTime = now() - start
            #mainStats.Show()



proc render(filename: string, width: int = 800, height: int = 600, pcg_state: int = 42, output_filename = "output", png_output = true): auto =
    let start = now()
    info(fmt"Starting rendering of scene from file {filename}")
    var strm: FileStream = newFileStream(filename, fmRead)
    if strm.isNil:
        echo getCurrentDir()
        fatal(fmt"File {filename} does not exist.")
        raise TestError.newException(fmt"File {filename} does not exist.")
    
    var
        pcg: PCG = newPCG(cast[uint64](pcg_state))
        inputstrm: InputStream = newInputStream(strm, newSourceLocation(filename))
        scene: Scene = ParseScene(inputstrm)

    if scene.settings.useLogger:
        for log in scene.settings.loggers:
            addLogger(log)
    
    var finalWidth: int = (if scene.settings.hasDefinedWidth: scene.settings.width else: width)
    var finalHeight: int = (if scene.settings.hasDefinedHeight: scene.settings.height else: height)
    
  

    var
        img: HdrImage = newHdrImage(finalWidth, finalHeight)
        imagetracer: ImageTracer = newImageTracer(img, scene.camera)

    useStats = scene.settings.useStats

    if scene.parseTimeLogs.len() > 0:
        for lvl in scene.parseTimeLogs.keys:
            for msg in scene.parseTimeLogs[lvl]:
                case lvl:
                    of logger.Level.debug:
                        debug(msg)
                    of logger.Level.info:
                        info(msg)
                    of logger.Level.warn:
                        warn(msg)
                    of logger.Level.error:
                        error(msg)
                    of logger.Level.fatal:
                        fatal(msg)

    ### Save image!!
    if scene.settings.isAnimated:
        var animation: Animation = newAnimation(scene)
        animation.Play()
        animation.Save()
    else:
        imagetracer.fireAllRays(scene.renderer.Get(), scene.settings.useAntiAliasing, scene.settings.antiAliasingRays)
        info(fmt"Shot a total of {scene.renderer.raysShot} rays")
        var strmWrite = newFileStream(fmt"{output_filename}.pfm", fmWrite)
        if scene.settings.usePostProcessing:
            for effect in scene.settings.postProcessingEffects:
                effect.eval(imagetracer.image)

        imagetracer.image.write_pfm(strmWrite)
        info("Image saved to ",output_filename,".pfm")
        if png_output:
            info("Image saved to ",output_filename,".png")
            imagetracer.image.write_png(fmt"{output_filename}.png", 1.1)
    let endTime = now() - start
    info(fmt"Rendering completed in {$endTime}")
    #mainStats.closeStats()

proc pfm2png(inputfile: string, outputfile:string, factor: float32 = 0.7, gamma:float32 = 1.0){.inline.} =
    logLevel = Level.debug
    info(fmt"Starting conversion of file {inputfile} to {outputfile}")
    if not inputfile.endsWith(".pfm"):
        raise InvalidFormatError.newException(fmt"Invalid input file for conversion: {inputfile}. Must be PFM file.")
    if not outputfile.endsWith(".png"):
        raise InvalidFormatError.newException(fmt"Invalid output file for conversion: {outputfile}. Must be PNG file.")
    var image : HdrImage = newHdrImage()
    var fileStream: FileStream = newFileStream(inputfile, fmRead)
    image.read_pfm(fileStream)
    debug("File" ,inputfile, "has been read from disk")

    var luminosity: float32 = image.average_luminosity()
    debug(fmt"Average luminosity of inputfile is {luminosity}")
    var tonemapping: ToneMapping = newToneMapping(1.0)
    tonemapping.eval(image)

    luminosity = image.average_luminosity()
    debug(fmt"Average luminosity of inputfile is {luminosity}")
    image.write_png(outputfile)
    debug("File", outputfile, "has been written to disk")



when isMainModule:
    when compileOption("profiler"):
        import nimprof

    let pkgVersion = getPackageVersion()
    if pkgVersion.isSome:
        info("Running RaytracingAlgorithm on version ",pkgVersion)
    else:
        info("Running RaytracingAlgorithm")
    debug("Parsing command-line arguments")

    dispatchMulti(
        [demo, help={

        }],
        [render, help = {
            "filename" : "Scene text file to be parsed",
            "width" : "Screen width in pixels",
            "height" : "Screen height in pixels",
            "pcg_state" : "Initial state of the random number generator",
            "output_filename": "Name of the rendered output image",
            "png_output": "Save a PNG"
        }],
        [pfm2png, help = {
            "factor" : "Multiplicative factor",
            "gamma" : "Exponent for gamma-correction",
            "inputfile" : "PFM file name in input  ",
            "outputfile" : "PNG file name in output"
        }]
    )