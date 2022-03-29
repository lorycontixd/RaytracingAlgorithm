import unittest
import "../src/RaytracingAlgorithm/color.nim"

let c1=Color(r:1,g:2,b:3)
let c2=Color(r:4,g:5,b:6)

#funzioni supporto ai test
assert c1+c2 == newColor(5,7,9)
assert c1*2 == newColor(2,4,6)
assert c1 == newColor(1,2,3)
assert c2 == newColor(4,5,6+1e-6)

