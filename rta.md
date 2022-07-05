
  

# Raytracing Algorithm DSL
  

The RaytracingAlgorithm package includes a language to define a 3D scene from a text file. In the following document we present a little documentation and some examples for the usage.

>⚠️The input text file must be of format .txt or .rta

## Data types

Variables are declared by first specifying the type, then the variable name and finally the value in round brackets. This means that in general the syntax is:

**Syntax:** type name(value)</center>

The currently supported data types are:
- integers (int)
- floating point numbers (float)
- boolean (bool)
- string (string)
- 
> ⚠️Since boolean values are used exclusively for settings, the values are **on** or **off**.

#### Examples
- int screenwidth(800)
- float time(600)
- bool AA (on)
- string matname("newmaterial")

## Vectors

Vectors are declared using square brackets, and each component separated by a comma.

#### Examples
-  **[0.43, 1.23, -9.21]**
-  **[-10, 1, 0.3]**

## Colours
Colours are declared using angular brackets, and each component separated by a comma.

#### Examples
-  **<1, 0,  0>**: Red
-  **<0, 1,  0>**: Green
-  **<0.75, 0.75,  0.75>**: Light grey

## Pigments
A pigment does not allow identifiers and has to be inserted directly as an argument, so it can be defined with the following syntax:

### Uniform
Represent a uniform pigment, made of only one colour, and hides a reflectance factor which is always 1.

**Syntax:** uniform(color)

##### Examples
- uniform(<0,0,0>) --> Black
- uniform(<0.9, 0.9, 0.9>) --> Light grey

### Checkered
Represent a checkered pigment, made of two alternating colours and the size of each tile.

**Syntax:** checkered(color1, color2, size)

##### Examples
- checkered(<0,0,0>, <1,1,1>, 1)
- checkered(<1,0,0>, <0,0,1>, 4.5)

### Image
Represent an image pigment, which maps an image onto a material which is then mapped onto an object.
The image pigment only expects the file path of the image to be loaded into the pigment.

**Syntax:** image(filepath)

> ⚠️ The input image must be of .pfm format

##### Examples
- image("../../images/myimage.pfm")
- image("C:/Users/MyUser/Documents/myimage.pfm")

### Gradient
A gradient pigment is defined by two colors and two numbers that encode the coefficients for each axis, so the contribution of the horizontal and vertical component of the gradient.
This means that a horizontal coefficient of 1 and a vertical coefficient of 0 gives a complete horizontal gradient.

**Syntax:** gradient(color1, color2, hCoefficient, vCoefficient)

>⚠️The sum of horizontal and vertical coefficients must equal 1.

##### Examples
- gradient(<0,0,0>, <1,1,1>, 0, 1)
- gradient(<0.1, 0.1, 0.1>, <0.9, 0.9, 0.9>, 0.4, 0.6)
  
## BRDFs

A bidirectional reflectance distribution function (BRDF) is an function that explains how a light ray (coming from an angle and leaving to another angle) reflects over an opaque surface.
It requires a pigment of the surface and additional parameters that depend on the used BRDF.

### Diffuse BRDF

A diffuse BRDF is such that incoming radiance is distributed equally on a hemisphere, such that the BRDF is constant independently of the angle of incidence/emission.

**Syntax:** diffuse(pigment)

##### Examples
- diffuse(uniform(<0,0,0>))
- diffuse(checkered(<0,0,0>, <1,1,1>, 4), 0.5)

### Specular BRDF

A specular BRDF is such that incoming radiance is totally reflected according to Snell's law, therefore the BRDF is a Dirac's delta function.
It requires only a pigment, but encodes a threshold angle which dictates over which angle should the reflection be calculated.

**Syntax:** specular(pigment)

##### Examples
- specular(uniform(<0,0,0>))
- specular(image("mypath.pfm"))

### Phong BRDF

The Phong Model combines the previously defined functions into one, taking into account a diffuse component and a glossy component responsible for reflections on the surface.

The intensity of specular reflections is dictated by a factor called specular exponent or shininess, which is the power law coefficient of the dot product of incoming and outgoing directions.

Clearly there has to be two coefficients which dictate the strength of the diffuse and the glossy component.

**Syntax:** phong(pigment, shininess, diffuseCoefficient, specularCoefficient)

> ⚠️ The sum of the diffuse and specular coefficients must not be greater than 1.

##### Examples
- phong(uniform(<1,0,0>), 20, 0.9, 0.1)
- phong(gradient(<1,0,0,>, <0,0,1>, 0.5, 0.5), 1000, 0.1, 0.9)
- 
### Cook Torrance BRDF

  

  

## Materials

A material describes how the surface of an object is made. It's a combination of a BRDF and an intrinsic, emissive component described by a pigment. Materials can be defined with the keyword `material` and must have an identifier associated so that they can be later assigned to objects.

**Syntax:** material matname(brdf, pigment)

##### Examples

  ```
- material ground_material(
	diffuse(checkered(<0.3, 0.5, 0.1>, <0.1, 0.2, 0.5>, 4), 1.0 ),
	uniform(<0, 0, 0>)
 
)

- material sky_material(
	diffuse(uniform(<0, 0, 0>)),
	uniform(<0.5, 0.8, 1>)
)
```

## Shapes

RaytracingAlgorithm supports an infinite amount of shapes using triangle meshes, but can only support spheres, infinite planes and triangles without the use of meshes.

A shape is uniquely identified by an ID which allows the user to define animations and assign them to the shape by means of the identifier. Also, the shape obviously contains the transformations in world space, as well as a material which is assigned through the material identifier.

### Spheres

A sphere is defined with the ```sphere``` keyword, and an identifier has to be passed immediately. The constructor then takes in the material and the transformation for that sphere. The overall syntax is then:

**Syntax:** sphere identifier(material_name, transform)

##### Examples
- sphere skydome (skymaterial, scale([0,0,0]) )
- sphere ball( ball_material, translation([1,2,3])
- sphere mysphere( mymaterial, identity)

### Planes
A plane is defined by the ```plane``` keyword, and accepts an identifier just like the sphere. The syntax is the same.

**Syntax:** sphere identifier(material_name, transform)

##### Examples
- plane ground( groundmaterial, identity )
- plane myplane( mymaterial, translation([0,0,2]) )

### Triangle

A triangle is a very important shape because it allows the definition of meshes, which also allows anything to be renerer. Since almost every object can be approximated using triangles, we may need a lot of triangles to create more complex shapes, therefore the defintion of this shape must be as efficient as possible
> ⚠️ The construction of triangles from text file is still under construction so it will not work.

**Syntax**: triangle( v1, v2, v3, material) ,where v1,v2,v3 are the vertex positions (vectors)

  

### Meshes

A triangle mesh can be defined in multiple way. If you have an Wavefront .obj file, you can simply pass the filename with the object transformation. If you want to define a triangle mesh manually, you can do so by calling the ```mesh``` keyword and define the triangles one by one.
  

**Syntax (.obj):** mesh( filename, transform, material )

**Syntax (manual):** mesh( material, transform, [ list of triangles ] )

where a triangle is defined differently by an individual triangle described above, as it does not have a material component, which is instead given by the mesh.

  

##### Examples

```

- mesh("myfile.obj", translation([0,0,1]), mymaterial)

- mesh(
	mymaterial,
	translation([0,0,1]) * scale([2,2,2]),
	[
		triangle( [0,0,0], [0,0,1], [0,1,1]),
		triangle( [0,0,1], [0,1,0], [0,1,1])

	]
)

```

## Renderer

In order to produce a photorealistic images using RaytracingAlgorithm, a rendering algorithm has to be defined in the scene file. The rendering algorithm shoots light rays from the camera, through a screen which will be the final rendered image and bounced through the scene to define the pixel's final color.

Each rendering technique has its advantages and disadvantages which will be listed in this section.

> ⚠️ A renderer must be defined in the scene file.  

### OnOff Renderer

The onoff renderer is the simplest renderer of all. It dyes the pixel of a color if the ray passing through that pixel will hit something in the scene, otherwise it dyes it of another color. This renderer is typically used for debugging purposes as the image will be composed of only two colours.

**Syntax:** renderer( onoff, background_color, color)

##### Examples
- renderer (onoff, <0,0,0>, <1,1,1>)
- renderer (onoff, <0,0,0>, <1,0,0>)

 

### Flat Renderer

The flat renderer adds more colours by assigning materials to different shapes. Like the on-off renderer, it assigns the colour to the pixel based on the shape that the ray from that pixel has hit, but it still does not include ray bouncing, capturing only the colour on the first hit.

**Syntax:** renderer( flat, background_color)

##### Examples
- renderer( flat, <0,0,0>)
- renderer( flat, <1,0,0>) ``` (red background)```
  

### Pointlight Renderer

Point-light renderer makes use of bright, small objects like a lamp, the sun, etc.. After a ray hits a surface, it checks if any light source is visible from the interaction point. If any is visible, the light source contribution is added to the pixel, making the pixel bright, otherwise it will be kept dark, creating the effect of shadows. Shadows can differ with the type of light used, for example hard shadows are created with point-like light sources, while soft shadows are created with area lights.

**Syntax:** renderer( pointlight, background_color, ambient_color)

##### Examples
- renderer( pointlight, <0,0,0>, 0.3, 0.4, 1.0> )
- renderer(pointlight, <0.46, 0.62, 0.94>, <0.1, 0.1, 0.1>)


### PathTracer

The path tracer is the most complex and accurate rendering algorithm defined in RaytracingAlgorithm. Each time a light ray bounces on a surface, a multiple number of new rays are shot from the interaction point across the scene until a given depth value has been reached. In this way, each pixel is not only made up of the colour of the first surface hit, but instead takes into account all contributions of rays recursively bounced around the scene.

The advantage of this algorithm is that the rendering equation can be solved exactly, giving birth to photo-realistic images. However, this algorithm is very inefficient, as it must shoot a very high number of rays around the scene, and calculate the interaction with objects for each.

The pathtracing renderer also implements an algorithm called 'Russian roulette' which helps remove the bias on the image created by all those rays that reached a depth larger than the maximum depth, and that were given a null radiance contribution.

The renderer takes as arguments:
- The background color (color to be rendered in case no object is hit)
- The number of rays to be shot after each ray-object intersection.
- The maximum value of ray depth for the algorithm to halt. (A ray depth is the number of bounces of that ray).
- The maximum russian roulette value.

**Syntax:** renderer( pathtracer, number_rays, max_depth, russian_roulette_value )

##### Examples
- renderer(pathtracer, <0.46, 0.62, 0.94>, 7, 4, 6)
- renderer(pathtracer, <0,0,0>, 2,3,2)


## Camera

In order to rendere a scene, it is obviously necessary to have an object that represents a camera in the scene. The camera has a world transform, which is mostly needed for its position and its rotation, it has a distance to the screen of pixels and it can be of two different types: orthogonal camera and perspective camera.

The camera type determines how the rays are generated through the screen, and essentially:

- Orthogonal: Preserves parallelism (rays shots through each pixel are parallel)

- Perspective: More distant objects appear smaller on the screen.

>⚠️ A camera must be defined in the scene file.

**Syntax:** camera( camera_type, transformation, aspect_ratio, distance_to_screen)

> The aspect ratio parameter will be removed as it will be determined by the width/height parameters.

##### Examples

- camera( perspective, translation([-4, 0, 2]), 1.0, 1.0 )
- camera( perspective, rotation_z(30)* translation([0,0,1]), 2.0, 2.0 )

## Settings
RaytracingAlgorithm implements various settings to modify the image to the user's will. The settings are defined by the keyword ```set``` and most of them can be declared in different ways: 
- Setting turned off: ``` set setting = off```
- Setting turned on and using default parameters: ``` set setting = on```
- Setting turned on and using custom parameters: ``` set setting = new setting( *args )

Settings are defined in order of definition in the file, and some settings must come after others.

### Width and height
The width and height are the only setting that do not follow the rules described above, and are the only setting that can be defined both in the scene file and from command line. The scene file definition has the priority over the command-line definition, so if both are defined, the scene file values are taken. If neither are defined, the default values for width and height are 800 and 600 respectively.

**Syntax**:
- set width = value
- set height = value

##### Examples
- set width = 1920
- set height = 1080

### Logger
The logger is a useful tool for displaying useful messages during the rendering of a scene. The logger settings asks for a pipeline for logging messages to be redirected to. This can either be the name of a file, or a console pipeline such as stdout or stderr. The default values for an activated logger is to output the messages to a file called 'main.log'. 

**Syntax**: set logger = new logger( pipeline )

##### Examples
- set logger = off
- set logger = on
- set logger = new logger("myfile.log")
- set logger = new logger( stdout )

### Stats
The stats setting provides various statistics at the end of a rendered scene, such as the number of rays shot by the algorithm, the total time taken, the time taken for each function, and so on. 
> ❌ This implementation will not work until a future release. We're planning to restore it when a parallel implementation of the stats module is implemented.

### AntiAliasing
AntiAliasing is a technique used to remove noise from an image, caused by the possible presence of multiple colours within a single pixel of the image. A way of fixing this problem is to shoot multiple rays inside the same pixel and averaging the resulting radiance.
The only parameter for our implementation of the AntiAliasing algorithm is thus the number of rays per pixel, which is set by default to 9.
The algorithm requires a noticeable computational time, so the number of rays must not be too high.

> ⚠️ The number of rays used by the antialiasing must be a perfect square, such as 1, 4, 9, 16, 25, ...

**Syntax:** set antialiasing = new antialiasing( num_rays )

##### Examples
- set antialiasing = off
- set antialiasing = on
- set antialiasing = new antialiasing (4)

### Animation
The animation setting completely changes the output of RaytracingAlgorithm, which will give a video of the animation instead of a rendered image. Just like the other settings, it can be turned on with default values or with custom values.
The animation setting requires as parameters the duration of the animation (in seconds) and the number of frames per second. By default, these values are set to 3 seconds of animation and 20 frames per second, for a total of  60 frames of animation. This object is what creates the overall animation of the scene, however, each object must be animated individually using its intrinsic animator component. In fact, without the definition of an animated object, the result would be just a stationary animation.

**Syntax:** set animation = new animation (duration, fps)

##### Examples
- set animation = off
- set animation = on
- set animation = new animation( 3, 60 )

### PostProcessing
PostProcessing are a set of effects to be applied only once the image has already been rendered, to make it look nicer, more realistic, or sometimes to correct some problems such as to reduce image noise. As of today, the only postprocessing effects that RaytracingAlgorithm offers are:
- *Tone Mapping:* Maps RGB colours to sRGB colours to approximate high-dynamic range images in a more limited dynamic range environment.
- *Gaussian Blur*: Gaussian blur is a method of blurring an image which can be used either to intentionally give it a blur effect, or to reduce the noise of the image.
>⚠️ In the future the gaussian blur will be classified under a general blur effect with the ability of specifying the type of blur as parameter (gaussian, et

The syntax is general for post processing effects, and cannot be separated into individual effects. This means that the post-processing effects setting asks for a list of effects, which cannot be pre-defined and passed as variables.

**Syntax:** set postprocessing = new postprocessing ( *args ), where *args are just different effects.

##### Post-processing effect
- ToneMapping: tonemapping( factor, luminosity=none)
	- factor (float, required): a multiplicative factor which brightens the image with higher values
	- luminosity (float, optional): a normalization factor which is by default the average luminosity of all pixels, but can be set manually.
- GaussianBlur: gaussianblur( radius )
	- radius( int, required): the radius of the gaussian kernel in the pixel matrix. Since gaussian blur effect fetches, for each pixel, the colour of nearby neighbours to determine the blurred colour of the actual pixel, the radius parameter determines how many neighbours will account for the blur. Of course, **the higher the radius, the blurrier the image.**


##### Examples
- set postprocessing = off
- set postprocessing = on
- set postprocessing = new postprocessing( tonemapping(1.0) )
- set postprocessing = new postprocessing ( gaussianblur(3), tonemapping (2.0) )


## Object Animators
As previously mentioned in the animation setting, an animation is nothing without animated objects. The way RaytracingAlgorithm defines animations is through an animator component for each animatable object (usually shapes). This component defines the way the object  should move through *keyframes*, which holds a transformation for each given time, and then interpolates between those keyframes, by decomposing each transformation into a scale (vector), rotation (quaternion) and translation (vector) component.
This work is done through the ```animate``` keyword which asks for an object identifier, which is the object to be animated, and a list of keyframes for that object, where each keyframe is a pair (time, transformation).

**Syntax:** animate ( object, *keyframes)

##### Examples
```
- sphere mysphere(material, identity)
animate (
	mysphere,
	[0, translation([0,1,0])],
	[1, translation([0,2,0]),
	[2, rotationy(90) * translation([0,3,0])
)
```
> ⚠️ An object always asks for a transformation when defined, but when animated, the original transformation is ignored.
