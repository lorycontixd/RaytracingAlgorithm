import geometry, color

type
    Light* = ref object of RootObj
        position*: Point
        color*: Color
        linearRadius*: float32

    Pointlight* = ref object of Light


func newPointlight*(position: Point, color: Color, linearRadius: float32): Pointlight=
    return Pointlight(position: position, color: color, linearRadius: linearRadius)
