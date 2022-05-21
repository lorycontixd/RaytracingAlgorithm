import hdrimage, camera, ray, color, pcg
import std/[math, threadpool]


type 
    ImageTracer* = ref object of RootObj
        image*: HdrImage
        camera*: Camera 

    AntiAliasing* = ref object of ImageTracer
        samplesPerSide: int
        pcg: PCG


proc newImageTracer*(image: var HdrImage, camera: Camera): ImageTracer=
    var tracer: ImageTracer = ImageTracer(image:image, camera:camera)
    result = tracer

proc fireRay*(self: var ImageTracer, col, row: int, u_pixel: float32 = 0.5, v_pixel: float32 = 0.5): Ray=
    var
        u:float32 = (float32(col) + u_pixel) / float32(self.image.width)
        v:float32 = 1.0 - (float32(row) + v_pixel) / float32(self.image.height)
    return self.camera.fireRay(u, v)

func fireAllRays*(self: var ImageTracer, f: proc): void =
    var
        color: Color
        ray: Ray
        
    for row in 0 ..< self.image.height:
        for col in 0 ..< self.image.width:
            ray = self.fireRay(col, row)
            color = f(ray)
            self.image.set_pixel(col, row, color)

func newAntiAliasing*(image: var HdrIMage, camera: Camera, samples: int, pcg: PCG): AntiAliasing=
    return AntiAliasing(image: image, camera: camera, samplesPerSide: samples, pcg: pcg)

func fireAllRays*(self: var AntiAliasing, f: proc): void=
    var
        cum_color: Color
        ray: Ray
    
    for row in 0 ..< self.image.height:
        for col in 0 ..< self.image.width:
            cum_color = Color.black()

            if self.samplesPerSide > 0:
                parallel:
                    for inter_pixel_row in countup(0, self.samplesPerSide-1):
                        for inter_pixel_col in countup(0, self.samplesPerSide-1):
                            let
                                u_pixel = (inter_pixel_col + self.pcg.random_float()) / self.samplesPerSide
                                v_pixel = (inter_pixel_row + self.pcg.random_float()) / self.samplesPerSide
                                
                                ray = spawn self.fireRay(col, row, u_pixel, v_pixel)
                                cum_color = cum_color + f(^ray)
                    self.image.sel_pixel(col, row, cum_color * (1.0 / pow(self.samplesPerSide, 2.0)))
            else:
                ray = self.fire_ray(col, row)
                self.image.set_pixel(col, row, f(ray))
