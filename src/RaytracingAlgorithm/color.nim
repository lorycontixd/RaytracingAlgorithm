import std/[strutils, strformat]
#import docstrings
import exception

type
    Color* = object 
        r* , g* , b* : float32

# ------------ Constructors ---------------

proc newColor*(): Color=
    result = Color(r:0, g:0, b:0)

proc newColor*(r,g,b: float32): Color=
    result = Color(r:r, g:g, b:b)

proc newColor*(color: Color): Color=
    result = color

proc newColor*(color: string): Color=
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
    ## Color class method to compute luminosity
    ## 
    ## Parameters
    ## - color (Color)
    ## 
    ## Returns
    ## - luminosity (float32): Luminosity of the color
    let colormax = max(max(color.r, color.g), color.b)
    let colormin = min(min(color.r, color.g), color.b)
    return (colormax + colormin)/2

# ------------- Operators --------------

proc `+`*(c1,c2: Color): Color {.inline.}=
    return Color(r: c1.r+c2.r, g: c1.g+c2.g, b: c1.b+c2.b)

proc `*`*(c1,c2: Color): Color {.inline.}=
    return Color(r: c1.r*c2.r, g: c1.g*c2.g, b: c1.b*c2.b)

proc `*`*(c1: Color, a:float): Color {.inline.}=
    return Color(r: c1.r*a, g: c1.g*a, b: c1.b*a)

proc IsEqual*(x,y: float32, epsilon:float32=1e-5): bool {.inline.}=
    ## Color class method to verify if two floats are approximately equal
    ## 
    ## Parameters
    ## - x (float32): left float
    ## - y (float32): right float
    ## 
    ## Returns
    ##      True (floats are close) or False (floats are not equal)
    return abs(x - y) < epsilon


proc `==`*(c1,c2: Color): bool {.inline.}=
    ## Color class method to verify if two Colors are equal
    ## 
    ## Parameters
    ## - c1 (Color): left color
    ## - c2 (Color): right color
    ## 
    ## Returns
    ##      True (r,g,b respectively of the two Colors are equal) else: False
    return IsEqual(c1.r, c2.r) and IsEqual(c1.g, c2.g) and IsEqual(c1.b, c2.b)


proc `!=`*(c1, c2: Color): bool {.inline.}=
    return not(c1==c2)

# ------------- Static methods ---------------

proc black*(_: typedesc[Color]): Color {.inline.}=
    return newColor("black")

proc white*(_: typedesc[Color]): Color {.inline.}=
    return newColor("white")

proc red*(_: typedesc[Color]): Color {.inline.}=
    return newColor("red")

proc green*(_: typedesc[Color]): Color {.inline.}=
    return newColor("green")

proc blue*(_: typedesc[Color]): Color {.inline.}=
    return newColor("blue")

proc yellow*(_: typedesc[Color]): Color {.inline.}=
    return newColor("yellow")

proc magenta*(_: typedesc[Color]): Color {.inline.}=
    return newColor("magenta")

proc cyan*(_: typedesc[Color]): Color {.inline.}=
    return newColor("cyan   ")