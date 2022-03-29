import std/[os]

type
    CustomException* = ref object of Exception


    ImageError* = object of CustomException

    PFMImageError* = object of ImageError
    PNGImageError* = object of ImageError

    InvalidColorError* = object of CustomException

    InputParsingError* = object of CustomException
    TestError* = object of Exception

#[
template myNewException*(exceptn: typedesc, message: string; parentException: ref Exception = nil): untyped =
    let parent = parentDir(getCurrentDir())
    let errorDir = joinPath(parent,"examples","errors")
    if not existsDir(dir):

    (ref exceptn)(msg: message, parent: parentException)
]#