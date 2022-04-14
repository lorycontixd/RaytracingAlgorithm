import hdrimage, camera, ray, color
import std/[typetraits]


type 
    ImageTracer* = object
        image*: HdrImage
        camera*: Camera 


proc newImageTracer*(image: HdrImage, camera:Camera = newOrthogonalCamera(2.0)): ImageTracer=
    var tracer: ImageTracer = ImageTracer(image:image, camera:camera)

proc fire_ray*(self: ImageTracer, col, row: int, u_pixel: float32 = 0.5, v_pixel: float32 = 0.5): Ray=
    var
        u:float32 = (float32(col) + u_pixel) / float32(self.image.width - 1)
        v:float32 = (float32(row) + v_pixel) / float32(self.image.height - 1)
    return self.camera.fire_ray(u, v)

proc fire_all_rays(self: ImageTracer, f: proc(r:Ray):Color ): void {.inline.} =
    var
        ray: Ray
        color: Color
    for row in 0 ..< self.image.height:
        for col in 0 ..< self.image.width:
            ray = self.fire_ray(col, row)
            color = f(ray)
            self.image.set_pixel(col, row, color)
