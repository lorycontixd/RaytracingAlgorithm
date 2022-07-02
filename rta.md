# Raytracing Algorithm DSL 
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

#####  Examples
- gradient(<0,0,0>, <1,1,1>, 0, 1)
- gradient(<0.1, 0.1, 0.1>,  <0.9, 0.9, 0.9>, 0.4, 0.6)

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