import shape, rayhit, ray
import std/[sequtils, sugar, macros, typetraits, strutils, options]

type
    World* = ref object
        shapes*: seq[Shape]

func newWorld*(): World =
    return World(shapes: @[])

func newWorld*(list: seq[Shape]): World=
    return World(shapes: list)

func GetIndex*(self: World, s_id: string): int=
    for i, shape in self.shapes.pairs:
        if shape.id == s_id:
            return i
    raise IndexError.newException("ID not found in world shapes.")

method Add*(self: var World, s: Shape): void {.base.}=
    self.shapes.add(s)

method Remove*(self: var World, s_id: string): void {.base.}=
    # remove from seq
    let index = self.GetIndex(s_id)
    self.shapes.delete(index)

#[
template Add*(self: var World, shapes: varargs[Shape]): void=
    for shape in shapes:
        self.Add(shape)

template Remove*(self: var World, shapes: varargs[Shape]): void=
    for shape in shapes:
        self.Remove(shape.id)
]#
#proc Remove*(self: var World, shape_id: string): void=
func Filter*(self:World, t: typedesc): seq[Shape]=
    result = collect(newSeq):
        for i,s in self.shapes.pairs:
            if (s.id.contains(($t).toUpperAscii())): s

proc Show*(self: World): void=
    for shape in self.shapes:
        echo shape.id, " --> ", shape.origin

proc rayIntersect*(self: World, r:Ray): Option[RayHit]=
    var
        closest: Option[RayHit] = none(RayHit)
        intersection: Option[RayHit]

    for shape in self.shapes:
        intersection = shape.rayIntersect(r, false)

        if intersection == none(RayHit):
            continue
        
        if closest == none(RayHit) or intersection.get().t < closest.get().t:
            closest = intersection
    return closest
            