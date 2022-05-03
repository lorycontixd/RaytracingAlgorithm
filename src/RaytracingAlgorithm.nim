
import RaytracingAlgorithm/[hdrimage, geometry, utils, logger, shape, ray, transformation, world, rayhit, imagetracer, exception, screen]
import std/[parsecfg, os, streams, times, options, parseopt, tables, marshal]
import cligen

proc render(width: int = 800, height: int = 600, camera: string = "perspective", output_filename = "output", pfm_output=true, png_output=false): auto=
  let
    screen = newScreen(width, height, camera)
    world = newWorld()

proc pfm2png(yippee: int, myFlts: seq[float], verb=false) = discard
    

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
        [pfm2png ]
    )

    