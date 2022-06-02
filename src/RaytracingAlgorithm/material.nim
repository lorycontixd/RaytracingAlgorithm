import geometry, color, exception, hdrimage, pcg, mathutils, ray, utils
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

    GradientPigment* = ref object of Pigment
        color1*: Color
        color2*: Color
        threshold*: float32
        uCoefficient*: float32
        vCoefficient*: float32

    BRDF* = ref object of RootObj
        pigment*: Pigment

    DiffuseBRDF* = ref object of BRDF
        reflectance*: float32

    SpecularBRDF* = ref object of BRDF
        thresholdAngle*: float32

    PhongBRDF* = ref object of BRDF
        diffuseReflectivity*: float32
        specularReflectivity*: float32
        shininess*: float32

    CookTorranceNDF* = enum
        GGX, Beckmann, Blinn

    
    CookTorranceBRDF* = ref object of BRDF 
        roughness*: float32
        albedo*: float32
        metallic*: float32
        ndf*: CookTorranceNDF
    

    Material* = object
        brdf*: BRDF
        emitted_radiance*: Pigment

# ----------------------------  CONSTRUCTORS -------------------
proc newUniformPigment*(color: Color = Color.black()): UniformPigment=
    return UniformPigment(color: color)

proc newGradientPigment*(color1, color2: Color, threshold: float32, uCoefficient: float32 = 1.0, vCoefficient: float32 = 0.0): GradientPigment=
    assert IsEqual(uCoefficient + vCoefficient, 1.0)
    return GradientPigment(color1: color1, color2: color2, threshold: threshold, uCoefficient: uCoefficient, vCoefficient: vCoefficient)

proc newCheckeredPigment*(color1, color2: Color, numberOfSteps: int = 10): CheckeredPigment=
    return CheckeredPigment(color1: color1, color2: color2, numberOfSteps: numberOfSteps)

proc newDiffuseBRDF*(pigment: Pigment = newUniformPigment(), reflectance: float32 = 1.0): DiffuseBRDF=
    return DiffuseBRDF(pigment: pigment, reflectance: reflectance)

proc newSpecularBRDF*(pigment: Pigment = newUniformPigment(), thresholdAngle: float32 = PI / 1800.0): SpecularBRDF=
    return SpecularBRDF(pigment: pigment, thresholdANgle: thresholdAngle)

proc newPhongBRDF*(pigment: Pigment = newUniformPigment(), shininess: float32 = 10.0, diffuseReflectivity: float32 = 0.3, specularReflectivity: float32 = 0.5): PhongBRDF=
    assert (diffuseReflectivity + specularReflectivity <= 1) # must obey energy conservation
    assert (shininess >= 0.0) ## cannot have negative values of shininess 
    return PhongBRDF(pigment: pigment, shininess: shininess, diffuseReflectivity: diffuseReflectivity, specularReflectivity: specularReflectivity)

proc newCookTorranceBRDF*(pigment: Pigment = newUniformPigment(), roughness: float32 = 0.5, albedo: float32 = 0.5, metallic: float32 = 0.5, ndf: CookTorranceNDF = CookTorranceNDF.GGX): CookTorranceBRDF =
    return CookTorranceBRDF(pigment: pigment, roughness: roughness, albedo: albedo, metallic: metallic, ndf: ndf)

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

method getColor*(self: GradientPigment, vec: Vector2): Color=
    let 
        ueff = self.uCoefficient * vec.u
        veff = self.vCoefficient * vec.v
    var t: float32 = (ueff + veff) / 2.0
    let c = Color.Lerp(self.color1, self.color2, t)
    return c

method getColor*(self: ImagePigment, vec: Vector2): Color=
    var col = int(vec.u * float32(self.image.width))
    var row = int(vec.v * float32(self.image.height))

    if col >= self.image.width: 
        col = -1 + self.image.width 

    if row >= self.image.height:
        row = -1 + self.image.height
    let c = self.image.get_pixel(col, row)
    return c

method getImage*(self: ImagePigment, image: HdrImage): HdrImage {.base.}=
    return self.image

method eval*(self: BRDF, normal: Normal, in_dir, out_dir: Vector3, uv: Vector2): Color {.base.}=
    raise newException(AbstractMethodError, "BRDF.eval is an abstract method and cannot be called.")

method ScatterRay*(self: BRDF, pcg: var PCG, incoming_dir: Vector3, interaction_point: Point, normal: Normal, depth: int): Ray {.base.}=
    raise AbstractMethodError.newException("BRDF.ScatterRay is an abstract method and cannot be called.")


## Lambertian Diffuse BRDF
method eval*(self: DiffuseBRDF, normal: Normal, in_dir, out_dir: Vector3, uv: Vector2): Color=
    self.pigment.getColor(uv) * (self.reflectance / PI)

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

## Specular BRDF
method eval*(self: SpecularBRDF, normal: Normal, in_dir, out_dir: Vector3, uv: Vector2): Color=
    let
        theta_in = arccos(Dot(normal.normalize(), in_dir.normalize()))
        theta_out = arccos(Dot(normal.normalize(), out_dir.normalize()))

    if abs(theta_in - theta_out) < self.thresholdAngle:
        return self.pigment.get_color(uv)
    else:
        return Color.black()
        
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

## Phong BRDF

method eval*(self: PhongBRDF, normal: Normal, in_dir, out_dir: Vector3, uv: Vector2): Color =
    let newIncomingDir = in_dir.normalize()
    let newNormal =  normal.convert(Vector3).normalize()    
    self.pigment.getColor(uv) * ((self.diffuseReflectivity / PI) + self.specularReflectivity * ((self.shininess + 2) / 2 * PI) * pow(cos(Dot(out_dir, newIncomingDir - newnormal * 2.0 * newnormal.Dot(newIncomingDir))), self.shininess))

method ScatterRay*( 
        self: PhongBRDF,
        pcg: var PCG,
        incoming_dir: Vector3,
        interaction_point: Point,
        normal: Normal,
        depth: int
    ): Ray =
    var newDir: Vector3
    let
        (e1, e2, e3) = CreateOnbFromZ(normal)   
        r = pcg.random_float()
    if (r >= 0 and r < self.diffuseReflectivity):
        # diffusive behaviour
        let
            cos_theta_sq = pcg.random_float()
            cos_theta = sqrt(cos_theta_sq)
            sin_theta = sqrt(1 - cos_theta_sq)
            phi = 2.0 * PI * pcg.random_float()
        newDir = e1 * cos(phi) * cos_theta + e2 * sin(phi) * cos_theta + e3 * sin_theta
    elif (r >= self.diffuseReflectivity and r < self.diffuseReflectivity + self.specularReflectivity):
        # specular behaviour
        let
            theta = arccos( pow(  pcg.random_float(), 1.0 / (1.0 + self.shininess)) )
            phi = 2 * PI * pcg.random_float()
        newDir = e1 * sin(theta) * cos(phi) + e2 * sin(theta) * sin(phi) + e3 * cos(theta)
    else:
        #no contribution
        newDir = newVector3(0.0, 0.0, 0.0)

    return newRay(
        interaction_point,
        newdir,
        1e-3,
        Inf,
        depth
    )
    

## Cook Torrance BRDF

func GeometryFunction(self: CookTorranceBRDF, in_dir, out_dir: Vector3, normal: Normal): float32=
    ## Calculates the attenuation of the light due to microfacets shadowing each other.
    ## It models the probability that at a given point, the microfacets are occluded by each other
    ## If GGX NDF is defined, then use GGX Geometry Function, else use Cook-Torrance Geometry Function
    let half_vector = in_dir + out_dir
    if self.ndf == CookTorranceNDF.GGX:
        return CharacteristicFunction(Dot(in_dir, normal.convert(Vector3))) * ( 2.0 / 1 + sqrt(1 + self.roughness * self.roughness * pow(tan(Dot(in_dir, normal.convert(Vector3))) , 2.0)) )
    else:
        return min( 1.0, min(  (2*Dot(normal.convert(Vector3), half_vector)*Dot(normal.convert(Vector3), in_dir))/(Dot(in_dir, half_vector))  ,   (2*Dot(normal.convert(Vector3), half_vector)*Dot(normal.convert(Vector3), out_dir))/(Dot(in_dir, half_vector))  ) )

func FresnelSchlick(self: CookTorranceBRDF, in_dir, out_dir: Vector3, normal: Normal, n: int): float32=
    let f0 = pow(float32(n-1), 2.0) / pow(float32(n+1), 2.0)
    let half_vector = in_dir + out_dir
    return f0 + (1-f0) * pow( 1.0 - Dot(out_dir, half_vector), 5.0)

func NDF(self: CookTorranceBRDF, in_dir, out_dir: Vector3, normal: Normal): float32=
    let half_vector = in_dir + out_dir
    let r2 = pow(self.roughness, 2.0)
    if self.ndf == CookTorranceNDF.GGX:
        # GGX / Trowbridge-Reitz
        let
            a1 = self.roughness
            a2 = a1 * a1
            noH = abs(half_vector.z)
            d = (noH * a2 - noH) * noH + 1
        return a2 / (d * d * PI)
    elif self.ndf == CookTorranceNDF.Beckmann:
        return 1.0 / (PI * pow(self.roughness, 2.0) * pow( Dot(half_vector, normal.convert(Vector3)) , 4.0)) * exp( - pow( tan(Dot(half_vector, normal.convert(Vector3))),2.0) / pow(self.roughness, 2.0))


method eval*(self: CookTorranceBRDF, normal: Normal, in_dir, out_dir: Vector3, uv: Vector2): Color = discard

method ScatterRay*( 
        self: CookTorranceBRDF,
        pcg: var PCG,
        incoming_dir: Vector3,
        interaction_point: Point,
        normal: Normal,
        depth: int
    ): Ray =
    var newDir: Vector3
    let
        (e1, e2, e3) = CreateOnbFromZ(normal)
        rough2 = pow(self.roughness, 2.0)
    if self.ndf == CookTorranceNDF.GGX:
        var theta: float32 = arccos(sqrt( rough2 / (pcg.random_float() * (rough2 - 1) + 1) ))
        var phi: float32 = pcg.random_float()
        newDir = e1 * sin(theta) * cos(phi) + e2 * sin(theta) * sin(phi) + e3 * cos(theta)
    elif self.ndf == CookTorranceNDF.Beckmann:
        var theta: float32 = arccos(sqrt( 1 / (1 - rough2 * ln(1 - pcg.random_float())) ))
        var phi: float32 = pcg.random_float()
        newDir = e1 * sin(theta) * cos(phi) + e2 * sin(theta) * sin(phi) + e3 * cos(theta)
    elif self.ndf == CookTorranceNDF.Blinn:
        var theta: float32 = arccos( 1.0 / pow(pcg.random_float(), self.roughness + 1))
        var phi: float32 = pcg.random_float()
    else:
        raise TestError.newException("")
    return newRay(
        interaction_point,
        newDir,
        1e-3,
        Inf,
        depth
    )


    