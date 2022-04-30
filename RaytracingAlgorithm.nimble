# Package

version       = "0.1.1"
author        = "Lorenzo Conti, Diana Barindelli"
description   = "RayTracing Algorith in Nim"
license       = "GPL-3.0"
srcDir        = "src"
bin           = @["RaytracingAlgorithm"]

# Dependencies
requires "nim >= 1.6.4"
requires "therapist"
requires "SimplePNG"
requires "neo"

task mytest, "Run the packages tests!":
    exec "nim cpp -r tests/test_camera.nim"

task main, "Run a script":
    exec "nim cpp -r -d:release src/RaytracingAlgorithm.nim"