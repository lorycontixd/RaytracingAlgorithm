import std/[os, strformat]

type
    CustomException* = ref object of Exception
    TestError* = object of Exception

    AbstractMethodError* = object of CustomException # not derivable
    NotImplementedError* = object of CustomException
    InputError* = object of CustomException
    ValueError* = object of CustomException
    TypeError* = object of CustomException
    ImageError* = object of CustomException

    ParserError* = object of InputError
    InvalidColorError* = object of InputError
    
    PFMImageError* = object of ImageError
    PNGImageError* = object of ImageError

    InvalidCommandError* = object of ParserError # invalid command passed (render, animate, pfm2png)

    ShapeIDNotFoundError* = object of InputError
        shape_id*: string


##### ------------------------------------------  CONSTRUCTORS  ----------------------------------------

## --- Input Errors
func newShapeIDError(shape_id: string): ShapeIDNotFoundError=
    result = newException(ShapeIDNotFoundError)
    result.shape_id = shape_id
    result.msg = fmt"Shape id not found: {shape_id}"