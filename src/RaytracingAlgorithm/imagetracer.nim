import hdrimage, camera, ray, color, pcg, utils, stats
import std/[math, threadpool, times, sequtils]


type 
    ImageTracer* = ref object of RootObj # traces an image by shooting rays through each of its pixels
        image*: HdrImage
        camera*: Camera 

    AntiAliasing* = ref object of ImageTracer # prevents from artifacts caused by color changes in a single pixel
        samplesPerSide: int
        pcg: PCG

converter toParent[T:ImageTracer](x:T):ImageTracer= x.mapIt(it.ImageTracer)


proc newImageTracer*(image: var HdrImage, camera: Camera): ImageTracer=
    ## constructor for ImageTracer
    var tracer: ImageTracer = ImageTracer(image:image, camera:camera)
    result = tracer

proc fireRay*(self: var ImageTracer, col, row: int, u_pixel: float32 = 0.5, v_pixel: float32 = 0.5): Ray {.injectProcName.}=
    ## Shoots one ray through image pixel, individuated by (col, row)
    ## parameters (col, row) are measured in the same way as in `HdrImage` class: the bottom left
    ## corner corresponds to (0, 0).
    ## Parameters
    ##      self (var ImageTracer) : image
    ##      col, row (int): column and row index of the pixel
    ##      u_pixel, v_pixel (float32): specify where the ray should cross the pixel
    ##                                  they are in range [0,1], default_value: 0.5
    ## Returns
    ##      (Ray)
    let start = now()
    var
        u:float32 = (float32(col) + u_pixel) / float32(self.image.width)
        v:float32 = 1.0 - (float32(row) + v_pixel) / float32(self.image.height)
    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 0)
    return self.camera.fireRay(u, v)

proc fireAllRays*(self: var ImageTracer, f: proc): void {.injectProcName.}=
    ## Shoots several rays through each pixel in the image
    ## For each pixel of `HdrImage` object, fires one ray and passes it to the function `f`, which
    ## accepts a `Ray` object and returns a `Color` object, to be assigned to that pixel in the image.
    ## Parameters
    ##      self (var ImageTracer) : image
    ##      f (proc)
    ## Returns
    ##      (Ray)
    let start = now()
    var
        color: Color
        ray: Ray
    for row in 0 ..< self.image.height:
        for col in 0 ..< self.image.width:
            ray = self.fireRay(col, row)
            color = f(ray)
            self.image.set_pixel(col, row, color)
    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 0)

func newAntiAliasing*(image: var HdrImage, camera: Camera, samples: int, pcg: PCG): AntiAliasing=
    ## constructor for antiAliasing
    return AntiAliasing(image: image, camera: camera, samplesPerSide: samples, pcg: pcg)

proc fireAllRays*(self: var AntiAliasing, f: proc): void {.injectProcName.}=
    ## Shoots several rays through each pixel in the image
    ## Method 'stratified sampling':
    ## to prevent aliasing, divides each pixel in squares and extracts a random position in
    ## each of them, where ray will be shot
    ## Parameters
    ##      self (var Antialiasing) 
    ##      f (proc)
    ## Returns
    ##      /
    let start = now()
    var
        cumcolor: Color
        ray: Ray
    #echo "--> ",self.image.width,"      - ",self.image.height
    for row in 0 .. self.image.height-1:
        for col in 0 .. self.image.width-1:
            cumcolor = Color.black()

            if self.samplesPerSide > 0:
                #countup(0, self.samplesPerSide-1)
                for inter_pixel_row in 0 || self.samplesPerSide-1:
                    for inter_pixel_col in 0 || self.samplesPerSide-1:
                        let
                            u_pixel = (inter_pixel_col.float32 + self.pcg.random_float()) / self.samplesPerSide.float32
                            v_pixel = (inter_pixel_row.float32 + self.pcg.random_float()) / self.samplesPerSide.float32
                            
                            ray = cast[var ImageTracer](self).fireRay(col, row, u_pixel, v_pixel)
                            cumcolor = cum_color + f(ray)
                self.image.set_pixel(col, row, cumcolor * (1.0 / pow(self.samplesPerSide.float32, 2.0)))
            else:
                ray = cast[var ImageTracer](self).fire_ray(col, row)
                self.image.set_pixel(col, row, f(ray))
    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 0)

    