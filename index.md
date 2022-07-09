[Home](https://lorycontixd.github.io/RaytracingAlgorithm)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[Results](https://lorycontixd.github.io/RaytracingAlgorithm/media)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[API Reference](https://lorycontixd.github.io/RaytracingAlgorithm/apireference)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;


# RaytracingAlgorithm

RaytracingAlgorithm is a Nim package which takes care of rendering photorealistic images starting from a 3D scene described from an input text file.
It is able to produce an image both in High-Dynamic Range (PFM, etc..) and Low-Dynamic Range(PNG, JPEG; etc..).

![GitHub commit activity (weekly)](https://img.shields.io/github/commit-activity/w/lorycontixd/RaytracingAlgorithm)
![GitHub release](https://img.shields.io/github/v/release/lorycontixd/RaytracingAlgorithm)

## Requirements
RaytracingAlgorithm requires the following packages to be installed in order to properly function:
- [Nim](https://nim-lang.org/) (nim >= 1.6.4)
- [Testament](https://nim-lang.org/docs/testament.html): Support for unittesting. Should be already installed with Nim.
- [SimplePNG](https://github.com/jrenner/nim-simplepng): Package that handles the backend for PNG image creation. Installable through the Nimble package manager with ```nimble install simplepng```.
- [Cligen](https://github.com/c-blake/cligen): Support for command-line argument parsing and help message formatting. Installable through the Nimble package manager with ```nimble install cligen```.
- [Stacks](https://github.com/rustomax/nim-stacks): Pure Nim stack implementation using sequences. Installable through the Nimble package manager with ```nimble install stacks```.

## Features
- Generate photo-realistic images of your choice
- Possible parallel CPU execution (CUDA in future)
- Easy-to-use language to define a scene
- Optimized for speed and memory
- Render pre-defined demo images in an instance

## Installation

The package can be installed in multiple ways
### Cloning the repository
1. Enter the terminal and navigate to the directory you want the package to be installed in.
2. Clone the repository with the command
```
git clone git@github.com:lorycontixd/RaytracingAlgorithm.git
```
3. Then you can enter the directory with the command
```
cd RaytracingAlgorithm
```

### Downloading the latest release
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/lorycontixd/RaytracingAlgorithm?color=green&label=Repo%20size&style=plastic)


1. From terminal, download the latest version of the package from the GitHub repository of the package:
```
wget https://github.com/lorycontixd/RaytracingAlgorithm/archive/refs/tags/vx.y.z.zip
```

or

```
wget https://github.com/lorycontixd/RaytracingAlgorithm/archive/refs/tags/vx.y.z.tar.gz
```

where x,y,z are the numbers of the version you want to download.

2. Extract the file in the directory where the package should be located
```
unzip vx.y.z.zip
```

or 

```
tar -xvf vx.y.z.tar.gz
```
3. Enter the directory and run the main file:

```
cd RaytracingAlgorithm-x.y.z
```


##### Example
To download version 2.1.0 of RaytracingAlgorithm:
```
wget https://github.com/lorycontixd/RaytracingAlgorithm/archive/refs/tags/v2.1.1.tar.gz
tar v2.1.0.tar.gz
cd RaytracingAlgorithm-2.1.0/
```

###
We are planning to publish the RaytracingAlgorithm package to nimble in order to make it easier to download, but this feature will be released in a future version.


## Usage
After downloading the package you can start using it!

> ⚠️ Make sure you are in the parent directory!!

### Ask for help
If you are unsure of how to use RaytracingAlgorithm, you can first read the documentation or print the help screen, by typing:
```
nim cpp -d:release src/RaytracingAlgorithm.nim && ./src/RaytracingAlgorithm.out --help
```

You can also view a help message for each command that the package offers you, by placing the flag --help after the command:

```
nim cpp -d:release src/RaytracingAlgorithm.nim && ./src/RaytracingAlgorithm.out <command> --help
```

### Render image
RaytracingAlgorithm lets you render a photo-realistic image representing a text-defined 3D scene using raytracing. This is done thanks to the ```render``` command.

> ⚠️ Parameters enclosed in square brackets [] are optional and have an encoded default value.

From terminal, type:
```
nim cpp -d:release src/RaytracingAlgorithm.nim && ./src/RaytracingAlgorithm.out render --filename=FILE_NAME [--width=WIDTH] [--height=HEIGHT] [--output_filename=OUTPUT_FILENAME] [--png_output=BOOL]
```
where:
- ```FILE_NAME``` is the name of the input file with the description of the scene to be parsed;
- ```WIDTH``` and ```HEIGHT``` are respectively the screen width and height in pixels, set by default to 800 and 600 (also definable in the scene file);
- ```OUTPUT_FILENAME``` is the name of the name of the output file with the rendered image; it is set by default to 'output';
- ```BOOL``` is **True** if you want the image also in a PNG format, **False** else, set to False by default.

In this way, you're generating by default an image in PFM format. 

### From PFM to PNG
RaytracingAlgorithm also lets you convert a HDR image (.pfm format) into a LDR image (.png format), with the help of filters such as tone mapping.

From terminal, type:
```
nim cpp -d:relaese RaytracingAlgorithm.nim && ./RaytracingAlgorithm.out pfm2png --input_filename=INPUT_FILENAME --output_filename=OUTPUT_FILENAME [--factor=FACTOR] [--gamma=GAMMA] 
```

where:
- ```FACTOR``` is the multiplicative factor used to normalize the image, set by default to 0.7;
- ```GAMMA``` is the exponent for the gamma-correction for the response of the monitor, set by default to 1.0;
- ```INPUT_FILENAME``` is the PFM input file name;
- ```OUTPUT_FILENAME``` is the PNG output file name.


## Scene files
We implemented a new straightforward language in order to create images from an input file. You can follow step-by-step tutorials to generate your first image.

- [API Reference](https://github.com/lorycontixd/RaytracingAlgorithm/blob/master/rta.md)

- [First Tutorial](https://github.com/lorycontixd/RaytracingAlgorithm/blob/master/tutorials/firsttutorial.md): Create two spheres inside a scene with different materials.
- [Second Tutorial](): Create your first animation.

## Future works
RaytracingAlgorithm still has a long way to go before it reaches the amount of functionalities that it deserves. There are known bugs which are waiting to be fixed and ideas waiting to be implemented.

### Known bugs
- Triangles + Meshes not working at all.
- Stats module commented (waiting for parallelization).
- 

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
![GitHub License](https://img.shields.io/github/license/lorycontixd/RaytracingAlgorithm)

[GPL-3.0](https://choosealicense.com/licenses/gpl-3.0/)
