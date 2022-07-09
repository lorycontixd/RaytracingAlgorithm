# First Tutorial
This document will help you build your first photo-realistic rendered image using the RaytracingAlgorithm package.
The outcome will be this image:
	![Final Image](https://github.com/lorycontixd/RaytracingAlgorithm/blob/master/media/documentation/tutorial1/finalimage.png)


> Make sure you find yourself inside the root folder.
> Run the script with the following command: nim cpp -d:release ./src/RaytracingAlgorithm.nim && ./src/RaytracingAlgorithm.out render --filename=<YOUR_FILE>

### Step 1
The first thing to be done is to add a sky background and a plane to place our spheres onto. This is done by firstly defining the necessary materials and then assigning the materials to the right spheres.
> Remember that you can comment your code by starting a line with #.

```
#----  Materials
material sky_material(
        diffuse(uniform(<0.0, 0.0, 0.0>)),
        uniform(<0.45, 0.91, 1>)
)
material ground_material(
		diffuse(checkered(<0.3, 0.5, 0.1>,
				<0.1, 0.2, 0.5>, 4)),
        uniform(<0, 0, 0>)
)

#---- Spheres
sphere sky (sky_material, scale([50,50,50])) 		# Background
plane (ground_material, identity) 					# Ground
```
Also remember that no scene can work without the definition of an observer inside the scene, and a rendering method.
In this example, we will define a perspective camera that is able to see both sphere, and render the image using the path-tracer, which is the most advanced algorithm implemented in RaytracingAlgorithm. To define these two tools you can simply add these lines to your previous code:
```
renderer(pathtracer, <0,0,0>, 6, 6, 3)
camera(perspective, rotation_z(30)* translation([-4, 0, 1]), 1.0, 1.0) 
```

At this stage, you should get an image that looks like this:

![Step1 Image](https://github.com/lorycontixd/RaytracingAlgorithm/blob/master/media/documentation/tutorial1/step1.png)

### Step2
For the next step, we will take care of adding both spheres to the scene and understanding what materials are attached to them.
As seen on the resulting image, the front sphere will have a mirror-like material attached, while the other will have a rougher, hybrid material, where by hybrid we mean that it has a bit of both diffusive and specular behaviours. This material is covered by the Phong brdf, more info [here](https://github.com/lorycontixd/RaytracingAlgorithm/blob/master/rta.md#phong-brdf).
To add the spheres to your scene, just add these lines to your previous code:
```
material sphere_material(
        specular(uniform(<0.5, 0.5, 0.5>)),
        uniform(<0, 0, 0>)
)

material ctmaterial(
        phong(uniform(<0.7, 0, 0.7>), 3000, 0.2, 0.8),
        uniform(<0.1, 0, 0.1>)
)

sphere s(sphere_material, translation([0, 0, 1]))
sphere cts(ctmaterial, translation([-1, -2.7, 1]))
```
The resulting image would be the following:
![Step2 Image](https://github.com/lorycontixd/RaytracingAlgorithm/blob/master/media/documentation/tutorial1/step2.png)

### Step 3
The image would theoretically we complete, as it looks the same as our target image. Or does it?
What we can do last is apply some settings to make the image look nicer **after** the rendering, by applying some effects called post-processing effects.
What we can also do is make the image look neater by increasing the image resolution. In this example, we will produce an image of resolution 1920x1080, which is standard for relatively modern monitors.

These settings can be applied by adding the following lines:
```
set width = 1920
set height = 1080

set postprocessing = new postprocessing(
	tonemapping(1.1),
	gaussianblur(1)
)
```

### Final thoughts
Et voilà, our first image has been produced. 
The general structure that we'd use in this case to make the code look a little bit clear is the following:

1. Definition of width and height
2. Definition of materials
3. Definition of shapes
4. Definition of camera & renderer
5. Definition of settings (postprocessing, animations, etc)

The final code can be found [here](https://github.com/lorycontixd/RaytracingAlgorithm/blob/master/examples/example_demo.rta).