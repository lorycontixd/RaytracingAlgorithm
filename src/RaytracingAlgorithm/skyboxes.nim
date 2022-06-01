import shape

type
    Skybox* = ref object of RootObj
        shapes*: seq[Shape]

    ClearSky* = ref object of Skybox

proc newClearSky(): ClearSky=
    return ClearSky()