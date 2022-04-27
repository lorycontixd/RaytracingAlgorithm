import color, ray

proc baseColor*(ray: Ray): Color=
    result = newColor(1.0, 2.0, 3.0)

proc customColor*(ray: Ray, c:Color): Color=
    result = c

