import std/[strutils, streams, strformat, endians, random, math, options]
import color, exception, utils, logger
import simplepng


type
    HdrImage* = object # class used to implement an HDR Image from a color matrix
        width*: int # number of columns of 2D color-matrix
        height*: int # number of rows of 2D color-matrix
        pixels*: seq[Color] # 2D color-matrix, represented as a 1D array
        distanceHits*: seq[float32]
        endianness*: Endianness # kind of byte/bit endianness

    Endianness* = enum
        littleEndian = "<f" # crescent pows in reading bytes
        bigEndian = ">f" # decrescent pows in reading bytes

converter toEndianness*(s: string): Endianness = parseEnum[Endianness](s)


proc newHdrImage*(): HdrImage {.inline.} =
    ## constructor for HDR Image
    ## Parameters
    ##      /
    ## Returns
    ##      (HdrImage) : a black image with little endianness
    result = HdrImage(
        width:0,
        height:0,
        pixels: newSeq[Color](0),
        distanceHits: newSeq[float32](0),
        endianness: Endianness.littleEndian
    )

proc newHdrImage*(width, height: int): HdrImage {.inline.} =
    ## constructor for HDR Image
    ## Parameters: 
    ##      width , height (int, int)
    ## 
    ## Returns:  
    ##      (HdrImage): black HdrImage with little endianness
    result = HdrImage(width: width, height: height, pixels: newSeq[Color](width*height), distanceHits: newSeq[float32](width*height))
    for i in 0..width*height-1:
        result.pixels[i] = newColor(0,0,0)
    for i in 0..width*height-1:
        result.distanceHits[i] = Inf
    result.endianness = Endianness.littleEndian

proc newHdrImage*(width, height: int, endianness:Endianness): HdrImage {.inline.} =
    ## constructor for HDR Image
    ## Parameters: 
    ##      width, height (int, int), 
    ##      endianness (Endianness)
    ## 
    ## Returns: 
    ##      (HdrImage): black HdrImage with the endianness requested
    result = HdrImage(width: width, height: height, pixels: newSeq[Color](width*height), distanceHits: newSeq[float32](width*height))
    for i in 0..width*height-1:
        result.pixels[i] = newColor(0,0,0)
    for i in 0..width*height-1:
        result.distanceHits[i] = Inf
    result.endianness = endianness

proc newHdrImage*(other:HdrImage): HdrImage {.inline.} =
    ## constructor for HDR Image
    ## Parameters:
    ##      other (HdrImage)
    ## Returns:
    ##      (HdrImage): an image equal to 'other' HdrImage
    result = HdrImage(width:other.width, height:other.height, pixels:other.pixels, distanceHits: other.distanceHits, endianness:other.endianness)

proc parse_endianess*(_: typedesc[HdrImage], line:string): string = # Remove public on release
    ## Assign endianness 
    ## Parameters: 
    ##      self (HdrImage)
    ##      line (string) : value specifying the endianness
    ## Returns: 
    ##      (string) :Endianness read in line
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

proc parse_img_size*(_: typedesc[HdrImage], line:string): (int,int) = # Remove public on release
    ## Assign values to 'width' and 'height'
    ## Parameters: 
    ##      self (HdrImage)
    ##      line (string): values for width and height
    ## 
    ## Returns: 
    ##      width, height (int, int)
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
    ## Verifies if (x, y) are coordinates within the 2D matrix
    ## Parameters: 
    ##      self (HdrImage)
    ##      x,y (int,int): coordinates
    ## 
    ## Returns: 
    ##      True (if valid coordinates), False (else)
    result = ((x>=0) and (x<self.width) and (y>=0) and (y<self.height))

proc pixel_offset*(self: HdrImage, x,y:int): int {.inline.} =
    ## Computes the index position of pixel (x,y) in the array 
    ## The pixel at the top-left corner has coordinates (0, 0)
    ## 
    ## -Parameters: 
    ##      self (HdrImage)
    ##      x,y (int,int) : coordinates
    ## 
    ## -Returns: 
    ##      result (int)
    result = y * self.width + x

proc get_pixel*(self: HdrImage, x,y:int): Color {.inline.} =
    ## Returns the `Color` value for a pixel in the image
    ## The pixel at the top-left corner has coordinates (0, 0)
    ##
    ## -Parameters: 
    ##      self (HdrImage)
    ##      x,y (int,int) : coordinates (x for width, y for height)
    ## 
    ## -Returns: 
    ##      (Color) : pixel of Color with coordinates x,y
    try:
        assert self.valid_coordinates(x,y)
    except:
        echo fmt"validating {x},{y} in {self.width},{self.height}"
    result = self.pixels[self.pixel_offset(x,y)]

proc set_pixel*(self: var HdrImage, x,y:int, new_color: Color) {.inline.} = 
    ## Sets the new color for a pixel in the image
    ## The pixel at the top-left corner has coordinates (0, 0)
    ## -Parameters: 
    ##      HdrImage 
    ##      x,y (int,int): coordinates
    ##      new_color (Color): color to be assigned 
    ## 
    ## -Returns: 
    ##      no return, but set pixel of coordinates x,y to Color
    if not self.valid_coordinates(x,y):
        raise ValueError.newException(fmt"Invalid coordinates: {x},{y} for width,height: {self.width}x{self.height}")
    let offset = self.pixel_offset(x,y)
    self.pixels[offset] = new_color

proc set_pixel_distance*(self: var HdrImage, x,y: int, distance: float32): void {.inline.}=
    ##
    if not self.valid_coordinates(x,y):
        raise ValueError.newException(fmt"Invalid coordinates: {x},{y} for width,height: {self.width}x{self.height}")
    let offset = self.pixel_offset(x,y)
    self.distanceHits[offset] = distance

proc average_luminosity*(self: var HdrImage, delta: float = 1e-10): float32 {.inline.} =
    ## Returns the average luminosity of the image
    ## `delta` parameter is used to prevent  numerical problems for underilluminated pixels
    ##
    ## -Parameters: 
    ##      self (HdrImage)
    ##      delta (float) :  default_value:  1e-10
    ## 
    ## -Returns: 
    ##      average luminosity (float)
    var cumsum: float = 0.0
    for pix in self.pixels:
        cumsum += log10(delta + pix.luminosity())
    return pow(10, cumsum / float(size(self.pixels)))

proc set_size*(self: var HdrImage, w,h: int): void=
    self.width = w
    self.height = h


## ------------------ FILLERS -------------------------
proc fill_pixels*(self: var HdrImage, color: Color) {.inline.}=
    ## Colors the image with 'color'
    for i in 0..size(self.pixels)-1:
        self.pixels[i] = color

proc fill_black*(self: var HdrImage)=
    ## Colors the image with 'black'
    self.fill_pixels(newColor("black"))

proc fill_white*(self: var HdrImage)=
    ## Colors the image with 'white'
    self.fill_pixels(newColor("white"))

proc fill_red*(self: var HdrImage)=
    ## Colors the image with 'red'
    self.fill_pixels(newColor("red"))

proc fill_green*(self: var HdrImage)=
    ## Colors the image with 'green'
    self.fill_pixels(newColor("green"))

proc fill_blue*(self: var HdrImage)=
    ## Colors the image with 'blue'
    self.fill_pixels(newColor("blue"))

proc fill_random*(self: var HdrImage)=
    ## Colors the image with a random color
    for i in 0..self.width-1:
        for j in 0..self.height-1:
            self.set_pixel(i,j, newColor(
                rand(1.0),
                rand(1.0),
                rand(1.0)
            ))

proc fill_gradient*(self: var HdrImage)=
    ## Colors the image with a gradient
    for i in 0..self.width-1:
        for j in 0..self.height-1:
            self.set_pixel(i,j, newColor(
                float32(i / self.width),
                float32(i / self.width),
                float32(i / self.width)
            ))



proc read_pfm*(self: var HdrImage, stream: Stream) {.inline.} =
    ##
    ##    Read PFM: Reads PFM file defined by stream and stores it in the current HdrImage object.
    ##    
    ##    Parameters:
    ##        - stream: Stream to read bytes from
    ##    
    ##    Returns
    ##        No returns, sets this object instead.
    ##
    
    debug("Read_pfm called from HdrImage")
    # Magic
    var magic: string = stream.readLine() # Reads first line for magic code
    if magic != "PF":
        raise PFMImageError.newException("Invalid Magic code for PFM image")
    # Image size
    let sizeline = stream.readLine() # Reads second line for image size
    var img_size: (int,int) = HdrImage.parse_img_size(sizeline)
    self.width = img_size[0]
    self.height = img_size[1]
    self.pixels = newSeq[Color](self.width*self.height) # Resets pixels to new size read from file
    # Endianness
    let endianline = stream.readLine() # Reads third line for endianness
    self.endianness = HdrImage.parse_endianess(endianline)
    
    # Fill pixel data from file bytes
    var
        buffer_size = 12
        buffer: array[12, byte] # Create buffer variable: will hold the 12 bytes relative to the 3 floats (R,G,B)
        r,g,b: float32 # Create RGB variables to store read colors
        rbuf, gbuf, bbuf: array[4,byte] # Create single buffer 

    for j in countdown(self.height-1, 0):    #read from bottom to up
        for i in 0..self.width-1:            #read from left to right
            discard stream.readData(addr(buffer), buffer_size) # Read 12 bytes data and save it in the buffer
            rbuf = seqToArray32( buffer[0..3]) # Split the 12 bytes buffer in 3 buffers of 4 bytes (1 per color)
            gbuf = seqToArray32( buffer[4..7])
            bbuf = seqToArray32( buffer[8..11])
            # need to divide little and big endian
            case self.endianness:
                of Endianness.littleEndian:
                    littleEndian32(addr r, addr rbuf) #  Convert from 4 bytes to float (littleEndian)
                    littleEndian32(addr g, addr gbuf)
                    littleEndian32(addr b, addr bbuf)
                of Endianness.bigEndian:
                    bigEndian32(addr r, addr rbuf) #  Convert from 4 bytes to float (bigEndian)
                    bigEndian32(addr g, addr gbuf)
                    bigEndian32(addr b, addr bbuf)
            self.set_pixel(i,j, newColor(r,g,b))
    debug(fmt"Image read, detected size({self.width},{self.height})")

#proc write_bytes(self: var HdrImage, stream: Stream)=
    

proc write_pfm*(self: var HdrImage, stream: Stream) {.inline.}=
    ##
    ## Write PFM: Writes current HdrImage to a generic stream with PFM format.
    ##    If stream is of type FileStream, the image is instantly written to file.
    ##    If stream is of type StringStream, the image is stored in the stream as a string.
    ## 
    ## Parameters:
    ##         stream: Stream to write bytes into.
    ##    
    ## Returns:
    ##         No returns, output is saved in the argument stream.

    debug("Write_pfm called from HdrImage")
    # Magic
    stream.write("PF\n")
    # Image size
    stream.write(fmt"{self.width} {self.height}{'\n'}")
    # Scale factor - Endianness
    if self.endianness == Endianness.littleEndian:
        stream.write("-1.0\n")
    else:
        stream.write("1.0\n")
    var
        r,g,b: float32 # Temporary variables to store each pixel colors
        rbuf, gbuf, bbuf: array[4,byte] # 4 bytes buffer to save each 
        buffer: array[12, byte] # 12 bytes buffer to
    for j in countdown(self.height-1, 0):
        for i in 0..self.width-1:
            let pixel = self.get_pixel(i, j)
            r = pixel.r
            g = pixel.g
            b = pixel.b
            # For each pixel, convert RGB values into a 4 bytes buffer each
            case self.endianness:
                of Endianness.littleEndian:
                    littleEndian32(addr rbuf, addr r)
                    littleEndian32(addr gbuf, addr g)
                    littleEndian32(addr bbuf, addr b)
                of Endianness.bigEndian:
                    bigEndian32(addr rbuf, addr r)
                    bigEndian32(addr gbuf, addr g)
                    bigEndian32(addr bbuf, addr b)
            # Concatenate the 3 buffers into one
            buffer[0..3] = rbuf 
            buffer[4..7] = gbuf
            buffer[8..11] = bbuf
            stream.writeData(addr(buffer), 12)  # Write the buffer to stream
    doAssert stream.atEnd() == true

proc write_png*(self: var HdrImage, output_file: string, gamma:float =1.0){.inline.}= 
    ## saves a PNG file with pixels in [0,255] set to byte
    ## 
    ## Parameters:
    ##      self (HdrImage)
    ##      output_file (string): title of file
    ##      gamma (float) : default_value = 1.0
    ## 
    ## Returns: 
    ##      output_file PNG format
    var p = initPixels(self.width, self.height)
    var i: int = 0
    for pixel in p.mitems:
        pixel.setColor(
            cast[byte]( int(255 * pow(self.pixels[i].r, 1.0/gamma))),
            cast[byte]( int(255 * pow(self.pixels[i].g, 1.0/gamma))),
            cast[byte]( int(255 * pow(self.pixels[i].b, 1.0/gamma))),
            255'u8
        )
        i+=1
    simplePNG(output_file, p)

