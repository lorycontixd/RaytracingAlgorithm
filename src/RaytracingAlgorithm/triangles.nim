import geometry, transformation

## 
## Triangle Mesh: A class representing a mesh of many triangles.
## Instead of a list of `Triangle` classes, the representation with a bunch of lists has been chosen for more efficiency on memory.
type
    TriangleMesh* = object
        nTriangles*: int
        nVertices*: int

        indices*: seq[int]
        positions*: seq[Point] # position of each vertex
        tangents*: seq[Vector3] # (optional) tangent to each vertex -> shading tangents
        normals*: seq[Normal] # (optional) normal to each vertex -> shading normals
        uvs*: seq[Vector2]


## Constructors
#[
func newTriangleMesh*(
    transform: Transformation,
    nTriangles: int,
    vertexIndices: seq[int]
    ): TriangleMesh {.inline.}=
]#

