import hdrimage, camera, ray, color, pcg, utils, stats
import std/[math, threadpool, times, sequtils]


type 
    ImageTracer* = ref object of RootObj
        image*: HdrImage
        camera*: Camera 

    AntiAliasing* = ref object of ImageTracer
        samplesPerSide: int
        pcg: PCG

converter toParent[T:ImageTracer](x:T):ImageTracer= x.mapIt(it.ImageTracer)


proc newImageTracer*(image: var HdrImage, camera: Camera): ImageTracer=
    var tracer: ImageTracer = ImageTracer(image:image, camera:camera)
    result = tracer

proc fireRay*(self: var ImageTracer, col, row: int, u_pixel: float32 = 0.5, v_pixel: float32 = 0.5): Ray {.injectProcName.}=
    let start = now()
    var
        u:float32 = (float32(col) + u_pixel) / float32(self.image.width)
        v:float32 = 1.0 - (float32(row) + v_pixel) / float32(self.image.height)
    
    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 0)
    return self.camera.fireRay(u, v)

proc fireAllRays*(self: var ImageTracer, f: proc): void {.injectProcName.}=
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
    return AntiAliasing(image: image, camera: camera, samplesPerSide: samples, pcg: pcg)

proc fireRay*(self: var AntiAliasing, col, row: int, u_pixel: float32 = 0.5, v_pixel: float32 = 0.5): Ray {.injectProcName.}=
    let start = now()
    var
        u:float32 = (float32(col) + u_pixel) / float32(self.image.width)
        v:float32 = 1.0 - (float32(row) + v_pixel) / float32(self.image.height)
    
    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 0)
    return self.camera.fireRay(u, v)

proc fireAllRays*(self: var AntiAliasing, f: proc): void {.injectProcName.}=
    let start = now()
    var
        cumcolor: Color
        ray: Ray
    echo "--> ",self.image.width,"      - ",self.image.height
    for row in 0 .. self.image.height-1:
        for col in 0 .. self.image.width-1:
            cumcolor = Color.black()

            if self.samplesPerSide > 0:
                for inter_pixel_row in 0..<self.samplesPerSide:
                    for inter_pixel_col in 0..<self.samplesPerSide:
                        let
                            u_pixel = (inter_pixel_col.float32 + self.pcg.random_float()) / self.samplesPerSide.float32
                            v_pixel = (inter_pixel_row.float32 + self.pcg.random_float()) / self.samplesPerSide.float32
                        ray = self.fireRay(col=col, row=row, u_pixel=u_pixel, v_pixel=v_pixel)
                        cum_color = cum_color + f(ray)
                self.image.set_pixel(col, row, cum_color * (1.0 / (self.samplesPerSide.float32 * self.samplesPerSide.float32)))
            else:
                ray = cast[var ImageTracer](self).fire_ray(col, row)
                self.image.set_pixel(col, row, f(ray))
    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 0)

    