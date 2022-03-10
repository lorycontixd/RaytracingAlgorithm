import "color.nim"

type
    HdrImage* = object
        width*: int
        height*: int
        pixels*: seq[Color]

proc newHdrImage*(width, height: int): HdrImage=
    result = HdrImage(width: width, height: height, pixels: newSeq[Color](width*height))
    for i in 0..width*height-1:
        result.pixels[i] = newColor(0,0,0)

proc newHdrImage*(other:HdrImage): HdrImage {.inline.}=
    result = HdrImage(width:other.width, height:other.height, pixels:other.pixels)


proc valid_coordinates*(self: HdrImage, x,y:int): bool=
    result = ((x>=0) and (x<self.width) and (y>=0) and (y<self.height))

proc pixel_offset*(self: HdrImage, x,y:int): int {.inline.}=
    result = y * self.width + x

proc get_pixel*(self: HdrImage, x,y:int): Color=
    assert self.valid_coordinates(x,y)
    result = self.pixels[self.pixel_offset(x,y)]

proc set_pixel*(self: var HdrImage, x,y:int, new_color: Color)= 
    assert self.valid_coordinates(x,y)
    let offset = self.pixel_offset(x,y)
    self.pixels[offset] = new_color


        
        

