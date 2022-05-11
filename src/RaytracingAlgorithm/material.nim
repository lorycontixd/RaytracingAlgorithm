import geometry, color, exception, hdrimage
import std/[math]

type
    Pigment* = ref object of RootObj # Abstract class
    UniformPigment* = ref object of Pigment
        color*: Color

    CheckeredPigment* = ref object of Pigment
        color1*: Color
        color2*: Color
        numberOfSteps*: int

    ImagePigment* = ref object of Pigment
        image*: HdrImage

    BRDF* = ref object of RootObj
        pigment*: Pigment

    DiffuseBRDF* = ref object of BRDF
        reflectance*: float32

    SpecularBRDF* = ref object of BRDF

    Material* = object
        brdf*: BRDF
        pigment*: Pigment

# ----------------------------  CONSTRUCTORS -------------------
proc newUniformPigment*(color: Color): UniformPigment=
    return UniformPigment(color: color)

proc newCheckeredPigment*(color1, color2: Color, numberOfSteps: int = 10): CheckeredPigment=
    return CheckeredPigment(color1: color1, color2: color2, numberOfSteps: numberOfSteps)

proc newDiffuseBRDF*(pigment: Pigment, reflectance: float32 = 1.0): DiffuseBRDF=
    return DiffuseBRDF(pigment: pigment, reflectance: reflectance)

proc newMaterial*(brdf: BRDF, pigment: Pigment): Material=
    return Material(brdf: brdf, pigment: pigment)

proc newImagePigment*(image: HdrImage): ImagePigment=
    return ImagePigment(image: image)

# ---------------------------
method getColor*(self: Pigment, vec: Vector2): Color {.base.}=
    raise newException(AbstractMethodError, "")

method getColor*(self: UniformPigment, vec: Vector2): Color=
    return self.color

method getColor*(self: CheckeredPigment, vec: Vector2): Color=
    let int_u = int(floor(vec.u * float32(self.numberOfSteps)))
    let int_v = int(floor(vec.v * float32(self.numberOfSteps)))

    if (int_u mod 2) == (int_v mod 2):
        return self.color1
    else:
        return self.color2

method getColor*(self: ImagePigment, vec: Vector2): Color=
    var col = int(vec.u * float32(self.image.width))
    var row = int(vec.v * float32(self.image.height))

    if col >= self.image.width: 
        col = -1 + self.image.width 

    if row >= self.image.height:
        row = -1 + self.image.height
    
    return self.image.get_pixel(col, row)

method getImage*(self: ImagePigment, image: HdrImage): HdrImage {.base.}=
    return self.image

method eval*(self: BRDF, normal: Normal, in_dir, out_dir: Vector3, uv: Vector2): Color {.base.}=
    raise newException(AbstractMethodError, "")

method eval*(self: DiffuseBRDF, normal: Normal, in_dir, out_dir: Vector3, uv: Vector2): Color=
    self.pigment.get_color(uv) * (self.reflectance / PI)