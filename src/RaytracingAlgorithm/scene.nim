import world
import camera
from material import Material
import std/[tables, sets]


type
    Scene* = object
        world*: World
        camera*: Camera
        materials*: Table[string, Material]
        float_variables*: Table[string, float32]
        overridden_variables*: HashSet[string]

func newScene*(): Scene=
    return Scene()
    
func newScene*(w: var World, camera: var Camera, materials: Table[string, Material], fVars: Table[string, float32], orVars: HashSet[string]): Scene=
    return Scene(world: w, camera: camera, materials: materials, float_variables: fVars, overridden_variables: orVars)


