import shape
import std/[sequtils, sugar, macros, typetraits]

type
    World* = object
        shapes*: seq[Shape]

proc newWorld*(): World =
    return World(shapes: @[])

proc newWorld*(list: seq[Shape]): World=
    return World(shapes: list)

proc Add*(self: var World, s: Shape): void=
    self.shapes.add(s)

template Add*(self: var World, shapes: varargs[Shape]): void=
    for shape in shapes:
        self.Add(shape)

#proc Remove*(self: var World, shape_id: string): void=
proc Filter*(self:World, t: typedesc): seq[Shape]=
    result = collect(newSeq):
        for i,s in self.shapes.pairs:
            echo i, " - ", s.type.name
            if s.type.name is t: s

proc Show*(self: World): void=
    for shape in self.shapes:
        echo shape.id, " --> ", shape.origin