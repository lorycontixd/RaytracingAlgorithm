# Changelog
All notable changes to this project will be documented in this file.


## [Unreleased]

## [1.0.0] - 21-06-2022
Unfortunately, the package versions were not updated for a long time, so this one will have a lot of changes.
### Added
- GitHub actions for automatic tests on 6 virtual machines.
- .gitignore to exclude outputs and quick/unwanted tests.
- Example scene files (to be added to demo command).
- Parallel image creation system using GNU parallel.
- Few textures (grass, sky, etc).
- Few Wavefront .obj files for triangle meshes.
- source.txt with some links to useful documents regarding some algorithms and concepts.
- Main file (src/RaytracingAlgorithm.nim)
    - Demo command which computes a pre-defined scene.
    - Render command which generates a runtime image based on a scene file. (including animations)
    - PFM to PNG command which converts a .pfm image to a .png image
- Added RaytracingAlgorithm modules
    - AABB.nim: Shape bounding boxes.
    - animation.nim: Animation controller for an animation.
    - animator.nim: Animator component of a shape which controls its animation.
    - camera.nim: Implements a camera / screen which shoots light rays. (backward raytracing)
    - imagetracer.nim: Class responsible for the conversion of ray outputs into an image.
    - lights.nim: Different light sources for the PointLight renderer technique. (for now only pointlight)
    - material.nim: Contains Pigment and BRDF implementation for the application of materials onto shapes.
    - mathutils.nim: Set of utility functions relative to mathematics (most important: CreateOnbFromZ, Lerp)
    - matrix.nim: Implementation of a 4x4 matrix with all its functions
    - parser.nim: Implementation of lexer and parser structure for reading a scene file.
    - quaternion.nim: Contains a complete quaternion implementation with all its functions.
    - ray.nim: Class for a ray
    - rayhit.nim: Holds all necessary information for a ray hitting a surface in the scene.
    - renderer.nim: Various techniques for shooting and bouncing rays across the scene.
    - scene.nim: Class holding all informations relative to a scene, such as: scene shapes, scene materials, scene settings, scene variables and more.
    - settings.nim: Scene settings (AA, stats, logs, etc...)
    - shape.nim: Shapes class (sphere, plane, triangle, etc..)

### Updated
- Updated RaytracingAlgorithm modules
    - color.nim: get_pixel no longer requires ```var``` in HdrImage
    - logger.nim: renamed quit procedure for logging system


## [0.1.1] - 31-03-2022
### Added
- LICENSE switched to GNUv3.
- Added shields to README for better first-impression informations.
- Opened geometry branch for geometry implementations.

## [0.1.0] - 30-03-2022
### Added
- This CHANGELOG file to hopefully serve as an evolving example of a
  standardized open source project CHANGELOG.
- Tone mapping and gamma correction for conversion of PFM images to PNG images.
- LICENSE set to MIT
- Added numerous tests

