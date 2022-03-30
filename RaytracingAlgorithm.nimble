# Package

version       = "0.1.0"
author        = "Lorenzo Conti, Diana Barindelli"
description   = "RayTracing Algorith in Nim"
license       = "GPL-3.0"
srcDir        = "src"


# Dependencies
requires "nim >= 1.6.4"
requires "therapist"
requires "SimplePNG"
requires "neo"

task mytest, "Run the packages tests!":
    exec "nim cpp -r tests/test_color.nim"
    exec "nim cpp -r tests/test_hdrimage.nim"