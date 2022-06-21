import std/[strformat]


type
    CustomException* =  object of CatchableError
    TestError* = object of CustomException

    AbstractMethodError* =  object of CustomException # not derivable
    NotImplementedError* =  object of CustomException
    InputError* =  object of CustomException
    TypeError* =  object of CustomException
    ImageError* =  object of CustomException
    MathError* =  object of CustomException
    IndexError* =  object of CustomException

    ParserError* =  object of InputError
    CommandLineError* =  object of InputError
    InvalidColorError* =  object of InputError
        c*: float32
        component*: string
    ShapeIDNotFoundError* =  ref object of InputError
        shape_id*: string
    
    PFMImageError* =  object of ImageError
    PNGImageError* =  object of ImageError

    ZeroDeterminantError* = object of MathError

    InvalidFormatError* = object of ParserError
    InvalidCommandError* =  object of CommandLineError # invalid command passed (render, animate, pfm2png, demo)
         

    
        


##### ------------------------------------------  CONSTRUCTORS  ----------------------------------------

## --- Input Errors
func newShapeIDError*(shape_id: string): ShapeIDNotFoundError=
    result = ShapeIDNotFoundError(shape_id: shape_id, msg: fmt"Shape id not found: {shape_id}")

func newInvalidColorError*(color: float32, component: string): InvalidColorError =
        result = InvalidColorError(c: color, component: component, msg : fmt"{component} of RGB Color is out of range [0,1]: {color}" )

