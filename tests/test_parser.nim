import "../src/RaytracingAlgorithm/parser.nim"
import "../src/RaytracingAlgorithm/scene.nim"
import "../src/RaytracingAlgorithm/material.nim"
import "../src/RaytracingAlgorithm/color.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import std/[streams, options, marshal, tables]


proc test_inputstream()=
    var strm: StringStream = newStringStream("abc \nd\nef")
    var stream: InputStream = newInputStream(strm, newSourceLocation(""))
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 1
    assert stream.ReadChar().get() == 'a'
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 2
    stream.UnreadChar('A')
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 1
    assert stream.ReadChar().get() == 'A'
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 2
    assert stream.ReadChar().get() == 'b'
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 3
    assert stream.ReadChar().get() == 'c'
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 4
    stream.SkipWhitespacesAndComments()
    assert stream.ReadChar().get() == 'd'
    assert stream.location.lineNum == 2
    assert stream.location.colNum == 2
    assert stream.ReadChar().get() == '\n'
    assert stream.location.lineNum == 3
    assert stream.location.colNum == 1
    assert stream.ReadChar().get() == 'e'
    assert stream.location.lineNum == 3
    assert stream.location.colNum == 2
    assert stream.ReadChar().get() == 'f'
    assert stream.location.lineNum == 3
    assert stream.location.colNum == 3
    assert stream.savedChar == none(char)

proc assert_isKeyword(token: Token, keyword: KeywordType)=
    echo "token: ",$$token
    assert token.kind == Tokenkind.tkKeyword
    assert token.keywordVal == keyword

proc assert_isIdentifier(token: Token, identifier: string)=
    assert token.kind == Tokenkind.tkIdentifier
    assert token.identifierVal == identifier

proc assert_isSymbol(token: Token, symbol: char)=
    assert token.kind == TokenKind.tkSymbol 
    assert token.symbolVal == symbol

proc assert_isNumber(token: Token, number: float32)=
    assert token.kind == Tokenkind.tkNumber
    assert token.numberVal == number

proc assert_isString(token: Token, s: string)=
    assert token.kind == Tokenkind.tkString
    assert token.stringVal == s


proc test_lexer()=
    var strm: StringStream = newStringStream("""# This is a comment
        # This is another comment
        new material sky_material(
            diffuse(image("my file.pfm")),
            <5.0, 500.0, 300.0>
        ) # Comment at the end of the line""")
    #var strm: StringStream = newStringStream("# This is a comment\nnew material sky_material(\n\tdiffuse(image(<0, 0, 0>)),\n\tuniform(<0.7, 0.5, 1>)\n)")
    var stream: InputStream = newInputStream(strm, newSourceLocation(""))
    assert_isKeyword(stream.ReadToken(), KeywordType.NEW)
    assert_isKeyword(stream.ReadToken(), KeywordType.MATERIAL)
    assert_isIdentifier(stream.ReadToken(), "sky_material")
    assert_isSymbol(stream.ReadToken(), '(')
    assert_isKeyword(stream.ReadToken(), KeywordType.DIFFUSE)
    assert_isSymbol(stream.ReadToken(), '(')
    assert_isKeyword(stream.ReadToken(), KeywordType.IMAGE)
    assert_isSymbol(stream.ReadToken(), '(')
    assert_isString(stream.ReadToken(), "my file.pfm")
    assert_isSymbol(stream.ReadToken(), ')')


proc test_parser()=
    var strm: StringStream = newStringStream("""
        float clock(150)
    
        material sky_material(
            diffuse(uniform(<0, 0, 0>)),
            uniform(<0.7, 0.5, 1>)
        )
    
        # Here is a comment
    
        material ground_material(
            diffuse(checkered(<0.3, 0.5, 0.1>,
                              <0.1, 0.2, 0.5>, 4)),
            uniform(<0, 0, 0>)
        )
    
        material sphere_material(
            specular(uniform(<0.5, 0.5, 0.5>)),
            uniform(<0, 0, 0>)
        )
    
        plane (sky_material, translation([0, 0, 100]) * rotation_y(clock))
        plane (ground_material, identity)
    
        sphere(sphere_material, translation([0, 0, 1]))
    
        camera(perspective, rotation_z(30) * translation([-4, 0, 1]), 1.0, 2.0)
        """)
        
    var stream: InputStream = newInputStream(strm, newSourceLocation(""))
    var scene : Scene = ParseScene(stream)

    # Check that the float variables are ok
    assert len(scene.float_variables) == 1
    assert scene.float_variables.hasKey("clock")
    assert scene.float_variables["clock"] == 150.0

    # Check that the materials are ok
    assert len(scene.materials) == 3
    assert scene.materials.hasKey("sphere_material")
    assert scene.materials.hasKey("sky_material")
    assert scene.materials.hasKey("ground_material")

    let
        sphere_material = scene.materials["sphere_material"]
        sky_material = scene.materials["sky_material"]
        ground_material = scene.materials["ground_material"]

    assert sky_material.brdf of DiffuseBRDF
    assert sky_material.brdf.pigment of UniformPigment
    assert sky_material.brdf.pigment.getColor(newVector2(0.0,0.0)) == newColor(0.0,0.0,0.0)


test_inputstream()
test_lexer()
#test_parser()