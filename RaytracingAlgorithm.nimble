# Package

version       = "2.1.0"
author        = "Lorenzo Conti, Diana Barindelli"
description   = "RayTracing Algorith in Nim"
license       = "GPL-3.0"
srcDir        = "src"
bin           = @["RaytracingAlgorithm"]

# Dependencies
requires "nim >= 1.6.4"
requires "SimplePNG"
requires "cligen"
requires "stacks"

task tests, "Run the packages tests!":
    exec "testament pattern \"tests/*.nim\" "

task compile, "Compile the main script":
    exec "nim cpp -d:release ./src/RaytracingAlgorithm.nim"
