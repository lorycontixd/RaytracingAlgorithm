import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import std/[math]
import neo

var 
    a = newVector3(3.0, 6.0, 2.0)
    b = newVector3(-1.0, -10.0, 2.0) 

assert a+b == newVector3(2.0, -4.0, 4.0)
assert a-b == newVector3(4.0, 16.0, 0.0)
assert a*b == -59.0
assert b*a == a*b
assert a.norm() == 7.0

var
    c = newPoint(1.0, 1.0, 2.0)

assert a+c == newPoint(4.0, 7.0, 4.0)
assert c-a == newPoint(-2.0, -5.0, 0.0)

assert a[0] == 3.0
assert b[2] == 2.0
assert c[1] == 1.0
assert $a == "Vector3(3.0,6.0,2.0)"
assert $c == "Point(1.0,1.0,2.0)"

var
    n = newNormal(1,1,1)


let m7 = matrix(@[
    @[1.2'f32, 3.5'f32, 4.3'f32],
    @[1.1'f32, 4.2'f32, 1.7'f32]
  ])

var
    t: Transformation = newTransormation()
    id = IdentityMatrix()
    zero = Zeros()
