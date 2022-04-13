import hdrimage, camera 


type 
    ImageTracer* = object
        iamge*: HdrImage
        camera*: Camera 

proc fire_ray*(self: ImageTracer, col, row: int, u_pixel, v_pixel: float32): float32=
    var u_pixel = 0.5
    var v_pixel = 0.5
    var u = (col + u_pixel) / (self.image.width - 1)
    var v = (row + v_pixel) / (self.image.height - 1)
    return self.camera.fire_ray(u, v)
