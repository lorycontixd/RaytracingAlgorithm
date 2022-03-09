
type
    Color* = object
        r*: float32
        g*: float32
        b*: float32
    
proc newColor*(): Color=
    result = Color(r:0, g:0, b:0)

proc newColor*(r,g,b: float32): Color=
    result = Color(r:r, g:g, b:b)