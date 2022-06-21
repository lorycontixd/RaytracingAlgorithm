import cligen
import RaytracingAlgorithm/[hdrimage, color ]
import std/[streams, strformat, marshal]

proc merge(inputfilename: string, outputfile: string){.inline.} =
    var
        nImages: int = 4
        imgs: seq[HdrImage]
        strm: FileStream

    for i in 0..<nImages:
        imgs.add(newHdrImage())
        strm = newFileStream(fmt"{inputfilename}{i:04}.pfm",fmRead)
        if strm.isNil:
            raise ValueError.newException(fmt"File does not exist: {inputfilename}{i}.pfm")
        imgs[i].read_pfm(strm)

    if strm.isNil:
        raise ValueError.newException(fmt"File does not exist: {inputfilename}")
    if imgs.len() != nImages:
        raise ValueError.newException(fmt"Inconsistent number of images read.")

    echo "num images: ",len(imgs)
    echo "0- w: ",imgs[0].width, "\th: ",imgs[0].height
    var outimg = newHdrImage(imgs[0].width, imgs[0].height)
    echo "1- w: ",outimg.width, "\th: ",outimg.height

    for y in countup(0,outimg.height-1):
        for x in countup(0,outimg.width-1):
            var c: Color = newColor()
            #echo "0: ",c
            for img in imgs:
                c.r += img.get_pixel(x,y).r/4
                c.g += img.get_pixel(x,y).g/4
                c.b += img.get_pixel(x,y).b/4
            outimg.set_pixel(x, y, c)
            #echo "1: ",c,"\n"
    
    outimg.write_pfm(newFileStream(fmt"{outputfile}.pfm", fmWrite))
    outimg.normalize_image(0.9)
    outimg.clamp_image()
    outimg.write_png(fmt"{outputfile}.png", 1.1)

proc main(): auto=
    dispatchMulti(
        [merge, help={
            "inputfilename" : "Input temporary image filename for merging",
            "outputfile" : "Output average image file name"
        }]
    )

main()


