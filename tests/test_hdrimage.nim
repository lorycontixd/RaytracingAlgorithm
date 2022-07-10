discard """
    action: "run"
    exitcode: 0
    output: '''
Testing HdrImage
Coordinates outside bounds
Failed image size parsing
'''
    batchable: true
    joinable: true
    valgrind: false
    cmd: "nim cpp -r -d:release $file"

"""

import std/[streams, sequtils]
import "../src/RaytracingAlgorithm/hdrimage.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/utils.nim"
import "../src/RaytracingAlgorithm/geometry.nim"

echo "Testing HdrImage"

var hdr = newHdrImage(1000,100)

let
    LE_BYTES = @[80.byte, 70, 10, 51, 32, 51, 10, 45, 49, 46, 48, 10, 0, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 0]
    BE_BYTES = @[80.byte, 70, 10, 51, 32, 51, 10, 49, 46, 48, 10, 0, 0, 0, 0, 63, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 63, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 63, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 63, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 63, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 63, 128, 0, 0, 0, 0, 0, 0]

proc test_creation=
    assert hdr.width == 1000
    assert hdr.height == 100
    assert hdr.endianness == hdrimage.Endianness.littleEndian

proc test_coordinate_validation=
    assert hdr.valid_coordinates(1,1)
    assert hdr.valid_coordinates(999, 99)
    try:
        assert hdr.valid_coordinates(1001, 101)
    except AssertionDefect:
        echo "Coordinates outside bounds"

proc test_set_pixel=
    let c = newColor(0,0,1)
    hdr.set_pixel(50,50, c)
    assert hdr.get_pixel(50, 50) == c

proc test_pfm_write=
    var LE_img = newHdrImage(3,3)
    LE_img.set_pixel(0,0, Color.blue())
    LE_img.set_pixel(0,1, Color.blue())
    LE_img.set_pixel(0,2, Color.green())
    LE_img.set_pixel(1,0, Color.black())
    LE_img.set_pixel(1,1, Color.black())
    LE_img.set_pixel(1,2, Color.black())
    LE_img.set_pixel(2,0, Color.green())
    LE_img.set_pixel(2,1, Color.red())
    LE_img.set_pixel(2,2, Color.red())

    var BE_img: HdrImage = newHdrImage(LE_img)
    BE_img.endianness = hdrimage.Endianness.bigEndian

    var LE_strstrm: StringStream = newStringStream("")
    LE_img.write_pfm(LE_strstrm)
    let LE_res = charSeqToByte(LE_strstrm.data.toSeq())
    assert LE_res == LE_BYTES

    var BE_strstrm: StringStream = newStringStream("")
    BE_img.write_pfm(BE_strstrm)
    let BE_res = charSeqToByte(BE_strstrm.data.toSeq())
    assert BE_res == BE_BYTES


proc test_parse_image_size=
    assert HdrImage.parse_img_size("100 100") == (100,100)
    assert HdrImage.parse_img_size("1920 1080") == (1920,1080)
    try:
        assert HdrImage.parse_img_size("801 601") == (800,600)
    except AssertionDefect:
        echo "Failed image size parsing"


proc test_parse_endianess=
    assert HdrImage.parse_endianess("-1.0") == hdrimage.Endianness.littleEndian
    assert HdrImage.parse_endianess("1.0") == hdrimage.Endianness.bigEndian

proc test_readpfm()=
    var img_test = newHdrImage(3,2)
    const le_ref_bytes = [byte 0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
      0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
      0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
      0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
      0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
      0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
      0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42]
    const be_ref_bytes = [byte 0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x31, 0x2e, 0x30, 0x0a, 0x42,
      0xc8, 0x00, 0x00, 0x43, 0x48, 0x00, 0x00, 0x43, 0x96, 0x00, 0x00, 0x43,
      0xc8, 0x00, 0x00, 0x43, 0xfa, 0x00, 0x00, 0x44, 0x16, 0x00, 0x00, 0x44,
      0x2f, 0x00, 0x00, 0x44, 0x48, 0x00, 0x00, 0x44, 0x61, 0x00, 0x00, 0x41,
      0x20, 0x00, 0x00, 0x41, 0xa0, 0x00, 0x00, 0x41, 0xf0, 0x00, 0x00, 0x42,
      0x20, 0x00, 0x00, 0x42, 0x48, 0x00, 0x00, 0x42, 0x70, 0x00, 0x00, 0x42,
      0x8c, 0x00, 0x00, 0x42, 0xa0, 0x00, 0x00, 0x42, 0xb4, 0x00, 0x00]  
    
    # testing little endianness
    
    var
        img = newHdrImage()
        str = bytesToString(le_ref_bytes)
        strm = newStringStream(str)
    img.read_pfm(strm)
    
    assert img.width == 3
    assert img.height == 2
    assert img.getPixel(0, 0) == newColor(1.0e1, 2.0e1, 3.0e1)
    assert img.getPixel(1, 0) == newColor(4.0e1, 5.0e1, 6.0e1)
    assert img.getPixel(2, 0) == newColor(7.0e1, 8.0e1, 9.0e1)
    assert img.getPixel(0, 1) == newColor(1.0e2, 2.0e2, 3.0e2)
    assert img.getPixel(1, 1) == newColor(4.0e2, 5.0e2, 6.0e2)
    assert img.getPixel(2, 1) == newColor(7.0e2, 8.0e2, 9.0e2)
  
    # testing big endianness

    var
        img1 = newHdrImage()
        str1 = bytesToString(be_ref_bytes)
        stream1 = newStringStream(str1)
    img1.read_pfm(stream1)
    
    assert img1.width == 3
    assert img1.height == 2
    assert img1.getPixel(0, 0) == newColor(1.0e1, 2.0e1, 3.0e1)
    assert img1.getPixel(1, 0) == newColor(4.0e1, 5.0e1, 6.0e1)
    assert img1.getPixel(2, 0) == newColor(7.0e1, 8.0e1, 9.0e1)
    assert img1.getPixel(0, 1) == newColor(1.0e2, 2.0e2, 3.0e2)
    assert img1.getPixel(1, 1) == newColor(4.0e2, 5.0e2, 6.0e2)
    assert img1.getPixel(2, 1) == newColor(7.0e2, 8.0e2, 9.0e2)
    

################  RUN  ####################
test_creation()
test_coordinate_validation()
test_set_pixel()
test_pfm_write()
test_parse_image_size()
test_parse_endianess()
test_readpfm()
