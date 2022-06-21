import world
import camera
import renderer
import settings
import pcg
import logger
from material import Material
import std/[tables, sets, sequtils]


type
    Scene* = object # scene read from a file
        world*: World
        camera*: Camera
        renderer*: Renderer
        materials*: Table[string, Material]
        float_variables*: Table[string, float32]
        overridden_variables*: HashSet[string]
        settings*: Settings
        parseTimeLogs*: Table[Level, seq[string]]
        pcg*: PCG


proc newScene*(): Scene=
    ## empty constructor for scene
    var parseTimeLogs: Table[Level, seq[string]] = initTable[Level, seq[string]]()
    for lvl in logger.Level.toSeq:
        parseTimeLogs[lvl] = newSeq[string]()
    var w: World = newWorld()
    return Scene(world: w, parseTimeLogs: parseTimeLogs, settings: newSettings(), pcg: newPCG())
    
proc newScene*(pcg: PCG): Scene=
    ## empty constructor for scene
    var parseTimeLogs: Table[Level, seq[string]] = initTable[Level, seq[string]]()
    for lvl in logger.Level.toSeq:
        parseTimeLogs[lvl] = newSeq[string]()
    var w: World = newWorld()
    return Scene(world: w, parseTimeLogs: parseTimeLogs, settings: newSettings(), pcg: pcg)

func newScene*(w: var World, camera: var Camera, materials: Table[string, Material], fVars: Table[string, float32], orVars: HashSet[string]): Scene=
    ## constructor for scene
    let parseTimeLogs = initTable[Level, seq[string]]()
    return Scene(world: w, camera: camera, materials: materials, float_variables: fVars, overridden_variables: orVars, parseTimeLogs: parseTimeLogs, settings: newSettings())

proc AddParseTimeLog*(self: var Scene, msg: string, lvl: logger.Level): auto=
    self.parseTimeLogs[lvl].add(msg)