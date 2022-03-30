import neo

type
    Normal* = object
        x*, y*, z*: float32

    Transformation* = object
        m*, inverse*: Matrix[float32]