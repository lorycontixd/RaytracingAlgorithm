import camera, mathutils, color, geometry, quaternion, logger, world, transformation, settings, hdrimage, imagetracer, renderer, matrix, animator, scene, postprocessing, exception
import std/[os, strformat, strutils, terminal]
#[
type
    Animation* = object
        start_transform*: Transformation
        end_transform*: Transformation
        width*: int
        height*: int
        camType*: CameraType
        render*: Renderer
        world*: World
        duration_sec*: int
        framerate*: int
        nframes: int
        
        # internal
        frames*: seq[ImageTracer]
        hasPlayed: bool
        hasRotation: bool # if initial state rotation and final state rotation are different
        actuallyAnimated: bool

        translations: seq[Vector3]
        rotations: seq[Quaternion]
        scales: seq[Matrix]

        ## --------  Class for playing animations --------
        ## An animation is a collection of images (frames) played sequentially.
        ## The animation is 'duration_sec' long and has a total number of frames dictated by 'duration_sec'x'framerate'.
        ## The scene is gi
        ## 
        ## Parameters:
        ## - start_pos (Vector3): The starting position of the scene's camera
        ## - end_pos (Vector3): The ending position of the scene's camera
        ## - width (int): The width of the frames in pixels
        ## - height (int): The height of the frames in pixels
        ## - camType (camera.CameraType): The type of camera that views the scene -> Perspective or orthogonal
        ## - world (world.World): Reference to the world scene containing all shapes
        ## - duration_sec (int): Duration of the animation in seconds
        ## - framerate (int): Number of frames per second
    


# ----------- Getters & Setters -----------

func GetNFrames(self: Animation): int=
    assert self.nframes == self.duration_sec * self.framerate
    return self.nframes

# ------------------------------------------------ Methods -----------------------------------------------------------------


# ----------- Constructors -----------

proc newAnimation*(start_transform, end_transform: Transformation, camType: CameraType, render: Renderer, width,height: int, world: var World, duration_sec: int = 10, framerate: int = 60): Animation=
    result = Animation(start_transform: start_transform, end_transform: end_transform, camType: camType, render: render, width: width, height: height, world: world, duration_sec: duration_sec, framerate: framerate, nframes: duration_sec*framerate,  hasPlayed: false)
    result.translations = newSeq[Vector3](2)
    result.rotations = newSeq[Quaternion](2)
    result.scales = newSeq[Matrix](2)
    result.actuallyAnimated = (start_transform != end_transform)
    Decompose(result.start_transform.m, result.translations[0], result.rotations[0], result.scales[0])
    Decompose(result.end_transform.m, result.translations[1], result.rotations[1], result.scales[1])

# ----------------- Animation Methods

proc Interpolate*(self: var Animation, t: float32, debug: bool = false): Transformation {.inline.}=
    if not self.actuallyAnimated or t <= 0.0:
        return self.start_transform
    if t >= float32(self.duration_sec):
        return self.end_transform
    var dt: float32 = t / float32(self.duration_sec)
    # Interpolate translation at _dt_
    var trans: Vector3 = (1.0 - dt) * self.translations[0] + dt * self.translations[1]
    if debug:
        echo "Translation:"
        echo $trans,"\n"
    # Interpolate rotation at _dt_
    var rotate: Quaternion = Slerp(self.rotations[0], self.rotations[1], dt)
    if debug:
        echo "Rotation:"
        echo $rotate,"\n"
        echo "\n"
    # Interpolate scale at _dt_
    var scale: Matrix = Zeros()
    for i in countup(0,3):
        for j in countup(0,3):
            scale[i,j] = Lerp(self.scales[0][i,j], self.scales[1][i,j], dt)
    if debug:
        echo "Scale:"
        scale.Show()
        echo "\n"

    let
        transTranform = Transformation.translation(trans)
        rotTransform = newTransformation(rotate.ToRotation())
        scaleTransform = newTransformation(scale)
    # Compute interpolated matrix as product of interpolated components
    return transTranform * rotTransform * scaleTransform

proc Play*(self: var Animation): void=
    ## Plays an animation and stores the frames in memory.

    info("Starting animation ")
    info("Framerate: ",self.framerate)
    info("Duration: ",self.duration_sec)
    info("Camera Type: ",self.camType)
    info("Estimated frames to be produces: ", self.GetNFrames())

    for i in countup(0, self.nframes-1):
        let
            t = float32(i / (self.nframes - 1)) * float32(self.duration_sec)
            transform = self.Interpolate(t, false)
            percentage = int(float32(i)/float32(self.nframes-1) * 100.0)

        stdout.styledWriteLine(fgRed, fmt"{i+1}/{self.nframes}", fgWhite, '#'.repeat percentage, if percentage > 50: fgGreen else: fgYellow, "\t", $percentage , "%")
        var
            cam = newPerspectiveCamera(self.width, self.height, transform=transform)
            hdrImage: HdrImage = newHdrImage(self.width, self.height)
            imagetracer: ImageTracer = newImageTracer(hdrImage, cam)
        imagetracer.fireAllRays(self.render.Get())
        let lum = imagetracer.image.average_luminosity()
        debug(fmt"Created frame {i+1}/{self.nframes} --> Average Luminosity: {lum}")
        self.frames.add(imagetracer)
        
        cursorUp 1
        eraseLine()
    stdout.resetAttributes()


proc Save*(self: var Animation, dontDeleteFrames: bool = false): void=
    info("Found ",len(self.frames)," frames to save")
    var finaldirname: string = "frames"
    var dirName: string = joinPath(getCurrentDir(), finaldirname)
    if dirExists(dirName):
        warn("Frames folder already found. Removing previous frames.")
        let resultCode = execShellCmd(fmt"rm -f {dirName}/*")
        if resultCode != 0:
            error("Could not delete existing frames")
    else:
        createDir(dirName)
    debug("Created temporary output folder: ",dirName)

    var i: int = 0
    for frame in self.frames:
        var img = frame.image
        img.normalize_image(1.0)
        img.clamp_image()
        let stringInt = fmt"{i:04}" # int, works
        var savePath: string = joinPath(dirName, fmt"output_{stringInt}.png")
        img.write_png(savePath, 1.0)
        debug("Written temporary PNG: ",savePath)
        i = i + 1
    var cmd: string = fmt"ffmpeg -f image2 -r {self.framerate} -i '{dirName}/output_%04d.png' -c:v libx264 -pix_fmt yuv420p out.mp4"
    let res = execShellCmd(cmd)
    debug("FFmpeg command called, return status: ",res)
    if res == 0:
        if not dontDeleteFrames:
            let res2 = execShellCmd(fmt"rm -rf {dirName}/")
            debug("Temporary folder deleted, return status: ",res2)
    else:
        error("FFmpeg image command failed with return code ", res)


proc SetWorld*(self: var Animation, w: World): void=
    self.world = w

proc Show*(self: Animation) = discard
]#



type
    Animation* = object
        #[
        width*: int
        height*: int
        camType*: CameraType
        cameraTransform*: Transformation
        render*: Renderer
        world*: World
        duration_sec*: int
        framerate*: int
        ]#
        nframes: int
        scene*: Scene

        # internal
        frames*: seq[ImageTracer]

#func newAnimation*(world: var World, width, height: int, renderer: Renderer, cameraTransform: Transformation, camType: CameraType, duration_sec, fps: int): Animation=
#    return Animation(world: world, width: width, height: height, render: renderer, cameraTransform: cameraTransform, camType: camType, duration_sec: duration_sec, framerate: fps, nframes: duration_sec*fps)
func newAnimation*(scene: Scene): Animation=
    return Animation(scene: scene, nframes: scene.settings.animDuration * scene.settings.animFPS)


proc SetTransforms*(self: var Animation, t: var float32): void=
    for shape in self.scene.world.shapes:
        shape.transform = shape.animator.Play(t)

proc Play*(self: var Animation): void=
    if self.scene.settings.animDuration <= 0:
        raise newException(SettingsError, "Animation duration must be greater than 0 in settings.")
    if self.scene.settings.animFPS <= 0:
        raise newException(SettingsError, "Animation FPS must be greater than 0 in settings.")
    for i in countup(0, self.nframes-1):
        var
            t: float32 = float32(i / (self.nframes - 1)) * float32(self.scene.settings.animDuration)
            percentage: int = int(float32(i)/float32(self.nframes-1) * 100.0)
        stdout.styledWriteLine(fgRed, fmt"{i+1}/{self.nframes}", fgWhite, '#'.repeat percentage, if percentage > 50: fgGreen else: fgYellow, "\t", $percentage , "%")
        self.SetTransforms(t)
        var
            cam = newPerspectiveCamera(self.scene.settings.width, self.scene.settings.height, transform=self.scene.camera.transform)
            hdrImage: HdrImage = newHdrImage(self.scene.settings.width, self.scene.settings.height)
            imagetracer: ImageTracer = newImageTracer(hdrImage, self.scene.camera)
        imagetracer.fireAllRays(self.scene.renderer.Get(), self.scene.settings.useAntiAliasing, self.scene.settings.antiAliasingRays)
        let lum = imagetracer.image.average_luminosity()
        debug(fmt"Created frame {i+1}/{self.nframes} --> Average Luminosity: {lum}")
        self.frames.add(imagetracer)
        cursorUp 1
        eraseLine()
    stdout.resetAttributes()

proc Save*(self: var Animation, dontDeleteFrames: bool = false): void=
    info("Found ",len(self.frames)," frames to save")
    var finaldirname: string = "frames"
    var dirName: string = joinPath(getCurrentDir(), finaldirname)
    if dirExists(dirName):
        warn("Frames folder already found. Removing previous frames.")
        let resultCode = execShellCmd(fmt"rm -f {dirName}/*")
        if resultCode != 0:
            error("Could not delete existing frames")
    else:
        createDir(dirName)
    debug("Created temporary output folder: ",dirName)

    var i: int = 0
    for frame in self.frames:
        var img = frame.image
        var tonemapping: ToneMapping = newToneMapping(1.0)
        tonemapping.eval(img)
        let stringInt = fmt"{i:04}" # int, works
        var savePath: string = joinPath(dirName, fmt"output_{stringInt}.png")
        img.write_png(savePath, 1.0)
        debug("Written temporary PNG: ",savePath)
        i = i + 1
    var cmd: string = fmt"ffmpeg -f image2 -r {self.scene.settings.animFPS} -i '{dirName}/output_%04d.png' -c:v libx264 -pix_fmt yuv420p out.mp4"
    let res = execShellCmd(cmd)
    debug("FFmpeg command called, return status: ",res)
    if res == 0:
        if not dontDeleteFrames:
            let res2 = execShellCmd(fmt"rm -rf {dirName}/")
            debug("Temporary folder deleted, return status: ",res2)
    else:
        error("FFmpeg image command failed with return code ", res)