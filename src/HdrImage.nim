import std/strutils
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

proc parse_endianess*(self: HdrImage, line:string): string= # Remove public on release
    var flt: float32
    try:
        flt = parseFloat(line)
    except ValueError:
        raise newException(ValueError, "Invalid endianness specification") # Convert to custom exception
    if flt > 0:
        return ">f"
    elif flt < 0:
        return "<f"
    else:
        raise newException(ValueError, "Invalid endianness specification")

proc parse_img_size*(self: HdrImage, line:string): tuple = # Remove public on release
    let elements = line.split(" ")
    if len(elements) != 2:
        raise newException(ValueError, "Invalid image size specification")

    var
        width, height: int
    try:
        width = parseInt(elements[0])
        height = parseInt(elements[1])
        if width < 0 or height < 0:
            raise newException(ValueError, "")
    except ValueError:
        raise newException(ValueError, "Invalid width/height") # Convert to custom exception
    return (width, height)
    

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


        
        

