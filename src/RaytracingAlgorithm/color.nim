import std/[strutils, strformat]
#import docstrings
import exception, mathutils
from utils import IsEqual

type
    Color* = object  #class for RGB colors (Red, Green, Blue)
        r* , g* , b* : float32

# ------------ Constructors ---------------

proc newColor*(): Color=
    ## constructor for colors
    ## Parameters
    ##      /
    ## Returns
    ##      (Color): black (0,0,0)
    result = Color(r:0, g:0, b:0)

proc newColor*(r,g,b: float32): Color=
    ## constructor for colors
    ## Parameters
    ##      r, g, b (float32): float numbers in range [0,1] for red, green, blue
    ## Returns
    ##      (Color): corresponding color
    result = Color(r:r, g:g, b:b)

proc newColor*(color: Color): Color=
    ## constructor for colors
    ## Parameters
    ##      color (Color)
    ## Returns
    ##      (Color): new color equal to the input one
    result = color

proc newColor*(color: string): Color=
    ## constructor for some spefic colors
    ## Parameters
    ##      color (string): name of color to be created
    ## Returns
    ##      (Color): corresponding color object
    let color = toLowerAscii(color)
    case color:
        of "black":
            return newColor(0.0, 0.0, 0.0)
        of "white":
            return newColor(1.0, 1.0, 1.0)
        of "red":
            return newColor(1.0, 0.0, 0.0)
        of "green":
            return newColor(0.0, 1.0, 0.0)
        of "blue":
            return newColor(0.0, 0.0, 1.0)
        of "yellow":
            return newColor(1.0, 1.0, 0.0)
        of "cyan":
            return newColor(0.0, 1.0, 1.0)
        of "magenta":
            return newColor(1.0, 0.0, 1.0)
        of "purple":
            return newColor(0.5, 0.0, 1.0)
        of "orange":
            return newColor(1.0, 0.5, 0.0)
        of "lightblue":
            return newColor(0.0, 0.5, 1.0)
        of "grey":
            return newColor(0.5, 0.5, 0.5)
        else:
            raise InvalidColorError.newException(fmt"Base color {color} is not defined.")
           

# ------------- Methods ----------------

proc luminosity*(color: Color): float32 =
    ## Color class method to compute luminosity, as average between max and min component of the color
    ## 
    ## Parameters
    ##      color (Color)
    ## 
    ## Returns
    ##       luminosity (float32): Luminosity of the color
    let colormax = max(max(color.r, color.g), color.b)
    let colormin = min(min(color.r, color.g), color.b)
    return (colormax + colormin)/2

# ------------- Operators --------------

proc `+`*(c1,c2: Color): Color {.inline.}=
    ## Sum of two colors
    ## Parameters
    ##      c1, c2 (Color): colors to be summed
    ## Returns
    ##      (Color): a color equal to c1+c2
    return Color(r: c1.r+c2.r, g: c1.g+c2.g, b: c1.b+c2.b)

proc `*`*(c1,c2: Color): Color {.inline.}=
    ## Product of two colors
    ## Parameters
    ##      c1, c2 (Color): colors to be multiplied
    ## Returns
    ##      (Color): a color equal to c1*c2
    return Color(r: c1.r*c2.r, g: c1.g*c2.g, b: c1.b*c2.b)

proc `*`*(c1: Color, a:float32): Color {.inline.}=
    ## Product between a color and a scalar
    ## Parameters
    ##      c1 (Color): color to be multiplied
    ##      a (float): scalar 
    ## Returns
    ##      (Color): a color equal to a*c1
    return Color(r: c1.r*a, g: c1.g*a, b: c1.b*a)


proc `==`*(c1,c2: Color): bool {.inline.}=
    ## Color class method to verify if two Colors are equal
    ## 
    ## Parameters
    ##       c1 (Color): left color
    ##       c2 (Color): right color
    ## 
    ## Returns
    ##      True (r,g,b respectively of the two Colors are equal) else: False
    return IsEqual(c1.r, c2.r) and IsEqual(c1.g, c2.g) and IsEqual(c1.b, c2.b)


proc `!=`*(c1, c2: Color): bool {.inline.}=
    ## Color class method to verify if two Colors are diefferent
    ## 
    ## Parameters
    ##       c1 (Color): left color
    ##       c2 (Color): right color
    ## 
    ## Returns
    ##      False (r,g,b respectively of the two Colors are equal) , True (else)
    return not(c1==c2)

# ------------- Static methods ---------------

proc Lerp*(_: typedesc[Color], c1, c2: Color, t: var float32): Color=
    ## Returns the linear interpolated color between two colors and a scalar
    ## Parameters
    ##      c1, c2 (Color): colors used for the linear interpolation
    ##      t (float32): scalar used for the linear interpolation
    ## Returns
    ##      (Color): new color, derived from interpolation
    ##                  ex: color.red = interpolate(color1.red, color2.red, t)
    return newColor(Lerp(c1.r, c2.r, t), Lerp(c1.g, c2.g, t), Lerp(c1.b, c2.b, t))

proc black*(_: typedesc[Color]): Color {.inline.}=
    ## Returns black
    return newColor("black")

proc white*(_: typedesc[Color]): Color {.inline.}=
    ## Returns white
    return newColor("white")

proc red*(_: typedesc[Color]): Color {.inline.}=
    ## Returns red
    return newColor("red")

proc green*(_: typedesc[Color]): Color {.inline.}=
    ## Returns green
    return newColor("green")

proc blue*(_: typedesc[Color]): Color {.inline.}=
    ## Returns blue
    return newColor("blue")

proc yellow*(_: typedesc[Color]): Color {.inline.}=
    ## Returns yellow
    return newColor("yellow")

proc magenta*(_: typedesc[Color]): Color {.inline.}=
    ## Returns magenta
    return newColor("magenta")

proc cyan*(_: typedesc[Color]): Color {.inline.}=
    ## Returns cyan
    return newColor("cyan")