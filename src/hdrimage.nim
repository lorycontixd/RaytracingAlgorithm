import std/[strutils, streams, tables, strformat, endians]
import color, exception, utils


type
    HdrImage* = object
        width*: int
        height*: int
        pixels*: seq[Color]
        endianness*: Endianness
    Endianness* = enum
        littleEndian = "<f"
        bigEndian = ">f"

converter toEndianness*(s: string): Endianness = parseEnum[Endianness](s)




proc newHdrImage*(width, height: int): HdrImage=
    result = HdrImage(width: width, height: height, pixels: newSeq[Color](width*height))
    for i in 0..width*height-1:
        result.pixels[i] = newColor(0,0,0)
    result.endianness = Endianness.littleEndian

proc newHdrImage*(width, height: int, endianness:Endianness): HdrImage=
    result = HdrImage(width: width, height: height, pixels: newSeq[Color](width*height))
    for i in 0..width*height-1:
        result.pixels[i] = newColor(0,0,0)
    result.endianness = endianness

proc newHdrImage*(other:HdrImage): HdrImage {.inline.}=
    result = HdrImage(width:other.width, height:other.height, pixels:other.pixels, endianness:other.endianness)

proc parse_endianess*(self: HdrImage, line:string): string = # Remove public on release
    var flt: float32
    try:
        flt = parseFloat(line)
    except ValueError:
        raise newException(ValueError, "Invalid endianness specification") # Convert to custom exception
    if flt > 0:
        return $Endianness.bigEndian
    elif flt < 0:
        return $Endianness.littleEndian
    else:
        raise newException(ValueError, "Invalid endianness specification")

proc parse_img_size*(self: HdrImage, line:string): (int,int) = # Remove public on release
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

proc pixel_offset*(self: var HdrImage, x,y:int): int {.inline.} =
    result = y * self.width + x

proc get_pixel*(self: var HdrImage, x,y:int): Color {.inline.} =
    assert self.valid_coordinates(x,y)
    result = self.pixels[self.pixel_offset(x,y)]

proc set_pixel*(self: var HdrImage, x,y:int, new_color: Color) {.inline.} = 
    assert self.valid_coordinates(x,y)
    let offset = self.pixel_offset(x,y)
    self.pixels[offset] = new_color




proc read_pfm*(self: var HdrImage, stream: FileStream, buffer_size: int = 12): HdrImage {.inline.} =
    # Magic
    
    var magic: string = stream.readLine()
    if magic != "PF":
        raise PFMImageError.newException("Invalid Magic code for PFM image")
    # Image size
    let sizeline = stream.readLine()
    var img_size: (int,int) = self.parse_img_size(sizeline)
    # Endianness
    let endianline = stream.readLine()
    let endian = self.parse_endianess(endianline)

    result = newHdrImage(img_size[0], img_size[1], endian)
    var
        buffer: array[12, byte]
        r,g,b: float32
        rbuf, gbuf, bbuf: array[4,byte]

    for i in 0..(img_size[0] * img_size[1])-1: #replace with size of pixels
        discard stream.readData(addr(buffer), buffer_size)
        var
            rbuf = seqToArray32( buffer[0..3])
            gbuf = seqToArray32( buffer[4..7])
            bbuf = seqToArray32( buffer[8..11])
        # need to divide little and big endian
        littleEndian32(addr r, addr rbuf)
        littleEndian32(addr g, addr gbuf)
        littleEndian32(addr b, addr bbuf)
        result.pixels[i] = newColor(r,g,b)

proc write_pfm*(self: var HdrImage, stream: FileStream) {.inline.}=
    stream.write("PF\n")
    stream.write(fmt"{self.width} {self.height}{'\n'}")
    if self.endianness == Endianness.littleEndian:
        stream.write("-1.0\n")
    else:
        stream.write("1.0\n")
    var
        r,g,b: float32
        rbuf, gbuf, bbuf: array[4,byte]
        buffer: array[12, byte]
    
    for pixel in self.pixels:
        r = pixel.r
        g = pixel.g
        b = pixel.b
        # need to divide little and big endian
        littleEndian32(addr rbuf, addr r)
        littleEndian32(addr gbuf, addr g)
        littleEndian32(addr bbuf, addr b)
        buffer[0..3] = rbuf
        buffer[4..7] = gbuf
        buffer[8..11] = bbuf
        stream.writeData(addr(buffer), 12)
    doAssert stream.atEnd() == true

proc write_black*(self: var HdrImage, stream: FileStream) {.inline.}=
    stream.write("PF\n")
    stream.write(fmt"{self.width} {self.height}{'\n'}")
    if self.endianness == Endianness.littleEndian:
        stream.write("-1.0")
    else:
        stream.write("1.0")
    
    var buffer: array[16, byte]
    for i in 0..(self.width*self.height):
        stream.writeData(addr(buffer), 16)
    stream.close()

proc write_white*(self: var HdrImage, stream: FileStream) {.inline.}=
    stream.write("PF\n")
    stream.write(fmt"{self.width} {self.height}{'\n'}")
    if self.endianness == Endianness.littleEndian:
        stream.write("-1.0")
    else:
        stream.write("1.0")
    
    var buffer: array[16, byte]
