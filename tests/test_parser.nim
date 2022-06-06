import "../src/RaytracingAlgorithm/parser.nim"
import std/[streams, options]


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
    #var strm: StringStream = newStringStream("new material sky_material")
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





test_inputstream()
test_lexer()