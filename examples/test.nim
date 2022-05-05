import "../src/RaytracingAlgorithm/renderer.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/ray.nim"

var 
    w: World= newWorld()
    radius: float32 = 0.1
    #scale_tranform: Transformation = Transformation.scale(newVector3(radius, radius, radius))

w.Add(newSphere("SPHERE_0", Transformation.translation( newVector3(0.5, 0.5, 0.5)) * Transformation.scale(newVector3(radius, radius, radius)) ))
w.Add(newSphere("SPHERE_1", Transformation.translation( newVector3(0.5, 0.5, -0.5)) * Transformation.scale(newVector3(radius, radius, radius)) ))
w.Add(newSphere("SPHERE_2", Transformation.translation( newVector3(0.5, -0.5, 0.5)) * Transformation.scale(newVector3(radius, radius, radius)) ))
w.Add(newSphere("SPHERE_3", Transformation.translation( newVector3(0.5, -0.5, -0.5)) * Transformation.scale(newVector3(radius, radius, radius)) ))
w.Add(newSphere("SPHERE_4", Transformation.translation( newVector3(-0.5, 0.5, 0.5)) * Transformation.scale(newVector3(radius, radius, radius)) ))
w.Add(newSphere("SPHERE_5", Transformation.translation( newVector3(-0.5, 0.5, -0.5)) * Transformation.scale(newVector3(radius, radius, radius)) ))
w.Add(newSphere("SPHERE_6", Transformation.translation( newVector3(-0.5, -0.5, -0.5)) * Transformation.scale(newVector3(radius, radius, radius)) ))
w.Add(newSphere("SPHERE_7", Transformation.translation( newVector3(-0.5, -0.5, 0.5)) * Transformation.scale(newVector3(radius, radius, radius)) ))


var
    min: float32 = 0.1
    max: float32 = 200.0
    onoff: OnOffRenderer = newOnOffRenderer(w, Color.black(), Color.white())

var
    r1: Ray = newRay(newPoint(-2.0, 0.0, 0.0), newVector3(5/2, 1/2, 1/2).normalize(), min, max) # dir norm = (0.96, 0.19, 0.19)
    r2: Ray = newRay(newPoint(-2.0, 0.0, 0.0), newVector3(5/2, 1/2, -1/2).normalize(), min, max) # dir norm = (0.96, 0.19, -0.19)
    r3: Ray = newRay(newPoint(-2.0, 0.0, 0.0), newVector3(5/2, -1/2, 1/2).normalize(), min, max) # dir norm = (0.96, -0.19, 0.19)
    r4: Ray = newRay(newPoint(-2.0, 0.0, 0.0), newVector3(5/2, -1/2, -1/2).normalize(), min, max) # dir norm = (0.96, -0.19, -0.19)
    r5: Ray = newRay(newPoint(-2.0, 0.0, 0.0), newVector3(3/2, 1/2, 1/2).normalize(), min, max)
    r6: Ray = newRay(newPoint(-2.0, 0.0, 0.0), newVector3(3/2, 1/2, -1/2).normalize(), min, max)
    r7: Ray = newRay(newPoint(-2.0, 0.0, 0.0), newVector3(3/2, -1/2, -1/2).normalize(), min, max)
    r8: Ray = newRay(newPoint(-2.0, 0.0, 0.0), newVector3(3/2, -1/2, 1/2).normalize(), min, max)


for i in countup(0, 100000):
    let t = i/10000
    var p: Point = r1.at(t)
    echo p
    if p.isClose(newPoint(0.1151, 0.42302, 0.42302), 1e-4):
        echo "FOUND: ",i, "  -  ",t
        break


let x = onoff.Get()
echo x(r1) # dir norm = (0.96, 0.19, 0.19)
echo x(r2) # dir norm = (0.96, 0.19, -0.19)
echo x(r3) # dir norm = (0.96, -0.19, 0.19)
echo x(r4) # dir norm = (0.96, -0.19, -0.19)
echo x(r5)
echo x(r6) 
echo x(r7) 
echo x(r8) 

#echo x(newRay(newPoint(0.0, 0.0, 0.0), newVector3(1.0, 1.0, 1.0), 0.4, 200.0))