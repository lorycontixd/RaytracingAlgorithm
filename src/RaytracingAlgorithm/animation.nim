import camera, color, geometry, quaternion, logger, shape, world, transformation, hdrimage, imagetracer, renderer, matrix
import std/[os, strformat, options, streams, marshal]

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
    

# ----------- Constructors -----------

func newAnimation*(start_transform, end_transform: Transformation, camType: CameraType, width,height: int, world: var World, duration_sec: int = 10, framerate: int = 60): Animation=
    result = Animation(start_transform: start_transform, end_transform: end_transform, camType: camType, width: width, height: height, world: world, duration_sec: duration_sec, framerate: framerate, nframes: duration_sec*framerate,  hasPlayed: false)
    result.translations = newSeq[Vector3](2)
    result.rotations = newSeq[Quaternion](2)
    result.scales = newSeq[Matrix](2)

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
    result[3][3] = float32(1.0)

func ExtractRotationMatrix*(m: Matrix): Matrix=
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
        for i in countup(0,4):
            for j in countup(0,4):
                Rnext[i][j] = 0.5 * (R[i][j] + Rit[i][j])
        norm = 0
        for i in 0..3:
            let n = abs(R[i][0] - Rnext[i][0]) + abs(R[i][1] - Rnext[i][1]) + abs(R[i][2] - Rnext[i][2]) 
            norm = max(norm, n)
        R = newMatrix(Rnext)
        count = count + 1
        if (count > 100 or norm <= 0.0001):
            break
    result = newMatrix(R)

func ExtractRotation*(m: Matrix): Quaternion=
    var R: Matrix = ExtractRotationMatrix(m)
    result = newQuaternion(R)

func ExtractScale*(R: Matrix, m: Matrix): Matrix=
    var M: Matrix = newMatrix(m)
    for i in 0..3:
        M[i][3] = float32(0.0)
    M[3][3] = float32(1.0)
    result = matrix.inverse(R) * M

# -- Animation Methods

func Decompose*(m: Matrix, T: var Vector3, Rquat: var Quaternion, S: var Matrix): void {.inline, gcSafe.}=
    ##
    ##

    #- Extract translation components from transform matrix
    T = ExtractTranslation(m)
    #- Compute a matrix with no translation components
    Rquat = ExtractRotation(m)
    #- Extract scale matrix -> M=RS
    S = ExtractScale(ExtractRotationMatrix(m), RemoveTranslationFromMatrix(m))


proc FindRotation*(self: var Animation): void {.inline.} =
    ##
    
    Decompose(self.start_transform.m, self.translations[0], self.rotations[0], self.scales[0])
    Decompose(self.end_transform.m, self.translations[1], self.rotations[1], self.scales[1])
    if (Dot(self.rotations[0], self.rotations[1]) < 0):
        self.rotations[1] = self.rotations[1].Negativize()


#[
proc Play*(self: var Animation): void=
    ## Plays an animation and stores the frames in memory.

    info("Starting animation ")
    info("Framerate: ",self.framerate)
    info("Duration: ",self.duration_sec)
    info("Camera Type: ",self.camType)
    info("Estimated frames to be produces: ", self.GetNFrames())
    var rotation: Quaternion = Quaternion.VectorRotation(self.start_pos, self.end_pos)

    for i in countup(0, self.nframes-1):
        let
            t = float32(i / (self.nframes-1))
            q = rotation * t
        var
            cam = newPerspectiveCamera(self.width, self.height, transform=Transformation.translation(self.start_pos) * Transformation.rotationZ(180.0*t))
            hdrImage: HdrImage = newHdrImage(self.width, self.height)
            imagetracer: ImageTracer = newImageTracer(hdrImage, cam)
            onoff: OnOffRenderer = newOnOffRenderer(self.world, Color.black(), Color.white())
        
        imagetracer.fireAllRays(onoff.Get())
        let lum = imagetracer.image.average_luminosity()
        debug(fmt"Created frame {i+1}/{self.nframes} --> Average Luminosity: {lum}")
        self.frames.add(imagetracer)


proc Save*(self: var Animation, dontDeleteFrames: bool = false): void=
    info("Found ",len(self.frames)," frames to save")
    var dirName: string = "temp"
    if dirExists(dirName):
        let resultCode = execShellCmd("rm -f temp/*")
    else:
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
    var cmd: string = fmt"ffmpeg -f image2 -framerate {self.framerate} -pattern_type glob -i 'temp/*.png' -c:v libx264 -pix_fmt yuv420p out.mp4"
    let res = execShellCmd(cmd)
    debug("FFmpeg command called, return status: ",res)
    if res == 0:
        if not dontDeleteFrames:
            let res2 = execShellCmd("rm -rf temp/")
            debug("Temporary folder deleted, return status: ",res2)
    else:
        error("FFmpeg image command failed with return code ", res)



proc Show*(self: Animation) = discard

        ]#


    