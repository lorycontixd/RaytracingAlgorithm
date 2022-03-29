# RaytracingAlgorithm

RaytracingAlgorithm is a Nim package which takes care of rendering photorealistic images starting from a 3D scene described from an input text file.

It is able to produce an image both in High-Dynamic Range (PFM, etc..) and Low-Dynamic Range(PNG, JPEG; etc..).

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
...


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)