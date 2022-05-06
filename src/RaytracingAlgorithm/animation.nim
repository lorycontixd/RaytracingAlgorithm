import camera, color, geometry, quaternion, world, transformation, hdrimage, imagetracer, renderer
import std/[os, strformat, options, streams]

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
    var
        onoff: OnOffRenderer = newOnOffRenderer(self.world, Color.black(), Color.white())
        baseTranslation: Transformation = Transformation.translation(self.start_pos)
        rotation: Quaternion = VectorRotation(self.start_pos, self.end_pos)
    var
        vec: Vector3
        q: Quaternion
        cam: Camera
        
    for i in countup(0, self.nframes-1):
        let t = float32(i / (self.nframes-1))
        
        q = rotation * t
        var transform: Transformation = baseTranslation * newTransformation( q.toRotationMatrix(), q.toRotationMatrix().inverse() )
        if self.camType == CameraType.Orthogonal:
            cam = newOrthogonalCamera(self.width, self.height, transform)
        elif self.camType == CameraType.Perspective:
            cam = newPerspectiveCamera(self.width, self.height, 1.0, transform)

        var
            hdrImage: HdrImage = newHdrImage(self.width, self.height)
            imagetracer: ImageTracer = newImageTracer(hdrImage, cam)
        
        imagetracer.fireAllRays(onoff.Get())
        self.frames.add(imagetracer)
    self.hasPlayed = true


proc Save*(self: var Animation, debug: bool = false): void=
    #[
        ffmpeg -r 25 -f image2 -s 640x480 -i img%03d.png \
        -vcodec libx264 -pix_fmt yuv420p \
        spheres-perspective.mp4
    ]#
    ## Directory 
    if not self.hasPlayed:
        return
    var dirName: string = "temp"
    createDir(dirName)

    for i in countup(0, len(self.frames)-1):
        var tracer: ImageTracer = self.frames[i]
        let outputFile = joinPath(dirName, fmt"image_{i}")
        if debug:
            echo "--> Saving image to outputFile"
        var strmWrite = newFileStream("output.pfm", fmWrite)
        tracer.image.write_pfm(strmWrite)
        tracer.image.normalize_image(1.0)
        tracer.image.clamp_image()
        tracer.image.write_png(outputFile, 1.0)
        
    
    var cmd: string = fmt"ffmpeg -r {self.framerate} -f image2 -s {self.width}x{self.height} -i temp/%03d.png -vcodec libx264 -pix_fmt yuv420p video_{$self.camType}.mp4"
    discard execShellCmd(cmd)

proc Show*(self: Animation) = discard

        


    