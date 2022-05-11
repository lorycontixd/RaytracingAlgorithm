import shape, rayhit, ray, exception
import std/[sequtils, sugar, macros, typetraits, strutils, options]

type
    World* = ref object
        shapes*: seq[Shape]

func newWorld*(): World =
    return World(shapes: @[])

func newWorld*(list: seq[Shape]): World=
    return World(shapes: list)

func GetIndex*(self: World, s_id: string): int {.raises: [ShapeIDNotFoundError, ValueError].}=
    for i, shape in self.shapes.pairs:
        if shape.id == s_id:
            return i
    raise newShapeIDError(s_id)#ShapeIDNotFoundError.newException("ID not found in world shapes.")

method Add*(self: var World, s: Shape): void {.base.}=
    ## Add a shape to the world scene.
    ##
    ## Parameters
    ##      s (Shape): Shape to be added
    self.shapes.add(s)

method Remove*(self: var World, s_id: string): void {.base.}=
    ## Remove a shape from the world scene by ID
    ## 
    ## Parameters
    ##      shape_id (string): ID of the shape to be removed from the scene
    let index = self.GetIndex(s_id)
    self.shapes.delete(index)

func Filter*(self:World, t: typedesc): seq[Shape]=
    ## Selects a type of shape out of all shapes in the scene.
    ## The selection is done by passing the type of the object.
    ##
    ## Parameters
    ##      t (typedesc): Type of the shapes to be selected
    ## Returns
    ##      Subsequence of desired shapes from the scene
    result = collect(newSeq):
        for i,s in self.shapes.pairs:
            if (s.id.contains(($t).toUpperAscii())): s

proc Show*(self: World): void=
    ## Prints all the shapes in the scene
    for shape in self.shapes:
        echo shape.id

proc rayIntersect*(self: World, r:Ray): Option[RayHit]=
    ## Shoots a ray in the scene and returns the closest shape that the ray hits.
    ##
    ## Parameters
    ##      r (Ray): Ray to be fired inside the scene
    ## 
    ## Returns
    ##      Option of a RayHit. Null if the fired ray does not intersect a shape in the scene, RayHit with collision information if a shape was hit.
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
            