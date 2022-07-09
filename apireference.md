[Home](https://lorycontixd.github.io/RaytracingAlgorithm)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[Results](https://lorycontixd.github.io/RaytracingAlgorithm/media)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[API Reference](https://lorycontixd.github.io/RaytracingAlgorithm/apireference)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

# API Reference

## AABB
The AABB class represent the axis-aligned bounding-box, which is often used to quickly detect whether a ray would intersect the parent shape.
If the ray intersects the bounding box, then a more detailed computation of the intersection is executed, otherwise the ray doesn't hit the shape.

```nim
type
    AABB* = ref object of RootObj
        pMin*, pMax*: Point
``` 
### Methods

> AABB newAABB(p1, p2: Point)
Creates a new empty AABB defined by the two points, which are considered the minimum and the maximum points respectively.

** Parameters **
- p1 (Point) - The minimum point for the bounding box
- p2 (Point) - The maximum point for the bounding box
