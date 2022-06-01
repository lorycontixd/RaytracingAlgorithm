import shape

type
    Skybox* = ref object of RootObj
        shapes*: seq[Shape]

    ClearSky* = ref object of Skybox

proc newSkyBox*(filename: string): Skybox=
    # open stream
    # load hdrimage
    # set to big sphere
    return Skybox()

proc newClearSky*(): ClearSky=
    return ClearSky()