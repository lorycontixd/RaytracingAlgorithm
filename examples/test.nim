import "../src/RaytracingAlgorithm/renderer.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/ray.nim"

var onoff: OnOffRenderer = newOnOffRenderer(newWorld( cast[seq[Shape]](@[newSphere()])), Color.black(), Color.white())

let x = onoff.Get()
echo x(newRay())