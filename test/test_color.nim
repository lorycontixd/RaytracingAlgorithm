import "../src/color.nim"

let c1=Color(r:1,g:2,b:3)
let c2=Color(r:4,g:5,b:6)
echo c1+c2
echo c1*2


#funzioni supporto ai test
assert c1+c2 == newColor(5,7,9)
assert c1*2 == newColor(2,4,6)