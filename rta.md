# Raytracing Algorithm DSL (rta)
The RaytracingAlgorithm package includes a language to define a 3D scene from a text file. In the following document we present a little documentation and some examples for the usage. 

>⚠️The input text file must be of format .txt or .rta

## Data types
Variables are declared by first specifying the type, then the variable name and finally the value in round brackets. This means that in general the syntax is:

<center>type name(value)</center>

The currently supported data types are:
- integers (int) 
- floating point numbers (float)
- boolean (bool)
- string (string)

> ⚠️Since boolean values are used exclusively for settings, the values are **on** or **off**.

#### Examples
- int screenwidth(800)
- float time(600)
- bool AA (on)
- string matname("newmaterial")

## Vectors
Vectors are declared using square brackets, and each component separated by a comma.

#### Examples
- **[0.43, 1.23, -9.21]**
- **[-10, 1, 0.3]**

## Colours
Colours are declared using angular brackets, and each component separated by a comma.

#### Examples
- **<1, 0, 0>**: Red
- **<0, 1, 0>**: Green
- **<0.75, 0.75, 0.75>**: Light grey

## Pigments
A pigment does not allow identifiers and has to be inserted directly as an argument, so it can be defined with the following syntax:
<center>type(*args)</center>
where the arguments depend on the pigment being used:

### Uniform
Represent a uniform pigment, made of only one colour and a reflectance factor:
<center>uniform(color, reflectance) </center>

##### Examples
- uniform(<0,0,0>, 1.5)
- uniform(<0.9, 0.9, 0.9>, 1)

### Checkered
Represent a checkered pigment, made of two alternating colours and the size of each tile:
<center>checkered(color1, color2, size)</center>

##### Examples
- checkered(<0,0,0>, <1,1,1>, 1)
- checkered(<1,0,0>, <0,0,1>, 4.5)

### Image 
Represent an image pigment, which maps an image onto a material which is then mapped onto an object.
The image pigment only expects the file path of the image to be loaded into the pigment:
<center>image(filepath)</center>

> ⚠️ The input image must be of .pfm format

##### Examples
- image("../../images/myimage.pfm")
- image("C:/Users/MyUser/Documents/myimage.pfm")

### Gradient
A gradient pigment is defined by two colors and two numbers that encode the coefficients for each axis, so the contribution of the horizontal and vertical component of the gradient.
This means that a horizontal coefficient of 1 and a vertical coefficient of 0 gives a complete horizontal gradient. 
<center>gradient(color1, color2, hCoefficient, vCoefficient)</center>

>⚠️The sum of horizontal and vertical coefficients must equal 1.
#####  Examples
- gradient(<0,0,0>, <1,1,1>, 0, 1)
- gradient(<0.1, 0.1, 0.1>,  <0.9, 0.9, 0.9>, 0.4, 0.6)

## BRDFs
A bidirectional reflectance distribution function (BRDF) is an function that explains how a light ray (coming from an angle and leaving to another angle) reflects over an opaque surface.
It requires a pigment of the surface and additional parameters that depend on the used BRDF. 

### Diffuse BRDF
A diffuse BRDF is such that incoming radiance is distributed equally on a hemisphere, such that the BRDF is constant independently of the angle of incidence/emission.
<center> diffuse(pigment, reflectance)</center>

##### Examples
- diffuse(uniform(<0,0,0>), 1.0)
- diffuse(checkered(<0,0,0>, <1,1,1>, 4), 0.5)

### Specular BRDF
A specular BRDF is such that incoming radiance is totally reflected according to Snell's law, therefore the BRDF is a Dirac's delta function.
It requires a pigment and a threshold angle which dictates over which angle should the reflection be calculated.
<center> specular(pigment, threshold_angle)</center>

##### Examples
- specular(uniform(<0,0,0>). 0.001)
- specular(image("mypath.pfm"), 0.001)

### Phong BRDF
The Phong Model combines the previously defined functions into one, taking into account a diffuse component and a glossy component responsible for reflections on the surface.
The intensity of specular reflections is dictated by a factor called specular exponent or shininess, which is the power law coefficient of the dot product of incoming and outgoing directions.
Clearly there has to be two coefficients which dictate the strength of the diffuse and the glossy component.
> ⚠️ The sum of the diffuse and specular coefficients must not be greater than 1.

<center> phong(pigment, shininess, diffuseCoefficient, specularCoefficient) </center>

##### Examples
- phong(uniform(<1,0,0>), 20, 0.9, 0.1)
- phong(gradient(<1,0,0,>, <0,0,1>, 0.5, 0.5), 1000, 0.1, 0.9)

### Cook Torrance BRDF

## Materials
A material describes how the surface of an object is made, and it's a combination of a BRDF and an emissive component described by a pigment. Materials can be defined with the keyword `material` and must have an identifier associated so that they can be later assigned to objects. The syntax is:
<center>material matname(*args)

where the arguments depend on the materials being defined.
