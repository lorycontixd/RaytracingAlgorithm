import camera, color, geometry, quaternion, logger, world, transformation, hdrimage, imagetracer, renderer
import std/[os, strformat, options, streams, marshal]

type
    Animation* = ref object
        start_pos*: Vector3
        end_pos*: Vector3
        width*: int
        height*: int
        camType*: CameraType
        world*: World
        duration_sec*: int
        framerate*: int
        nframes*: int
        
        # internal
        frames*: seq[ImageTracer]
        hasPlayed: bool
    

proc newAnimation*(startpos, end_pos: Vector3, camType: CameraType, width,height: int, world: var World, duration_sec: int = 10, framerate: int = 60): Animation=
    result = Animation(start_pos: startpos, end_pos: end_pos, camType: camType, width: width, height: height, world: world, duration_sec: duration_sec, framerate: framerate, nframes: duration_sec*framerate,  hasPlayed: false)



proc Play*(self: var Animation): void=
    info("Starting animation")
    info("Framerate: ",self.framerate)
    info("Duration: ",self.duration_sec)
    info("Camera Type: ",self.camType)
    var rotation: Quaternion = Quaternion.VectorRotation(self.start_pos, self.end_pos)

    for i in countup(0, self.nframes-1):
        let
            t = float32(i / (self.nframes-1))
            q = rotation * t
        var
            cam = newPerspectiveCamera(self.width, self.height, transform=Transformation.translation(self.start_pos) * Transformation.rotationX(360.0 * t))
            hdrImage: HdrImage = newHdrImage(self.width, self.height)
            imagetracer: ImageTracer = newImageTracer(hdrImage, cam)
            onoff: OnOffRenderer = newOnOffRenderer(self.world, Color.black(), Color.white())
        
        imagetracer.fireAllRays(onoff.Get())
        let lum = imagetracer.image.average_luminosity()
        debug(fmt"Created image {i+1}/{self.nframes} - Average Luminosity: {lum}")
        self.frames.add(imagetracer)



proc Save*(self: var Animation): void=
    info("Found ",len(self.frames)," frames to save")
    var dirName: string = "temp"
    createDir(dirName)
    debug("Created temporary output folder: ",dirName)

    var i: int = 0
    for frame in self.frames:
        var img = frame.image
        img.normalize_image(1.0)
        img.clamp_image()
        var savePath: string = joinPath(dirName, fmt"output_{i}.png")
        img.write_png(savePath, 1.0)
        debug("Written temporary PNG: ",savePath)
        i = i + 1
    var cmd: string = fmt"ffmpeg - framerate {self.framerate} -pattern_type glob -i 'temp/*.png' -c:v libx264 -pix_fmt yuv420p out.mp4"
    let res = execShellCmd(cmd)
    debug("FFmpeg command called, return status: ",res)
    if res = 0:
        let res2 = execShellCmd("rm -rf temp/")
        debug("Temporary folder deleted, return status: ",res2)



proc Show*(self: Animation) = discard

        


    