import world
import camera
import renderer
from material import Material
import std/[tables, sets]


type
    Scene* = object
        world*: World
        camera*: Camera
        renderer*: Renderer
        materials*: Table[string, Material]
        float_variables*: Table[string, float32]
        overridden_variables*: HashSet[string]

func newScene*(): Scene=
    var w: World = newWorld()
    return Scene(world: w)
    
func newScene*(w: var World, camera: var Camera, materials: Table[string, Material], fVars: Table[string, float32], orVars: HashSet[string]): Scene=
    return Scene(world: w, camera: camera, materials: materials, float_variables: fVars, overridden_variables: orVars)


