import "../src/RaytracingAlgorithm/renderer.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/world.nim"
import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/camera.nim"
import "../src/RaytracingAlgorithm/triangles.nim"
import "../src/RaytracingAlgorithm/imagetracer.nim"
import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/material.nim"
import std/[streams]

const
    width: int = 1600 
    height: int = 1000

var cam: Camera = newPerspectiveCamera(width, height, transform=Transformation.translation(newVector3(-1.5, 0.0, 0.0)))

var keymatimg: HdrImage = newHdrImage()
keymatimg.read_pfm(newFileStream("../media/objs/key/keyB_tx.pfm", fmRead))
var keymatpigment: Pigment = newImagePigment(keymatimg)
var gradientpigment: GradientPigment = newGradientPigment(Color.white(), Color.black(), 1.0, 0.5, 0.5)
#var keymatpigment: Pigment = newUniformPigment(newColor(0.9, 0.5, 0.6))

var keymat: Material = newMaterial(newDiffuseBRDF(), gradientpigment )
var keymesh: TriangleMesh = newTriangleMeshOBJ(Transformation.translation(5.0, -2.0, 3.0) * Transformation.rotationY(90.0), "../media/objs/key/key.obj", keymat)
echo "Hi0"
var keytriangles: seq[Triangle] = CreateTriangleMesh(keymesh)
var treemesh: TriangleMesh = newTriangleMeshOBJ(Transformation.translation(3.0, 3.0, 0.0) * Transformation.rotationX(90.0) * Transformation.scale(0.6, 0.6, 0.6), "../media/objs/tree/tree.obj", newMaterial(newSpecularBRDF(newUniformPigment(newColor(0.8, 0.4, 0.6))),newUniformPigment(newColor(0.8, 0.4, 0.6))))
var treetriangles: seq[Triangle] = CreateTriangleMesh(treemesh)
#materials
let sky_material = newMaterial(
    newDiffuseBRDF(newUniformPigment(Color.black())),
    newUniformPigment(newColor(1.0, 0.9, 0.5)) # ielou
)

let ground_material = newMaterial(
    newDiffuseBRDF(newCheckeredPigment(newColor(0.3, 0.5, 0.1), newColor(0.1, 0.2, 0.5)))
)

var
    w: World = newWorld()
    img: HdrImage = newHdrImage(width, height)
    tracer: ImageTracer = newImageTracer(img, cam)
    render: FlatRenderer = newFlatRenderer(w, Color.yellow())
    #render: PathTracer = newPathTracer(w, Color.black() )
#w.Add(newSphere("SPHERE_0", Transformation.scale(200.0, 200.0, 200.0) * Transformation.translation(0.0, 0.0, 0.4), sky_material))
#w.Add(newPlane("PLANE_0", Transformation.translation(0.0, 0.0, -1.0), ground_material))
for t in keytriangles:
    w.Add(t)
#for t in treetriangles:
#    w.Add(t)
tracer.fireAllRays(render.Get())

var strmWrite = newFileStream("output.pfm", fmWrite)
tracer.image.write_pfm(strmWrite)
tracer.image.normalize_image(1.0)
tracer.image.clamp_image()
tracer.image.write_png("output.png", 1.0)