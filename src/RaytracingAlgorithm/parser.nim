import exception
import std/[streams, sequtils, sugar, strutils, options]

type
    SourceLocation* = object
        fileName*: string
        lineNum*: int
        colNum*: int
    
    InputStream* = object
        stream*: Stream
        location*: SourceLocation
        savedChar*: char
        savedLocation*: SourceLocation
        savedToken*: Option[Token]

    KeywordType* = enum
        NEW,
        MATERIAL,
        PLANE,
        SPHERE,
        DIFFUSE,
        SPECULAR,
        UNIFORM,
        CHECKERED,
        IMAGE,
        IDENTITY,
        TRANSLATION,
        ROTATIONX,
        ROTATIONY,
        ROTATIONZ,
        SCALE,
        CAMERA,
        ORTHOGONAL,
        PERSPECTIVE,
        FLOAT

    TokenKind = enum  # the different token types
        tkKeyword,          # 
        tkIdentifier,        # 
        tkString,       # 
        tkNumber,          # 
        tkSymbol,          # 
        tkStop            #

    TokenObj = object
        location*: SourceLocation
        case kind: TokenKind
        of tkKeyword: keywordVal: KeywordType
        of tkIdentifier: identifierVal: string
        of tkString: stringVal: string
        of tkNumber: numberVal: float32
        of tkSymbol: symbolVal: char
        of tkStop: stopVal: string

    Token = ref TokenObj

converter toKeywordType(s: string): KeywordType = parseEnum[KeywordType](s)

proc UnreadChar(self: var InputStream, c: char): void=
    self.savedChar = c
    self.location.shallowCopy(self.savedLocation)

proc SkipWhitespacesAndComments(self: var InputStream): void=
    var WHITESPACE: string = " \t\n\r"
    let s = @['\r','\n',' ']
    var c: char = self.stream.readChar()
    while c in WHITESPACE or c == '#':
        if c == '#':
            while not s.any(x => x == self.stream.readChar()) :
                discard
        c = self.stream.readChar()
        if c == ' ':
            return
    self.UnreadChar(c)


proc ParseStringToken(self: var InputStream, tokenLocation: SourceLocation): Token=
    var token: string = ""
    while true:
        let c = self.stream.readChar()

        if c == '"':
            break
        if c == ' ':
            raise TestError.newException("")
        token = token & c
    return Token(kind: tkString, location: tokenLocation, stringVal: token)

proc ParseKeywordOrIdentifierToken(self: var InputStream, firstChar: char, tokenLocation: SourceLocation): Token=
    var token: string = cast[string](firstChar)
    while true:
        let c = self.stream.readChar()
        if not c.isAlphaNumeric() or c == '_':
            self.UnreadChar(c)
            break
        token = token & c
    
    try:
        return Token(kind: tkKeyword, location: tokenLocation, keywordVal: token)
    except:
        return Token(kind: tkIdentifier, location: tokenLocation, identifierVal: token)

proc ParseFloatToken(self: var InputStream, firstChar: char, tokenLocation: SourceLocation): Token=
    var token: string = cast[string](firstChar)
    while true:
        let c = self.stream.readChar()
        if not Digits.contains(c) or c == '.' or {'e','E'}.contains(c):
            self.UnreadChar(c)
            break
        token = token & c
    var value: float32
    try:
        value = cast[float32](token)
    except:
        raise TestError.newException("ciao")
    return Token(kind: tkNumber, location: tokenLocation, numberVal: value)

proc ReadToken(self: var InputStream): Token=
    let SYMBOLS = "()[],*"
    self.SkipWhitespacesAndComments()
    var c: char = self.stream.readChar()
    if c == ' ':
        return Token(kind: tkStop, location: self.location, stopVal: "")
    var tokenLocation: SourceLocation
    tokenLocation.shallowCopy(self.location)

    if c in SYMBOLS:
        return Token(kind: tkSymbol, location: tokenLocation, symbolVal: c)
    elif c == '"':
        return self.ParseStringToken(tokenLocation)
    elif Digits.contains(c) or {'+','-','.'}.contains(c):
        return self.ParseFloatToken(c, tokenLocation)
    elif c.isAlphaNumeric() or c == '_':
        return self.ParseKeywordOrIdentifierToken(c, tokenLocation)
    else:
        raise TestError.newException("ciao")

proc UnreadToken(self: var InputStream, token: Token): void=
    assert not self.savedToken.isSome
    self.savedToken = some(token)



