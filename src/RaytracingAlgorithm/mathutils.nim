

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