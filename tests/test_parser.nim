import "../src/RaytracingAlgorithm/parser.nim"
import std/[streams]


proc test_inputstream()=
    var strm: StringStream = newStringStream("abc \nd\nef")
    var stream: InputStream = newInputStream(strm, newSourceLocation(""))
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 1
    assert stream.ReadChar() == 'a'
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 2
    stream.UnreadChar('A')
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 1
    assert stream.ReadChar() == 'A'
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 2
    assert stream.ReadChar() == 'b'
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 3
    assert stream.ReadChar() == 'c'
    assert stream.location.lineNum == 1
    assert stream.location.colNum == 4
    stream.SkipWhitespacesAndComments()
    assert stream.ReadChar() == 'd'
    assert stream.location.lineNum == 2
    assert stream.location.colNum == 2
    assert stream.ReadChar() == '\n'
    assert stream.location.lineNum == 3
    assert stream.location.colNum == 1
    assert stream.ReadChar() == 'e'
    assert stream.location.lineNum == 3
    assert stream.location.colNum == 2
    assert stream.ReadChar() == 'f'
    assert stream.location.lineNum == 3
    assert stream.location.colNum == 3
    assert stream.ReadChar() == ' '

test_inputstream()