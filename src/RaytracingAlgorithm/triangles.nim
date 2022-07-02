import geometry, transformation, utils, material, aabb, exception
import std/[options, streams, os, parseutils, strutils, sequtils, enumerate, strformat]

## 
## Triangle Mesh: A class representing a mesh of many triangles.
## Instead of a list of `Triangle` classes, the representation with a bunch of lists has been chosen for more efficiency on memory.
type
    TriangleMesh* = object
        nTriangles*: int
        nVertices*: int

        vertexIndices*: seq[int]
        vertexPositions*: seq[Point] # position of each vertex
        normalIndices*: Option[seq[int]]
        normals*: Option[seq[Normal]] # (optional) normal to each vertex -> shading normals
        textureIndices*: Option[seq[int]]
        uvs*: Option[seq[Vector2]]

        transform*: Transformation
        material*: Material
        aabb*: AABB


## Constructors


proc newTriangleMesh*(
        transform: Transformation,
        nTriangles: int,
        nVertices: int,
        vertexIndices: seq[int],
        points: seq[Point],
        normalIndices: Option[seq[int]] = none(seq[int]),
        normals: Option[seq[Normal]] = none(seq[Normal]),
        textureIndices: Option[seq[int]] = none(seq[int]),
        uvs: Option[seq[Vector2]] = none(seq[Vector2]),
        material: Material = newMaterial()
    ): TriangleMesh {.inline, injectProcName.}=
    var newpoints: seq[Point]
    var newnormals: seq[Normal]
    var resNormals: Option[seq[Normal]]

    for i in 0..nVertices-1:
        newpoints.add(transform * points[i])
    if normals.isSome:
        for i in 0..nVertices-1:
            newnormals.add(transform * normals.get()[i])
        resNormals = some(newnormals)
    else:
        resNormals = none(seq[Normal])
    return TriangleMesh(transform: transform, nTriangles: nTriangles, nVertices: nVertices, vertexIndices: vertexIndices, vertexPositions: newpoints, normals: resNormals, uvs: uvs)



proc newTriangleMeshRAY*(
        transform: Transformation,
        rayFile: string
    ): TriangleMesh {.inline, injectProcName.}=
    ##### .ray File Parsing
    let strm = newFileStream(rayFile, fmRead)
    # extract first line (number of vertices)
    var line: string = strm.readLine()
    var temp: string = ""
    for i in line:
        if Digits.contains(i):
            temp = temp & i
    var nvertices: int = parseInt(temp)
    var vertices: seq[Point]
    var normals: seq[Normal]
    var indices: seq[int]
    var nTriangles: int = 0
    # extract vertex locations
    while not strm.atEnd():
        line = strm.readLine()
        if not line.startsWith("#vertex"):
            break
        line = line.replace("#vertex ","")
        let splitline = line.split(" ")
        vertices.add(newPoint(parseFloat(splitline[0]), parseFloat(splitline[1]), parseFloat(splitline[2])))
        normals.add(newNormal(parseFloat(splitline[3]), parseFloat(splitline[4]), parseFloat(splitline[5])))
    # extract faces
    while not strm.atEnd():
        line = strm.readLine()
        if not line.startsWith("#shape_triangle"):
            break
        line = line.replace("#shape_triangle ","")
        let splitline = line.split(" ")
        indices.add(parseInt(splitline[1]))
        indices.add(parseInt(splitline[2]))
        indices.add(parseInt(splitline[3]))
        inc nTriangles
    return newTriangleMesh(
        transform,
        nTriangles,
        nvertices,
        indices,
        vertices
    )

proc newTriangleMeshOBJ*(transform: Transformation, objFile: string, material: Material = newMaterial()): TriangleMesh {.inline.}=
    let KEYWORDS = @["v","vt","vn","f","g"]
    var vertexPoints: seq[Point]
    var vertexNormals: seq[Normal]
    var textureCoordinates: seq[Vector2]
    var vertexIndices, vertexNormalIndices, vertexTextureIndices: seq[int]
    var nTriangles: int = 0

    var line: string
    let strm = newFileStream(objFile, fmRead)
    if strm.isNil:
        raise newException(FileNotFoundError, fmt"File not found {objFile}")
    while not strm.atEnd():
        line = strm.readLine()
        let spaceIndex = skipUntil(line,' ',0)
        var key: string = ""
        for i in 0..spaceIndex-1:
            key = key & line[i]
        if not KEYWORDS.contains(key):
            continue
        
        line.delete(0, spaceIndex)
        var items: seq[string] = line.split(" ")
        if items.contains(""):
            items.delete(items.find(""))
        case key
            # vertex position (x,y,z)
            of "v":
                vertexPoints.add(transform * newPoint(parseFloat(items[0]), parseFloat(items[1]), parseFloat(items[2])))
            # vertex normal (x,y,z)
            of "vn":
                vertexNormals.add(transform * newNormal(parseFloat(items[0]), parseFloat(items[1]), parseFloat(items[2])))
            # texture vertex (u,v)
            of "vt":
                textureCoordinates.add(newVector2(parseFloat(items[1]), parseFloat(items[0])))
            # face/vertices describing a face (v1/t1/vn1, ...)
            of "f":
                
                var
                    tempv, tempvn, tempvt: seq[int]
                for i, item in enumerate(items):
                    var splititem: seq[string] = item.split("/")
                    tempv.add( parseInt(splititem[0])-1)
                    if splititem.len() > 1 and splititem[1] != "":
                        tempvt.add( parseInt(splititem[1])-1)
                    if splititem.len() > 2 and splititem[2] != "":
                        tempvn.add( parseInt(splititem[2])-1)
                let polyV = TriangulatePolygon(tempv) # holds all vertices in the face line
                let polyVN = TriangulatePolygon(tempvn) # holds all normals in the face line
                let polyVT = TriangulatePolygon(tempvt) # holds all texture indices in the face line
                nTriangles += int(len(polyV)/3)
                vertexIndices.add(polyV)
                vertexNormalIndices.add(polyVN)
                vertexTextureIndices.add(polyVT)
                #vertexTextureIndices = @[0, 1, 2, 1, 3, 2]
    # set AABB
    var
        minX, maxX: float32 = vertexPoints[0].x
        minY, maxY: float32 = vertexPoints[0].y
        minZ, maxZ: float32 = vertexPoints[0].z
    for vertex in vertexPoints:
        if vertex.x < minX:
            minX = vertex.x
        if vertex.x > maxX:
            maxX = vertex.x
        if vertex.y < minY:
            minY = vertex.y
        if vertex.y > maxY:
            maxY = vertex.y
        if vertex.z < minZ:
            minZ = vertex.z
        if vertex.z > maxZ:
            maxZ = vertex.z
    var aabb: AABB = newAABB(
        newPoint(minX, minY, minZ),
        newPoint(maxX, maxY, maxZ)
    )
    let resVNI = (if len(vertexNormalIndices)==0 or len(vertexNormals)==0: none(seq[int]) else: some(vertexNormalIndices))
    let resVTI = (if len(vertexTextureIndices)==0 or len(textureCoordinates)==0: none(seq[int]) else: some(vertexTextureIndices))
    let resVN = (if len(vertexNormalIndices)==0 or len(vertexNormals)==0: none(seq[Normal]) else: some(vertexNormals))
    let resVT = (if len(vertexTextureIndices)==0 or len(textureCoordinates)==0: none(seq[Vector2]) else: some(textureCoordinates))
    #return newTriangleMesh(transform, nTriangles,len(vertexPoints), vertexIndices, vertexPoints, some(vertexNormalIndices), some(vertexNormals), some(vertexTextureIndices), some(textureCoordinates))
    return TriangleMesh(transform: transform, nTriangles: nTriangles, nVertices: len(vertexPoints), vertexIndices: vertexIndices, vertexPositions: vertexPoints, normalIndices: resVNI, normals: resVN, textureIndices: resVTI, uvs: resVT, material:material, aabb: aabb)            