import geometry, color, exception, hdrimage, pcg, mathutils, ray
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
        thresholdAngle*: float32

    PhongBRDF* = ref object of BRDF
        diffuseCoefficient*: float32
        specularCoefficienet*: float32

    Material* = object
        brdf*: BRDF
        emitted_radiance*: Pigment

# ----------------------------  CONSTRUCTORS -------------------
proc newUniformPigment*(color: Color = Color.black()): UniformPigment=
    return UniformPigment(color: color)

proc newCheckeredPigment*(color1, color2: Color, numberOfSteps: int = 10): CheckeredPigment=
    return CheckeredPigment(color1: color1, color2: color2, numberOfSteps: numberOfSteps)

proc newDiffuseBRDF*(pigment: Pigment = newUniformPigment(), reflectance: float32 = 1.0): DiffuseBRDF=
    return DiffuseBRDF(pigment: pigment, reflectance: reflectance)

proc newSpecularBRDF*(pigment: Pigment = newUniformPigment(), thresholdAngle: float32 = PI / 1800.0): SpecularBRDF=
    return SpecularBRDF(pigment: pigment, thresholdANgle: thresholdAngle)

proc newMaterial*(brdf: BRDF = newDiffuseBRDF(), pigment: Pigment = newUniformPigment()): Material=
    return Material(brdf: brdf, emitted_radiance: pigment)

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
    self.pigment.getColor(uv) * (self.reflectance / PI)

method eval*(self: SpecularBRDF, normal: Normal, in_dir, out_dir: Vector3, uv: Vector2): Color=
    let
        theta_in = arccos(Dot(normal.normalize(), in_dir.normalize()))
        theta_out = arccos(Dot(normal.normalize(), out_dir.normalize()))

    if abs(theta_in - theta_out) < self.thresholdAngle:
        return self.pigment.get_color(uv)
    else:
        return Color.black()

method ScatterRay*(self: BRDF, pcg: var PCG, incoming_dir: Vector3, interaction_point: Point, normal: Normal, depth: int): Ray {.base.}=
    raise AbstractMethodError.newException("BRDF.ScatterRay is an abstract method and cannot be called.")

method ScatterRay*(
        self: DiffuseBRDF,
        pcg: var PCG,
        incoming_dir: Vector3,
        interaction_point: Point,
        normal: Normal,
        depth: int
    ): Ray=
    let
        (e1, e2, e3) = CreateOnbFromZ(normal)
        cos_theta_sq = pcg.random_float()
        cos_theta = sqrt(cos_theta_sq)
        sin_theta = sqrt(1 - cos_theta_sq)
        phi = 2.0 * PI * pcg.random_float()

    return newRay(
        interaction_point,
        e1 * cos(phi) * cos_theta + e2 * sin(phi) * cos_theta + e3 * sin_theta,
        1e-3,
        Inf,
        depth
    )
        
method ScatterRay*(
        self: SpecularBRDF,
        pcg: var PCG,
        incoming_dir: Vector3,
        interaction_point: Point,
        normal: Normal,
        depth: int
    ): Ray=
    var newIncomingDir: Vector3 = incoming_dir.normalize()
    var newnormal: Vector3 = normal.convert(Vector3).normalize()
    return newRay(interaction_point, newIncomingDir - newnormal * 2.0 * newnormal.Dot(newIncomingDir), 1e-3, Inf, depth)

method ScatterRay*(
        self: PhongBRDF,
        pcg: var PCG,
        incoming_dir: Vector3,
        interaction_point: Point,
        normal: Normal,
        depth: int
    ): Ray = discard