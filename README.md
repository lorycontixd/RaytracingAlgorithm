# RaytracingAlgorithm

RaytracingAlgorithm is a Nim package which takes care of rendering photorealistic images starting from a 3D scene described from an input text file.
It is able to produce an image both in High-Dynamic Range (PFM, etc..) and Low-Dynamic Range(PNG, JPEG; etc..).

![GitHub commit activity (weekly)](https://img.shields.io/github/commit-activity/w/lorycontixd/RaytracingAlgorithm)
![GitHub release](https://img.shields.io/github/v/release/lorycontixd/RaytracingAlgorithm)

## Requirements
RaytracingAlgorithm requires the following packages to be installed in order to properly function:
- [Nim](https://nim-lang.org/) (nim >= 1.6.4)
- [SimplePNG](https://github.com/jrenner/nim-simplepng): Package that handles the backend for PNG image creation. Installable through the Nimble package manager with ```nimble install simplepng```
- [Therapist](https://maxgrenderjones.bitbucket.io/therapist/latest/therapist.html): Package for parsing command line arguments. Installable through Nimble with ```nimble install therapist```

## Installation

The package can be installed in multiple ways
### Cloning the repository
1. Enter the terminal and navigate to the directory you want the package to be installed in.
2. Clone the repository with the command
```
git@github.com:lorycontixd/RaytracingAlgorithm.git
```

### Downloading the latest release
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/lorycontixd/RaytracingAlgorithm?color=green&label=Repo%20size&style=plastic)


1. From terminal, download the latest version of the package from the GitHub repository of the package:
```
wget command goes here
```
2. Extract the file in the directory where the package should be located
```
tar command goes here
```
3. Run the package

###
We are planning to publish the RaytracingAlgorithm package to nimble in order to make it easier to download, but this feature will be released in a future version.


## Usage
### Renderer
From terminal, type:
```
nim cpp -d:relaese RaytracingAlgorithm.nim && ./RaytracingAlgorithm.out render --filename=FILE_NAME --width=WIDTH --height=HEIGHT --output_filename=OUTPUT_FILENAME --png_output=BOOL
```
where:
- ```FILE_NAME``` is the name of the input file with the description of the scene to be parsed;
- ```WIDTH``` and ```HEIGHT``` are respectively the screen width and height in pixels, set by default to 800 and 600;
- ```OUTPUT_FILENAME``` is the name of the name of the output file with the rendered image; it is set by default to 'output';
- ```BOOL``` is **True** if you want the image also in a PNG format, **False** else, set to False by default.

In this way, you're generating by default an image in PFM format. 

### From PFM to LDR
You would like to convert PFM images to LDR format, and you can do it as follows.
From terminal, type:
```
nim cpp -d:relaese RaytracingAlgorithm.nim && ./RaytracingAlgorithm.out pfm2png --factor=FACTOR --gamma=GAMMA --input_filename=INPUT_FILENAME --output_filename=OUTPUT_FILENAME
```

where:
- ```FACTOR``` is the multiplicative factor used to normalize the image, set by default to 0.7;
- ```GAMMA``` is the exponent for the gamma-correction for the response of the monitor, set by default to 1.0;
- ```INPUT_FILENAME``` is the PFM input file name;
- ```OUTPUT_FILENAME``` is the PNG output file name.


## Scene files
We implemented a new straightforward language in order to create images from an input file. You can follow step by step this tutorial to generate a simple image. For more details about the language, consult the language documentation here ### add link.

### How to create a simple image (tutorial)

## History
See the file changelog (### mettere link)


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
![GitHub License](https://img.shields.io/github/license/lorycontixd/RaytracingAlgorithm)

[GPL-3.0](https://choosealicense.com/licenses/gpl-3.0/)
