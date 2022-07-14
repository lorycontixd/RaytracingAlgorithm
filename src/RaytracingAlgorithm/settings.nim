import logger, postprocessing

type
    Settings* = object
        useStats*: bool
        useAntiAliasing*: bool
        useLogger*: bool
        useParallel*: bool
        usePostProcessing*: bool
        
        antiAliasingRays*: int
        loggers*: seq[File]
        loggerLevel*: logger.Level

        isAnimated*: bool
        animDuration*: int
        animFPS*: int

        width*: int
        height*: int
        hasDefinedWidth*: bool
        hasDefinedHeight*: bool

        postProcessingEffects*: seq[PostProcessingEffect]

        


func newSettings*(): Settings=
    var loggers = newSeq[File]()
    return Settings(loggers: loggers, antiAliasingRays: 0, useStats: false, useAntiAliasing: false, useLogger: true, isAnimated: false, animDuration: 3, animFPS: 30, width: 800, height: 600, hasDefinedWidth: false, hasDefinedHeight: false)

proc SetDuration*(self: var Settings, dur: int): void=
    self.animDuration = dur

func SetFPS*(self: var Settings, fps: int): void=
    self.animFPS = fps