import logger, stats

type
    Settings* = object
        useStats*: bool
        useAntiAliasing*: bool
        useLogger*: bool
        useParallel*: bool
        
        antiAliasingRays*: int
        loggers*: seq[File]
        loggerLevel*: logger.Level


func newSettings*(): Settings=
    var loggers = newSeq[File]()
    return Settings(loggers: loggers, antiAliasingRays: 0, useStats: false, useAntiAliasing: false, useLogger: true)