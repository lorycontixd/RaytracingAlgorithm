import "../src/RaytracingAlgorithm/geometry.nim"

var a= Vector(x: 3.0, y: 2.0, z: 1.0)
var b= Vector(x: -3.0, y: 5.0, z: -7.0)
var c= a+b
assert c == Vector(x: 0.0, y: 7.0, z: -6.0)