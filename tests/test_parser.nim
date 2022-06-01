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

test_inputstream()