import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/utils.nim"

discard """
  action: "run"
  exitcode: 0
  output: "Testing colours"
  batchable: true
  joinable: true
  valgrind: false
  cmd: "nim cpp -r -d:release $file"
"""
echo "Testing colours"

func color_create=
    let c1 = newColor(10, 10, 10)
    let c2 = Color.red()

    assert c1 == newColor(10,10,10)
    assert c2 == newColor(1,0,0)
    assert c1 != newColor(1,2,3)

func color_operations=
    let c1 = Color(r:1,g:2,b:3)
    let c2 = Color(r:4,g:5,b:6)

    assert c1+c2 == newColor(5,7,9)
    assert c1-c2 == newColor(-3,-3,-3)
    assert c1*2 == newColor(2,4,6)
    assert c1*c2 == newColor(4,10,18)
    assert c1 == newColor(1,2,3)
    assert c2 == newColor(4,5,6+1e-6)

func color_luminosity=
    let c1 = newColor(8,9,10)
    let c2 = newColor(2,6,10)

    assert c1.luminosity().IsEqual(9)
    assert c2.luminosity().IsEqual(6)

color_create()
color_operations()
color_luminosity()