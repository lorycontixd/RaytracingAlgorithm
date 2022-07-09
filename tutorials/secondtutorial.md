# Second tutorial
In this tutorial, you will learn to produce your first animation using RaytracingAlgorithm. We will be rendering a video clip of two planets rotating around each other.
[Here]() you can see the outcome of the animation, named planets.

> Make sure you find yourself inside the root folder.
> Run the script with the following command: nim cpp -d:release ./src/RaytracingAlgorithm.nim && ./src/RaytracingAlgorithm.out render --filename=<YOUR_FILE>

### Step 1
Firstly, we want to define the necessary materials and objects for the background.
In this case, to make our rendering faster we will not use an object to define our background, instead we use the renderer's background colour.
At this point we jump straight to the materials and shapes necessary for the planets:

```
#----  Materials
material jupmat(
    diffuse(uniform(<0,0,0>)),
    image("../media/images/jupiter/jupiter.pfm")
)

material earthmat(
    diffuse(uniform(<0,0,0>)),
    image("../media/images/earth_texture.pfm")
)

#---- Spheres
sphere jupiter(jupmat, translation([4, -3, 2.5]))
sphere earth(earthmat, translation([-2.1, 1.6, 1.1]))

#---- Tools
camera(perspective, translation([-5, 0, 1]), 1.0, 1.0)
renderer(pathtracer, <0.3, 0.3, 0.94>, 2,3,2)
```

Leaving the file in this status will just produce an image, because no animation has been defined.

### Step2
In this step we will be adding the components for the animation. We want earth to rotate more than jupiter, both in 5 seconds time.
First we must define an animation object with the following line:
```
set animation = new animation(5, 60)
```
This creates an animation of 5 seconds at 50 frames per second.

> ⚠️ This results in 300 frames total which may take a while.

Now we must define how each shape moves during these 5 seconds, and we can achieve that by defining a bunch of keyframes for each object, using the ```animate``` keyword:

```
animate (earth,
    [0, rotationz(0) * translation([0,0,1.5])],
    [2.5, rotationz(90) * translation([0,0,1.5])],
    [5, rotationz(180) * translation([0,0,1.5])]
)

animate (jupiter,
    [0, rotationz(0) * translation([1, -4, 2.5])],
    [2.5, rotationz(45) * translation([1, -4, 2.5])],
    [5, rotationz(90) * translation([1, -4, 2.5])]
)
```

This adds 3 keyframes for each object. The number on the left indicates the time of the keyframes, while the number of the right indicates the associated transformation.

> ⚠️ The animation component must be defined before every keyframe definition.

> ⚠️ The timestamp of a keyframe must be lower or equal than the animation duration.

### Step 3
Finally we can add some post-processing effects and other settings to make the animation look nicer:

```
set width = 2560
set height = 1440

set antialiasing = new antialiasing(1)
set postprocessing = new postprocessing(gaussianblur(1), tonemapping(0.6))
```

### Final thoughts
Congratulations! You have created your first animation. 

The final code can be found [here](https://github.com/lorycontixd/RaytracingAlgorithm/blob/master/examples/example_animation.rta).

