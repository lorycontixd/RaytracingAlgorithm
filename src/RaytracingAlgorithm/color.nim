import std/[strutils, strformat]
#import docstrings
import exception

type
    Color* = object 
        r* , g* , b* : float32

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
            raise InvalidColorError.newException(fmt"Color {color} is not defined.")

proc luminosity*(c:Color): float32 =
    let colormax = max(max(c.r, c.g), c.b)
    let colormin = min(min(c.r, c.g), c.b)
    return (colormax + colormin)/2
## 
## Color class method to compute luminosity
## 
##      -Parameters: Color
## 
##      -Returns: float 32 luminosity


proc `+`*(c1,c2: Color): Color {.inline.}=
    return Color(r: c1.r+c2.r, g: c1.g+c2.g, b: c1.b+c2.b)

proc `*`*(c1,c2: Color): Color {.inline.}=
    return Color(r: c1.r*c2.r, g: c1.g*c2.g, b: c1.b*c2.b)

proc `*`*(c1: Color, a:float): Color {.inline.}=
    return Color(r: c1.r*a, g: c1.g*a, b: c1.b*a)

proc IsEqual*(x,y: float32, epsilon:float32=1e-5): bool {.inline.}=
    return abs(x - y) < epsilon
##
## Color class method to verify if two floats are equal
## 
##      -Parameters: float32, float32
## 
##      -Returns: True (floats are close) or False (floats are not equal)

proc `==`*(c1,c2: Color): bool {.inline.}=
    return IsEqual(c1.r, c2.r) and IsEqual(c1.g, c2.g) and IsEqual(c1.b, c2.b)
##
## Color class method to verify if two Colors are equal
## 
##      -Parameters: Color, Color
## 
##      -Returns: True (r,g,b respectively of the two Colors are equal) else: False

proc `!=`*(c1, c2: Color): bool {.inline.}=
    return not(c1==c2)

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