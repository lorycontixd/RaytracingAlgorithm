type
    Color* = object 
        r* , g* , b* : float32

proc newColor*(): Color=
    result = Color(r:0, g:0, b:0)

proc newColor*(r,g,b: float32): Color=
    result = Color(r:r, g:g, b:b)

proc newColor*(color: Color): Color=
    result = color

proc `+`*(c1,c2: Color): Color=
    return Color(r: c1.r+c2.r, g: c1.g+c2.g, b: c1.b+c2.b)

proc `*`*(c1,c2: Color): Color=
    return Color(r: c1.r*c2.r, g: c1.g*c2.g, b: c1.b*c2.b)

proc `*`*(c1: Color, a:float): Color=
    return Color(r: c1.r*a, g: c1.g*a, b: c1.b*a)

proc IsEqual(x,y: float32, epsilon:float32=1e-5): bool =
    return abs(x - y) < epsilon

proc `==`*(c1,c2: Color): bool =
    return IsEqual(c1.r, c2.r) and IsEqual(c1.g, c2.g) and IsEqual(c1.b, c2.b)

