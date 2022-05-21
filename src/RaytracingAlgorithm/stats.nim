import std/[times, nimprof, typetraits, strutils]
import renderer
type
    Stats* = object
        # time
        startTime*: DateTime
        endTime*: DateTime
        duration*: Duration

        # tools
        renderer*: string
        imageWidth*: int
        imageHeight*: int
        
        #pcg
        averageFloatExtracted*: float32

        # rays
        
        raysShot*: int

        # world
        shapeCount: int




proc newStats*(): Stats =
    return Stats(startTime: now())

proc newStats*(renderer: Renderer): Stats =
    let renderer = $renderer.type.name.toLowerAscii()
    return Stats(renderer: renderer)

proc closeStats*(self: var Stats): void =
    self.endTIme = now()
    self.duration = self.endTime - self.startTime

func ToFile*(): void = discard


func SetRaysShot*(self: var Stats, renderer: Renderer): void=
    self.raysShot = renderer.raysShot
