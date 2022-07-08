import "../src/RaytracingAlgorithm/shape.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/ray.nim"
import "../src/RaytracingAlgorithm/rayhit.nim"
import "../src/RaytracingAlgorithm/transformation.nim"
import std/[options]

proc testSphere*(): void=
    ## ------ test sphere 1 ---------
    var
        r1: Ray = newRay(newPoint(0.0, 0.0, 2.0), Vector3.backward())
        unitSphere1: Sphere = newSphere("SPHERE_0", Transformation.translation(newVector3(0.0, 0.0, 0.0)))
        
    let res1 = unitSphere1.rayIntersect(r1)    
    
    if res1.isSome:
        let intersection1 = res1.get()
        assert intersection1.world_point.isClose(newPoint(0.0, 0.0, 1.0))
        assert intersection1.normal.isClose(Vector3.forward().convert(Normal))
        assert intersection1.surface_point.isClose(newVector2(0.0,0.0))

    ## ------ test sphere 2 --------
    var r2: Ray = newRay(newPoint(3.0, 0.0, 0.0), Vector3.left())

    let res2 = unitSphere1.rayIntersect(r2)
    if res2.isSome:
        let intersection2 = res2.get()
        assert intersection2.world_point.isClose(newPoint(1.0, 0.0, 0.0))
        assert intersection2.normal.isClose(Vector3.right().convert(Normal))
        assert intersection2.surface_point.isClose(newVector2(0.0,0.5))
    ## ------ test sphere 3 --------
    var r3: Ray = newRay(newPoint(3.0, 0.0, 0.0), Vector3.right())

    let res3 = unitSphere1.rayIntersect(r3)
    if res3.isSome:
        let intersection3 = res3.get()
        assert intersection3.world_point.isClose(newPoint(1.0, 0.0, 0.0))
        assert intersection3.normal.isClose(Vector3.left().convert(Normal))
        assert intersection3.surface_point.isClose(newVector2(0.0,0.5))



proc test_transformation()=
    var 
        sphere: Sphere = newSphere("SPHERE_0", Transformation.translation(newVector3(10.0, 0.0, 0.0)))
        r1: Ray = newRay(newPoint(10.0, 0.0, 2.0), Vector3.backward())
        hit1: RayHit = newRayHit(
            newPoint(10.0,0.0,1.0),
            newNormal(0.0,0.0,1.0),
            newVector2(0.0,0.0),
            1.0,
            r1,
            sphere.material
        )

        r2: Ray = newRay(newPoint(13.0, 0.0, 0.0), Vector3.left())
        hit2: RayHit = newRayHit(
            newPoint(11.0,0.0,0.0),
            newNormal(1.0,0.0,0.0),
            newVector2(0.0,0.5),
            2.0,
            r2,
            sphere.material
        )

    let res1 = sphere.rayIntersect(r1) 
    let res2 = sphere.rayIntersect(r2) 
   
    if res1.isSome:
        let intersection1 = res1.get()

        assert hit1.isClose(intersection1)

    if res2.isSome:
       let intersection2 = res2.get()

       assert hit2.isClose(intersection2)

    # Check if the sphere failed to move by trying to hit the untransformed shape
    var r3 : Ray =  newRay(newPoint(0.0,0.0,2.0), Vector3.backward())
    let res3 = sphere.rayIntersect(r3)
    assert not res3.isSome
    
    # Check if the *inverse* transformation was wrongly applied
    var r4 : Ray =  newRay(newPoint(-10.0,0.0,0.0), Vector3.backward())
    let res4 = sphere.rayIntersect(r4)
    assert not res4.isSome


proc test_normal()=
    var 
        sphere: Sphere = newSphere("SPHERE_0", Transformation.scale(newVector3(2.0, 1.0, 1.0)))
        r1: Ray = newRay(newPoint(1.0, 1.0, 0.0), newVector3(-1.0,-1.0,-1.0))
    let res = sphere.rayIntersect(r1) 
   
    if res.isSome:
        let intersection1 = res.get()
        assert intersection1.normal.normalize().isClose(newNormal(1.0,4.0,0.0).normalize())

proc test_direction()=
    # Scaling a sphere by -1 keeps the sphere the same but reverses its reference frame
    var 
        sphere: Sphere = newSphere("SPHERE_0", Transformation.scale(newVector3(-1.0, -1.0, -1.0)))
        r1: Ray = newRay(newPoint(0.0, 2.0, 0.0), Vector3.down())
    let res = sphere.rayIntersect(r1) 
   
    if res.isSome:
        let intersection1 = res.get()
        assert intersection1.normal.normalize().isClose(newNormal(0.0,1.0,0.0).normalize())

proc test_uv()=
    var
        r1: Ray = newRay(newPoint(2.0, 0.0, 0.0), Vector3.left())
        r2: Ray = newRay(newPoint(0.0, 2.0, 0.0), Vector3.down())
        r3: Ray = newRay(newPoint(-2.0, 0.0, 0.0), Vector3.right())
        r4: Ray = newRay(newPoint(0.0, -2.0, 0.0), Vector3.up())
        r5: Ray = newRay(newPoint(2.0, 0.0, 0.5), Vector3.left())
        r6: Ray = newRay(newPoint(2.0, 0.0, -0.5), Vector3.left())
        unitSphere1: Sphere = newSphere("SPHERE_0", Transformation.translation(newVector3(0.0, 0.0, 0.0)))
        
    let res1 = unitSphere1.rayIntersect(r1)  
    let res2 = unitSphere1.rayIntersect(r2) 
    let res3 = unitSphere1.rayIntersect(r3) 
    let res4 = unitSphere1.rayIntersect(r4) 
    let res5 = unitSphere1.rayIntersect(r5) 
    let res6 = unitSphere1.rayIntersect(r6) 
    if res1.isSome:
        let intersection1 = res1.get()
        assert intersection1.surface_point.isClose(newVector2(0.0,0.5))  
    if res2.isSome:
        let intersection2 = res2.get()
        assert intersection2.surface_point.isClose(newVector2(0.25,0.5))  
    if res3.isSome:
        let intersection3 = res3.get()
        assert intersection3.surface_point.isClose(newVector2(0.5,0.5))  
    if res4.isSome:
        let intersection4 = res4.get()
        assert intersection4.surface_point.isClose(newVector2(0.75,0.5))  
    if res5.isSome:
        let intersection5 = res5.get()
        assert intersection5.surface_point.isClose(newVector2(0.0,1/3))  
    if res6.isSome:
        let intersection6 = res6.get()
        assert intersection6.surface_point.isClose(newVector2(0.0,2/3))  
    

proc test_plane()=
    var 
        plane: Plane = newPlane("PLANE_0", Transformation.translation(0.0,0.0,0.0))
        r1: Ray = newRay(newPoint(0.0, 0.0, 1.0), Vector3.left())
        hit1: RayHit = newRayHit(
            newPoint(0.0,0.0,0.0),
            newNormal(0.0,0.0,1.0),
            newVector2(0.0,0.0),
            1.0,
            r1,
            plane.material
        )
    
    let res1 = plane.rayIntersect(r1) 
    if res1.isSome:
        let intersection1 = res1.get()
        assert hit1.isClose(intersection1)

    var r2 : Ray =  newRay(newPoint(0.0,0.0,1.0), Vector3.forward())
    let res2 = plane.rayIntersect(r2)
    assert not res2.isSome

    var r3 : Ray =  newRay(newPoint(0.0,0.0,1.0), Vector3.right())
    let res3 = plane.rayIntersect(r3)
    assert not res3.isSome

    var r4 : Ray =  newRay(newPoint(0.0,0.0,1.0), Vector3.up())
    let res4 = plane.rayIntersect(r4)
    assert not res4.isSome



proc test_transformation_plane()=
    var 
        plane: Plane = newPlane("PLANE_0", Transformation.rotationY(90))
        r1: Ray = newRay(newPoint(1.0, 0.0, 0.0), Vector3.left())
        hit1: RayHit = newRayHit(
            newPoint(0.0,0.0,0.0),
            newNormal(1.0,0.0,0.0),
            newVector2(0.0,0.0),
            1.0,
            r1,
            plane.material
        )
    
    let res1 = plane.rayIntersect(r1) 
   
    if res1.isSome:
        let intersection1 = res1.get()
        assert hit1.isClose(intersection1)

    var r2 : Ray =  newRay(newPoint(0.0,0.0,1.0), Vector3.forward())
    let res2 = plane.rayIntersect(r2)
    assert not res2.isSome

    var r3 : Ray =  newRay(newPoint(0.0,0.0,1.0), Vector3.right())
    let res3 = plane.rayIntersect(r3)
    #echo res3.get()

    var r4 : Ray =  newRay(newPoint(0.0,0.0,1.0), Vector3.up())
    let res4 = plane.rayIntersect(r4)
    assert not res4.isSome

proc test_uv_plane()=
    var
        r1: Ray = newRay(newPoint(0.0, 0.0, 010), Vector3.backward())
        r2: Ray = newRay(newPoint(0.25, 0.75, 1.0), Vector3.backward())
        r3: Ray = newRay(newPoint(4.25, 7.75, 1.0), Vector3.backward())
        
        plane: Plane = newPlane("PLANE_0", Transformation.translation(newVector3(0.0, 0.0, 0.0)))
        
    let res1 = plane.rayIntersect(r1)  
    let res2 = plane.rayIntersect(r2) 
    let res3 = plane.rayIntersect(r3) 
    
    if res1.isSome:
        let intersection1 = res1.get()
        assert intersection1.surface_point.isClose(newVector2(0.0,0.0))  
    if res2.isSome:
        let intersection2 = res2.get()
        assert intersection2.surface_point.isClose(newVector2(0.25,0.75))  
    if res3.isSome:
        let intersection3 = res3.get()
        assert intersection3.surface_point.isClose(newVector2(0.25,0.75))  
    




testSphere()
test_transformation()
test_direction()
test_uv()
test_transformation_plane()
test_plane()
test_uv_plane()
