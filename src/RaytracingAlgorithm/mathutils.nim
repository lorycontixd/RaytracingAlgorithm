import geometry

## ---------------------------------------------------------------

## ---------------------------------------------------------------

func Clamp*(value: var float32, min, max: float32): float32=
    ##  Clamps a value between a minimum and a maximum float value.
    ##
    ##  Parameters
    ##      value (float32): Value to be clamped
    ##      min (float32s): Minimum clamp value
    ##      max (float32): Maximum clamp value
    ##  Returns
    ##      Clamped value between min and max
    if (value < min):
        value = min
    elif (value > max):
        value = max
    return value

func Clamp01*(value: float32): float32=
    ## Clamps value between 0 and 1, and returns the value
    ##
    ## Parameters
    ##      value (float32): Value to be clamped between 0 and 1
    ## Returns
    ##      Clamped value in [0,1]
    if value < 0.0:
        return 0.0
    elif value > 1.0:
        return 1.0
    else:
        return value

func CreateOnbFromZ*(normall: Normal): (Vector3, Vector3, Vector3)=
    ## Normal must be normalized
    var normal: Normal
    if not normal.IsNormalized():
        normal = normall.normalize()
    var sign: float32
    if normal.z > 0.0:
        sign = 1.0 
    else:
        sign = -1.0
    let
        a = -1.0 / (sign + normal.z)
        b = normal.x * normal.y * a

        e1 = newVector3(1.0 + sign * normal.x * normal.x * a, sign * b, -sign * normal.x)
        e2 = newVector3(b, sign + normal.y * normal.y * a, -normal.y)

    return (e1, e2, newVector3(normal.x, normal.y, normal.z))


func Lerp*(a,b: float32, t: var float32): float32=
    return a + (b - a) * Clamp01(t)

func LerpUnclamped*(a,b,t: float32): float32=
    return a + (b-a)*t

func LerpAngle*(a,b,t: float32): float32 = discard

func SmoothStep*(fromValue, toValue: float32, t: var float32): float32=
    ## Interpolates between min and max with smoothing at the limits
    t = Clamp01(t)
    t = -2.0 * t * t * t + 3.0 * t * t
    return toValue * t + fromValue * (1.0 - t)