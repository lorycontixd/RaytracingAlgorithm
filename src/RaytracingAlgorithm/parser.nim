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
        savedChar*: Option[char]
        savedLocation*: SourceLocation
        savedToken*: Option[Token]
        tabulations*: int

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

proc newSourceLocation*(filename: string, row: int = 1, col: int = 1): SourceLocation=
    return SourceLocation(fileName: filename, lineNum: row, colNum: col)

proc newInputStream*(strm: Stream, location: SourceLocation, tabulations: int = 4): InputStream=
    return InputStream(stream: strm, location: location, tabulations: tabulations)
    

proc UpdatePosition(self: var InputStream, c: Option[char])=
        #Update `location` after having read `c` from the stream
        if c == none(char):
            return
        if c.get() == '\n':
            self.location.lineNum += 1
            self.location.colNum = 1
        elif c.get() == '\t':
            self.location.colNum += self.tabulations
        else:
            self.location.colNum += 1

proc ReadChar*(self: var InputStream): Option[char]=
    ## Read a new character from the stream
    var c: Option[char]
    if self.savedChar != none(char):
        c = self.savedChar
        self.savedChar = none(char)
    else:
        c = some(self.stream.readChar())
    self.savedLocation.shallowCopy(self.location)
    self.UpdatePosition(c)
    return c

proc UnreadChar*(self: var InputStream, c: char): void=
    self.savedChar = some(c)
    self.location.shallowCopy(self.savedLocation)

proc SkipWhitespacesAndComments*(self: var InputStream): void=
    var WHITESPACE: string = " \t\n\r"
    let s = {'\r','\n'}
    var c: Option[char] = self.ReadChar()
    var x: char = c.get()
    while x in WHITESPACE or x == '#':
        if x == '#':
            while not s.contains(self.stream.readChar()):
                discard
        c = self.ReadChar()
        if not self.savedChar.isSome:
            return
    self.UnreadChar(c.get())

proc ParseStringToken(self: var InputStream, tokenLocation: SourceLocation): Token=
    var token: string = ""
    while true:
        let c = self.ReadChar()
        if not c.isSome:
            raise TestError.newException("")

        if c.get() == '"':
            break
        
        token = token & c.get()
    return Token(kind: tkString, location: tokenLocation, stringVal: token)

proc ParseKeywordOrIdentifierToken(self: var InputStream, firstChar: char, tokenLocation: SourceLocation): Token=
    var token: string = cast[string](firstChar)
    while true:
        let c = self.ReadChar()
        if not c.get().isAlphaNumeric() or c.get() == '_':
            self.UnreadChar(c.get())
            break
        token = token & c.get()
    try:
        return Token(kind: tkKeyword, location: tokenLocation, keywordVal: token)
    except:
        return Token(kind: tkIdentifier, location: tokenLocation, identifierVal: token)

proc ParseFloatToken(self: var InputStream, firstChar: char, tokenLocation: SourceLocation): Token=
    var token: string = cast[string](firstChar)
    while true:
        let c = self.ReadChar()
        if not Digits.contains(c.get()) or c.get() == '.' or {'e','E'}.contains(c.get()):
            self.UnreadChar(c.get())
            break
        token = token & c.get()
    var value: float32
    try:
        value = cast[float32](token)
    except:
        raise TestError.newException("ciao")
    return Token(kind: tkNumber, location: tokenLocation, numberVal: value)

proc ReadToken*(self: var InputStream): Token=
    let SYMBOLS = "()[],*"
    self.SkipWhitespacesAndComments()
    var c: Option[char] = self.ReadChar()
    if not c.isSome:
        return Token(kind: tkStop, location: self.location, stopVal: "")
    var tokenLocation: SourceLocation
    tokenLocation.shallowCopy(self.location)

    var x: char = c.get()
    if x in SYMBOLS:
        return Token(kind: tkSymbol, location: tokenLocation, symbolVal: x)
    elif x == '"':
        return self.ParseStringToken(tokenLocation)
    elif Digits.contains(x) or {'+','-','.'}.contains(x):
        return self.ParseFloatToken(x, tokenLocation)
    elif x.isAlphaNumeric() or x == '_':
        return self.ParseKeywordOrIdentifierToken(x, tokenLocation)
    else:
        raise TestError.newException("ciao")

proc UnreadToken*(self: var InputStream, token: Token): void=
    assert not self.savedToken.isSome
    self.savedToken = some(token)



