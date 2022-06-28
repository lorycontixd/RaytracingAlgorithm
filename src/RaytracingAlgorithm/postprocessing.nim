import hdrimage, matrix, color, utils, exception, scene
import std/[math, enumerate, options]


type
    PostProcessingEffect* = ref object of RootObj

    DepthOfField* = ref object of PostProcessingEffect
        apertureRadius*: float32
        focalDistance*: float32
        scene*: Scene

    GaussianBlur* = ref object of PostProcessingEffect
        kernelRadius*: int
        kernelWidth*: int
        sigma*: float32

    ToneMapping* = ref object of PostProcessingEffect
        factor*: float32
        gammaCorrection*: float32
        luminosity*: Option[float32]
        delta*: float32
    
################################################  ABSTRACT  #######################################################

method eval*(self: PostProcessingEffect, input_ig: var HdrImage): auto {.base.}=
    raise newException(AbstractMethodError, "Cannot call abstract method eval of PostProcessingEffect")


################################################  GAUSSIAN BLUR  #######################################################

func newDepthOfField*(apertureRadius: float, focalDistance: float32, scene: Scene): DepthOfField {.inline.}=
    return DepthOfField(apertureRadius: apertureRadius, focalDistance: focalDistance, scene: scene)


################################################  GAUSSIAN BLUR  #######################################################

func newGaussianBlur*(radius: int): GaussianBlur=
    return GaussianBlur(kernelRadius: radius, kernelWidth: 2 * radius + 1, sigma: radius.float32 / 2.0)

func gaussian(x,y: float32, sigma: float32): float32=
    let norm = 1.0 / (2 * PI * sigma * sigma)
    let expNominator = - (x*x + y*y)
    let expDenominator = 2 * sigma * sigma
    return norm * exp(expNominator / expDenominator)

func GetKernel*(self: GaussianBlur): seq[seq[float32]]=
    var sum: float32 = 0
    result = newSeq[seq[float32]](self.kernelWidth)
    # Set kernel
    for i in -self.kernelRadius..self.kernelRadius:#width kernel
        var row: seq[float32] = newSeq[float32](self.kernelWidth)
        for j in -self.kernelRadius..self.kernelRadius:#height kernel
            let val = gaussian(i.float32,j.float32,self.sigma)
            row[j+self.kernelRadius] = val
            sum += val
        result[i+self.kernelRadius] = row
    
    # Normalize kernel
    for i in -self.kernelRadius..self.kernelRadius:
        for j in -self.kernelRadius..self.kernelRadius:
            result[i+self.kernelRadius][j+self.kernelRadius] = result[i+self.kernelRadius][j+self.kernelRadius] / sum

func SeparateKernel1D(kernel: seq[seq[float32]], axis: int): seq[float32]=
    assert axis == 0 or axis == 1
    result = newSeq[float32](kernel.len())
    if axis == 0:
        for i, row in kernel:
            result[i] = sum(kernel[i])
    elif axis == 1:
        #vertical
        for i, row in kernel:
            for j, elem in kernel[i]:
                result[j] = result[j] + kernel[i][j]

func SumKernel(kernel: seq[seq[float32]]): float32=
    result = 0
    for row in kernel:
        for j in row:
            result += j
    
method eval*(self: GaussianBlur, input_img: var HdrImage): auto=
    ## Applies Gaussian blur to the input image and saves it in an output image.
    ## Gaussian blur smoothens each pixel's color by building a gaussian kernel (RxR matrix, where R=kernel radius)
    ##  with the weighted values of neighbouring pixels. It is a low-pass filter, meaning it reduces high-frequency components.
    ##
    ## ! This version creates a black border around the image that scales with the radius of the kernel, because border pixels don't have enough neighbours.
    ## ! There are a few ways to fix this. One way is to fill the empty pixels in the kernel with values from the side of the kernel that has values.
    ##
    ##      Parameters
    ##          self (GaussianBlur): the effect instance
    ##          input_img (HdrImage): the image to be blurred
    ##          output_img (HdrImage): image to store result
    ##
    var output_img: HdrImage = newHdrImage(input_img.width, input_img.height)
    let kernel = GetKernel(self)
    for x in self.kernelRadius..<input_img.width-self.kernelRadius:
        for y in self.kernelRadius..<input_img.height-self.kernelRadius:
            var newcolor: Color = newColor()
            let imgpixel = input_img.get_pixel(x,y)
            for kernelX in -self.kernelRadius..self.kernelRadius:
                for kernelY in -self.kernelRadius..self.kernelRadius:
                    let kernelValue = kernel[kernelX+self.kernelRadius][kernelY+self.kernelRadius]
                    newcolor = newcolor + newColor(
                        input_img.get_pixel(x-kernelX, y-kernelY).r * kernelValue,
                        input_img.get_pixel(x-kernelX, y-kernelY).g * kernelValue,
                        input_img.get_pixel(x-kernelX, y-kernelY).b * kernelValue,
                    )
            output_img.set_pixel(x,y, newcolor)
    input_img.pixels = output_img.pixels

            
################################################  TONE MAPPING  #######################################################

func newToneMapping*(factor: float32, luminosity: Option[float32] = none(float32), delta: float32 = 1e-10): ToneMapping=
    return ToneMapping(factor: factor, luminosity: luminosity, delta: delta)


proc normalize_image*(self: ToneMapping, image: var HdrImage)=
    ## NORMALIZE IMAGE:  updates R,G,B values of the Image by normalization (factor * pixel / average_luminosity)
    ## 
    ## -Parameters: 
    ##      self (HdrImage)
    ##      factor (float) 
    ##      luminosity (float): optional
    ##      delta(float):  default_value: 1e-10)
    ## 
    ## -Returns: 
    ##      no returns, just update of pixels  
    var l: float32
    if not self.luminosity.isSome():
        l = image.average_luminosity()
    else:
        l = self.luminosity.get()
    for i in 0..size(image.pixels)-1:
        image.pixels[i] = image.pixels[i] * (self.factor/l)


proc clamp_image*(self: ToneMapping, image: var HdrImage)=
    ## Applies corrections for luminous sources to R,G,B components of pixels
    ## 
    ## -Parameters: 
    ##      self (HdrImage)
    ## 
    ## -Returns: 
    ##      no returns, only applies corrections
    for i in 0..size(image.pixels)-1:
        image.pixels[i].r = clampFloat(image.pixels[i].r)
        image.pixels[i].g = clampFloat(image.pixels[i].g)
        image.pixels[i].b = clampFloat(image.pixels[i].b)


method eval*(self: ToneMapping, input_img: var HdrImage): auto=
    ## Calculates tone mapping correction according to Shirley & Morley's algorithm.
    ##
    self.normalize_image(input_img)
    self.clamp_image(input_img)




########################## General ##################################
proc ApplyPostProcessing*(self: var HdrImage, effects: openArray[PostProcessingEffect]): auto {.inline.}=
    for effect in effects:
        effect.eval(self)