import "color.nim"

type
    HdrImage* = object
        width*: int
        height*: int
        pixels*: seq[Color]

proc newHdrImage*(width, height: int): HdrImage=
    result = HdrImage(width: width, height: height, pixels: newSeq[Color](width*height))
    for i in 0..width*height:
        result.pixels[i]= newColor(0,0,0)

proc valid_coordinates(z: HdrImage, x,y:int): bool=
    return((x>=0) and (x<z.width) and (y>=0) and (y<z.height))

proc pixel_offset*(z: HdrImage, x,y:int): int {.inline.}=
    result = y * z.width + x

proc get_pixels(z: HdrImage, x,y:int): Color=
    assert z.valid_coordinates(x,y)
    return z.pixels[z.pixel_offset(x,y)]

proc set_pixels(z: HdrImage, x,y:int, new_color: var Color) = 
    assert z.valid_coordinates(x,y)
    z.pixels[z.pixel_offset(x,y)] = newColor(new_color)


        
        

