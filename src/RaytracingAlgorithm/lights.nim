import geometry, color

type
    Light* = ref object of RootObj # holds information about a point light (a Dirac's delta in the rendering equation)
        position*: Point #  position of the point light in 3D space
        color*: Color # color of the point light
        linearRadius*: float32 #used to compute the solid angle subtended by the light at a given distance 

    Pointlight* = ref object of Light


func newPointlight*(position: Point, color: Color, linearRadius: float32): Pointlight=
    ## constructor for Pointlight
    return Pointlight(position: position, color: color, linearRadius: linearRadius)
