import camera, mathutils, color, geometry, quaternion, logger, shape, world, transformation, hdrimage, imagetracer, renderer, matrix
import std/[os, strformat, options, streams, marshal, strutils, terminal]

type
    Animation* = ref object
        start_transform*: Transformation
        end_transform*: Transformation
        width*: int
        height*: int
        camType*: CameraType
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

## -- Decomposition Utilities --

func ExtractTranslation*(m: Matrix): Vector3=
    result = newVector3(m[0][3], m[1][3], m[2][3])

func RemoveTranslationFromMatrix(m: Matrix): Matrix=
    result = newMatrix(m)
    for i in 0..3:
        result[i][3] = float32(0.0)
        result[3][i] = float32(0.0)
    result[3][3] = float32(1.0)

proc ExtractRotationMatrix*(m: Matrix): Matrix=
    var M: Matrix = RemoveTranslationFromMatrix(m)
    #- Extract rotation from transform matrix
    var 
        norm: float32
        count: int = 0
        R: Matrix = newMatrix(M)
    
    while true:
        var
            Rnext: Matrix = Zeros()
            Rit: Matrix = inverse(transpose(R))
        for i in countup(0,3):
            for j in countup(0,3):
                Rnext[i][j] = 0.5 * (R[i][j] + Rit[i][j])
        norm = 0
        for i in 0..3:
            let n = abs(R[i][0] - Rnext[i][0]) + abs(R[i][1] - Rnext[i][1]) + abs(R[i][2] - Rnext[i][2]) 
            norm = max(norm, n)
        R = newMatrix(Rnext)
        count = count + 1
        if (count > 100 or norm <= 0.0001):
            break
    let x = newMatrix(R)
    result = x

proc ExtractRotation*(m: Matrix): Quaternion=
    var R: Matrix = ExtractRotationMatrix(m)
    result = newQuaternion(R).Normalize()

proc ExtractScale*(R: Matrix, M: Matrix): Matrix=
    result = matrix.inverse(R) * M

proc Decompose*(m: Matrix, T: var Vector3, Rquat: var Quaternion, S: var Matrix): void {.inline, gcSafe.}=
    ##
    ##
    echo "---> m; "
    m.Show()
    #- Extract translation components from transform matrix
    T = ExtractTranslation(m)
    #- Compute a matrix with no translation components
    Rquat = ExtractRotation(m)
    #- Extract scale matrix -> M=RS
    S = ExtractScale(ExtractRotationMatrix(m), RemoveTranslationFromMatrix(m))
  

# ----------- Constructors -----------

proc newAnimation*(start_transform, end_transform: Transformation, camType: CameraType, width,height: int, world: var World, duration_sec: int = 10, framerate: int = 60): Animation=
    result = Animation(start_transform: start_transform, end_transform: end_transform, camType: camType, width: width, height: height, world: world, duration_sec: duration_sec, framerate: framerate, nframes: duration_sec*framerate,  hasPlayed: false)
    result.translations = newSeq[Vector3](2)
    result.rotations = newSeq[Quaternion](2)
    result.scales = newSeq[Matrix](2)
    result.actuallyAnimated = (start_transform != end_transform)
    Decompose(result.start_transform.m, result.translations[0], result.rotations[0], result.scales[0])
    Decompose(result.end_transform.m, result.translations[1], result.rotations[1], result.scales[1])
    
    echo $result.translations[0],"\n"
    echo "-> ",$result.rotations[0]
    result.rotations[0].toRotationMatrix().Show()
    #result.scales[0].Show()
    echo " "
    
    echo $result.translations[1],"\n"
    echo $result.rotations[1]
    result.rotations[1].toRotationMatrix().Show()
    #result.scales[1].Show()
    echo " "
# ----------------- Animation Methods

proc Interpolate*(self: Animation, t: float32, debug: bool = false): Transformation {.inline.}=
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
        rotate.toRotationMatrix().Show()
        echo "\n"
    # Interpolate scale at _dt_
    var scale: Matrix = Zeros()
    for i in countup(0,3):
        for j in countup(0,3):
            scale[i][j] = Lerp(self.scales[0][i][j], self.scales[1][i][j], dt)
    if debug:
        echo "Scale:"
        scale.Show()
        echo "\n"

    let
        transTranform = Transformation.translation(trans)
        rotTransform = newTransformation(rotate.toRotationMatrix())
        scaleTransform =  newTransformation(scale)

    transTranform.Show()
    echo "\n"
    rotTransform.Show()
    echo "\n"
    scaleTransform.Show()
    echo "\n"

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
        echo "Frame: ",i
        let
            t = float32(i / (self.nframes - 1)) * float32(self.duration_sec)
            x = float32(i)/float32(self.nframes-1)
            #translationMatrix = Transformation.translation(-2.0, 0.0, 0.0)
            #rotMatrix = Transformation.rotationX(90.0 * (1.0+x))
            #transform =  translationMatrix * rotMatrix 
            transform = self.Interpolate(t, true)
            percentage = int(float32(i)/float32(self.nframes-1) * 100.0)
        #echo "t: ",t,"   Rot matrix: "
        #rotMatrix.Show()
        #echo "quat: ",newQuaternion(rotMatrix.m)
        echo "t: ",t,"\n\n\n"
        stdout.styledWriteLine(fgRed, fmt"{i+1}/{self.nframes}", fgWhite, '#'.repeat i, if i > 50: fgGreen else: fgYellow, "\t", $percentage , "%")
        var
            cam = newPerspectiveCamera(self.width, self.height, transform=transform)
            hdrImage: HdrImage = newHdrImage(self.width, self.height)
            imagetracer: ImageTracer = newImageTracer(hdrImage, cam)
            onoff: OnOffRenderer = newOnOffRenderer(self.world, Color.black(), Color.white())
        imagetracer.fireAllRays(onoff.Get())
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



proc Show*(self: Animation) = discard

    