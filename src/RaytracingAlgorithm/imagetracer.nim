import hdrimage, camera, ray, color
import std/[typetraits, macros]


type 
    ImageTracer* = object
        image*: HdrImage
        camera*: Camera 


proc newImageTracer*(image: var HdrImage, camera: Camera): ImageTracer=
    var tracer: ImageTracer = ImageTracer(image:image, camera:camera)
    result = tracer

proc fireRay*(self: var ImageTracer, col, row: int, u_pixel: float32 = 0.5, v_pixel: float32 = 0.5): Ray=
    var
        u:float32 = (float32(col) + u_pixel) / float32(self.image.width)
        v:float32 = 1.0 - (float32(row) + v_pixel) / float32(self.image.height)
    return self.camera.fireRay(u, v)

template fireAllRays*(self: var ImageTracer, f: proc): void =
    var
        color: Color
        ray: Ray
        index: int = 0
        
    for row in 0 ..< self.image.height:
        for col in 0 ..< self.image.width:
            ray = self.fireRay(col, row)
            #echo ray
            color = f(ray)
            self.image.set_pixel(col, row, color)
            #index = index + 1