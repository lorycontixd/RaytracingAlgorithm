import "../src/RaytracingAlgorithm/geometry.nim"

var 
    a = newVector(3.0, 6.0, 2.0)
    b = newVector(-1.0, -10.0, 2.0) 

assert a+b == newVector(2.0, -4.0, 4.0)
assert a-b == newVector(4.0, 16.0, 0.0)
assert b-a == newVector(-4.0, -16.0, 0.0)
echo a*b
assert a*b == -59.0
assert b*a == a*b
assert a.norm() == 7.0

var
    c = newPoint(1.0, 1.0, 2.0)

assert a+c == newPoint(4.0, 7.0, 4.0)
assert c-a == newPoint(-2.0, -5.0, 0.0)