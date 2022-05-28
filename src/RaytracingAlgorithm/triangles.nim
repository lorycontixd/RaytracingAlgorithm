import geometry, transformation, utils, material
import std/[options, streams, os, parseutils, strutils, sequtils, enumerate]

## 
## Triangle Mesh: A class representing a mesh of many triangles.
## Instead of a list of `Triangle` classes, the representation with a bunch of lists has been chosen for more efficiency on memory.
type
    TriangleMesh* = object
        nTriangles*: int
        nVertices*: int

        vertexIndices*: seq[int]
        positions*: seq[Point] # position of each vertex
        tangents*: Option[seq[Vector3]] # (optional) tangent to each vertex -> shading tangents
        normals*: Option[seq[Normal]] # (optional) normal to each vertex -> shading normals
        uvs*: Option[seq[Vector2]]

        transform*: Transformation


## Constructors
proc newTriangleMesh*(
        transform: Transformation,
        nTriangles: int,
        nVertices: int,
        vertexIndices: seq[int],
        points: seq[Point],
        tangents: Option[seq[Vector3]] = none(seq[Vector3]),
        normals: Option[seq[Normal]] = none(seq[Normal]),
        uvs: Option[seq[Vector2]] = none(seq[Vector2])
    ): TriangleMesh {.inline, injectProcName.}=
    var newpoints: seq[Point]
    var newtangents: seq[Vector3]
    var newnormals: seq[Normal]

    var resTangents: Option[seq[Vector3]]
    var resNormals: Option[seq[Normal]]
    for i in 0..nVertices-1:
        newpoints.add(transform * points[i])
    if tangents.isSome:
        for i in 0..nVertices-1:
            newtangents[i] = transform * tangents.get()[i]
        resTangents = some(newtangents)
    else:
        resTangents = none(seq[Vector3])
    if normals.isSome:
        for i in 0..nVertices-1:
            newnormals[i] = transform * normals.get()[i]
        resNormals = some(newnormals)
    else:
        resNormals = none(seq[Normal])
    return TriangleMesh(transform: transform, nTriangles: nTriangles, nVertices: nVertices, vertexIndices: vertexIndices, positions: newpoints, tangents: resTangents, normals: resNormals, uvs: uvs)

proc newTriangleMesh*(
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
        case key
            of "v":
                vertexPoints.add(newPoint(parseFloat(items[0]), parseFloat(items[1]), parseFloat(items[2])))
            of "vn":
                vertexNormals.add(newNormal(parseFloat(items[0]), parseFloat(items[1]), parseFloat(items[2])))
            of "vt":
                textureCoordinates.add(newVector2(parseFloat(items[0]), parseFloat(items[1])))
            of "f":
                if items.contains(""):
                    items.delete(items.find(""))
                var
                    tempv, tempvn, tempvt: seq[int]
                for i, item in enumerate(items):
                    var splititem: seq[string] = item.split("/")
                    tempv.add( parseInt(splititem[0])-1)
                    tempvn.add( parseInt(splititem[1])-1)
                    tempvt.add( parseInt(splititem[2])-1)

                let polyV = TriangulatePolygon(tempv)
                let polyVN = TriangulatePolygon(tempv)
                let polyVT = TriangulatePolygon(tempv)
                nTriangles += int(len(polyV)/3)
                vertexIndices.add(polyV)
    return newTriangleMesh(transform, nTriangles,len(vertexPoints), vertexIndices, vertexPoints)
                


#[
proc newTriangleMeshOBJ*(
        transform: Transformation,
        objFile: string
    ): TriangleMesh {.inline, injectProcName.}=
    var vertices: seq[Point]
    var indices: seq[int]
    var nTriangles: int = 0
    ##### .obj File Parsing
    let strm = newFileStream(objFile, fmRead)
    var line: string
    var temp: string = ""
    # extract vertices
    while not strm.atEnd():
        if not strm.peekLine().startsWith("v "):
            discard strm.readLine()
        else:
            break
    while not strm.atEnd():
        line = strm.readLine()
        if not line.startsWith("v "):
            break
        #echo line
        line = line.replace("v ","")
        let splitline = line.split(" ")
        vertices.add(newPoint(parseFloat(splitline[0]), parseFloat(splitline[1]), parseFloat(splitline[2])))
    # extract faces
    while not strm.atEnd():
        if not strm.peekLine().startsWith("f "):
            discard strm.readLine()
        else:
            break
    while not strm.atEnd():
        line = strm.readLine()
        echo line
        if not line.startsWith("f "):
            continue
        line = line.replace("f ","")
        var splitline: seq[string] = line.split(" ")
        echo splitline
        var temp: seq[int]
        ## remove unnecessary chars before the actual number
        splitline.delete(splitline.find(""))
        echo splitline
        for elem in splitline:
            let newsplit = elem.split("/")
            var faceIndex: string= newsplit[0]
            for c in faceIndex:
                if not Digits.contains(c):
                    faceIndex.removePrefix(c)
            temp.add(parseInt(faceIndex))
        indices.add(temp[0]-1)
        indices.add(temp[1]-1)
        indices.add(temp[2]-1)
        inc nTriangles
        if splitline.len == 4:
            indices.add(temp[0]-1)
            indices.add(temp[1]-1)
            indices.add(temp[3]-1)
            inc nTriangles
    return newTriangleMesh(
        transform,
        nTriangles,
        len(vertices),
        indices,
        vertices
    )
]#