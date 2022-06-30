import hdrimage, camera, ray, color, pcg, utils, stats
import std/[math, threadpool, times, sequtils]


type 
    ImageTracer* = ref object of RootObj # traces an image by shooting rays through each of its pixels
        image*: HdrImage
        camera*: Camera
        
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
    #let start = now()
    var
        u:float32 = (float32(col) + u_pixel) / float32(self.image.width)
        v:float32 = 1.0 - (float32(row) + v_pixel) / float32(self.image.height)
    
    #let endTime = now() - start
    #mainStats.AddCall(procName, endTime, 0)
    return self.camera.fireRay(u, v)

proc fireAllRays*(self: var ImageTracer, f: proc, useAntiAliasing: bool = false, antiAliasingRays: int = 0): void {.injectProcName.}=
    ## Shoots several rays through each pixel in the image
    ## For each pixel of `HdrImage` object, fires one ray and passes it to the function `f`, which
    ## accepts a `Ray` object and returns a `Color` object, to be assigned to that pixel in the image.
    ## Parameters
    ##      self (var ImageTracer) : image
    ##      f (proc)
    ## Returns
    ##      (Ray)
    #let start = now()
    var
        color: Color
        ray: Ray
        pcg: PCG = newPCG()
        
    for row in 0 ..< self.image.height:
        for col in 0 ..< self.image.width:
            var pixel_dist :float32 = Inf
            if useAntiAliasing:
                var cumcolor = Color.black()
                if antiAliasingRays > 0:
                    for inter_pixel_row in 0..<antiAliasingRays:
                        for inter_pixel_col in 0..<antiAliasingRays:
                            let
                                u_pixel = (inter_pixel_col.float32 + pcg.random_float()) / antiAliasingRays.float32
                                v_pixel = (inter_pixel_row.float32 + pcg.random_float()) / antiAliasingRays.float32
                            ray = self.fireRay(col=col, row=row, u_pixel=u_pixel, v_pixel=v_pixel)
                            cum_color = cum_color + f(ray, pixel_dist)
                    self.image.set_pixel(col, row, cum_color * (1.0 / (antiAliasingRays.float32 * antiAliasingRays.float32)))
                    self.image.set_pixel_distance(col, row, pixel_dist)
                else:
                    ray = self.fireRay(col, row)
                    color = f(ray, pixel_dist)
                    self.image.set_pixel(col, row, color)
                    self.image.set_pixel_distance(col, row, pixel_dist)
            else:
                ray = self.fireRay(col, row)
                color = f(ray, pixel_dist)
                self.image.set_pixel(col, row, color)
                self.image.set_pixel_distance(col, row, pixel_dist)
    #let endTime = now() - start
    #mainStats.AddCall(procName, endTime, 0)