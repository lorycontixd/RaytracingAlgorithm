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
import "../src/RaytracingAlgorithm/animation.nim"
import "../src/RaytracingAlgorithm/material.nim"
import std/[streams, enumerate, options]

const
    width: int = 800 
    height: int = 600

var cam: Camera = newPerspectiveCamera(width, height, transform=Transformation.rotationY(90) * Transformation.translation(newVector3(-1.0, 0.0, 0.0)))
var keymatimg: HdrImage = newHdrImage()

var im: HdrImage = newHdrImage()
im.read_pfm(newFileStream("../media/skyboxes/quadrati.pfm", fmRead))

var
    img_mat: Material = newMaterial(newDiffuseBRDF(newImagePigment(im)))
    gradient_mat: Material = newMaterial(newDiffuseBRDF(pigment=newGradientPigment(Color.blue(), Color.red(), 1.0, 0.5, 0.5)))

#var mesh: TriangleMesh = newTriangleMeshOBJ(Transformation.translation(0.0, 0.0, 0.0) * Transformation.rotationZ(40.0) * Transformation.rotationY(20.0), "cube.obj", newMaterial(newPhongBRDF(newUniformPigment(Color.blue())), newGradientPigment(Color.yellow(), Color.blue(), 1.0, 0.0, 1.0)))
var mesh: TriangleMesh = newTriangleMeshOBJ(Transformation.translation(0.0, 0.0, 0.0),  "polygon.obj", img_mat)
var tr: seq[Triangle] = CreateTriangleMesh(mesh)
var sphere: Sphere = newSphere("SPHERE_0", Transformation.rotationY(90.0), gradient_mat)

var
    w: World = newWorld()
    img: HdrImage = newHdrImage(width, height)
    tracer: ImageTracer = newImageTracer(img, cam)
    render: FlatRenderer = newFlatRenderer(w, Color.yellow())
    #render: PathTracer = newPathTracer(w, Color.black() )
#w.Add(newSphere("SPHERE_0", Transformation.scale(200.0, 200.0, 200.0) * Transformation.translation(0.0, 0.0, 0.4), sky_material))
#w.Add(newPlane("PLANE_0", Transformation.translation(0.0, 0.0, -1.0), ground_material))
#w.Add(newSphere("SPHERE_0", Transformation.translation(0.0, 0.0, 0.0), newMaterial(newDiffuseBRDF(newUniformPigment(Color.black())), newGradientPigment(Color.black(), Color.white, 1.0, 1.0, 0.0))))

var r: Ray = cam.fireRay(0.5,1.0)
for i,t in enumerate(tr):
    w.Add(t)
    let res = t.rayIntersect(r)
    if res.isSome:
        echo res.get()
    
#for t in treetriangles:
#    w.Add(t)

#w.Add(sphere)




tracer.fireAllRays(render.Get())
var strmWrite = newFileStream("output.pfm", fmWrite)
tracer.image.write_pfm(strmWrite)
tracer.image.normalize_image(1.0)
tracer.image.clamp_image()
tracer.image.write_png("output.png", 1.0)



#[
var animator: Animation = newAnimation(
        Transformation.translation(-2.0, 0.0, 0.0),
        Transformation.translation(-2.0, 0.0, 0.0) * Transformation.rotationZ(170.0),
        CameraType.Perspective,
        render,
        width, height,
        w,
        3,
        4
    )
animator.Play()
animator.Save(false)
]#
