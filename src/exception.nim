

type
    ImageError* = object of Exception

    PFMImageError* = object of ImageError
    PNGImageErro* = object of ImageError

    InvalidColorError* = object of Exception