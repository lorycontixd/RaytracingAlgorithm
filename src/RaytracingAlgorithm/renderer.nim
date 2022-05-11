import world
from color import Color
from ray import Ray
from exception import NotImplementedError, AbstractMethodError
import std/[options]

type
    Renderer* = ref object of RootObj
        world*: World
        backgroundColor*: Color

    DebugRenderer* = ref object of Renderer

    OnOffRenderer* = ref object of Renderer
        color*: Color

# ----------- Constructors -----------
func newOnOffRenderer*(world: World, backgroundColor, color: Color): OnOffRenderer=
    return OnOffRenderer(world:world, backgroundColor:backgroundColor, color:color)

func newDebugRenderer*(world: World, backgroundColor: Color): DebugRenderer=
    return DebugRenderer(world:world, backgroundColor: backgroundColor)

# ----------- Methods -----------
method Get*(renderer: Renderer): (proc(r: Ray): Color) {.base, raises:[AbstractMethodError].}=
    raise AbstractMethodError.newException("Renderer.Get is an abstract method and cannot be called.")

method Get*(renderer: DebugRenderer): (proc(r: Ray): Color) =
    return proc(r: Ray): Color=
        return renderer.backgroundColor

method Get*(renderer: OnOffRenderer): (proc(r: Ray): Color) =
    return proc(r: Ray): Color=
        let intersection = rayIntersect(renderer.world,r)
        if intersection.isSome:
            #echo intersection
            return renderer.color
        else:
            return renderer.backgroundColor



