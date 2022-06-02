import shape, rayhit, ray, exception, lights, geometry, utils, stats
import std/[sugar, macros, typetraits, strutils, options, locks, times]

type
    World* = ref object
        shapes*: seq[Shape]
        pointLights*: seq[Light]

func newWorld*(): World =
    return World(shapes: @[])

func newWorld*(list: seq[Shape]): World=
    return World(shapes: list)

func GetIndex*(self: World, s_id: string): int {.raises: [ShapeIDNotFoundError, ValueError].}=
    for i, shape in self.shapes.pairs:
        if shape.id == s_id:
            return i
    raise newShapeIDError(s_id)#ShapeIDNotFoundError.newException("ID not found in world shapes.")

method Add*[T: Shape](self: var World, s: T): void {.base.}=
    ## Add a shape to the world scene.
    ##
    ## Parameters
    ##      s (Shape): Shape to be added
    self.shapes.add(s)

method AddLight*[T: Light](self: var World, l: T): void {.base.}=
    self.pointLights.add(l)


method Remove*(self: var World, s_id: string): void {.base.}=
    ## Remove a shape from the world scene by ID
    ## 
    ## Parameters
    ##      shape_id (string): ID of the shape to be removed from the scene
    let index = self.GetIndex(s_id)
    self.shapes.delete(index)

func Filter*(self:World, t: typedesc): seq[t]=
    ## Selects a type of shape out of all shapes in the scene.
    ## The selection is done by passing the type of the object.
    ##
    ## Parameters
    ##      t (typedesc): Type of the shapes to be selected
    ## Returns
    ##      Subsequence of desired shapes from the scene
    result = collect(newSeq):
        for i,s in self.shapes.pairs:
            if (s.id.contains(($t).toUpperAscii())): cast[t](s)

func FindFirst*(self: World, t: typedesc): Option[t]=
    for shape in self.shapes:
        if shape.id.contains(($t).toUpperAscii()):
            return some(shape)
    return none(t)

proc Show*(self: World): void=
    ## Prints all the shapes in the scene
    for shape in self.shapes:
        echo shape.id

proc rayIntersect*(self: World, r:Ray): Option[RayHit] {.inline, injectProcName.} =
    ## Shoots a ray in the scene and returns the closest shape that the ray hits.
    ##
    ## Parameters
    ##      r (Ray): Ray to be fired inside the scene
    ## 
    ## Returns
    ##      Option of a RayHit. Null if the fired ray does not intersect a shape in the scene, RayHit with collision information if a shape was hit.
    let start = now()
    var
        closest: Option[RayHit] = none(RayHit)
        intersection: Option[RayHit]
    
    for shape in self.shapes:
        intersection = shape.rayIntersect(r, false)

        if intersection == none(RayHit):
            continue
        
        if closest == none(RayHit) or intersection.get().t < closest.get().t:
            closest = intersection
    let endTime = now() - start
    mainStats.AddCall(procName, endTime, 2)
    
    return closest

func IsPointVisible*(self: World, point: Point, observer_position: Point): bool =
    let 
        dir = (point - observer_position).normalize().convert(Vector3)
        ray = newRay(observer_position, dir, 1e-2, Inf)
    for shape in self.shapes:
        if shape.rayIntersect(ray).isSome:
            return false
    return true