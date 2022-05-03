import world
from color import Color
from ray import Ray
from exception import NotImplementedError, AbstractMethodError
import std/[options]

type
    Renderer* = ref object of RootObj
        world*: World
        backgroundColor*: Color

    OnOffRenderer* = ref object of Renderer
        color*: Color

func newOnOffRenderer*(world: World, backgroundColor, color: Color): OnOffRenderer=
    return OnOffRenderer(world:world, backgroundColor:backgroundColor, color:color)

method Get*(renderer: Renderer): proc {.base, raises:[AbstractMethodError].}=
    raise AbstractMethodError.newException("Renderer.Get is an abstract method and cannot be called.")

method Get*(renderer: OnOffRenderer): (proc(r: Ray): Color) =
    return proc(r: Ray): Color=
        if rayIntersect(renderer.world,r).isSome:
            return renderer.color
        else:
            return renderer.backgroundColor


    
