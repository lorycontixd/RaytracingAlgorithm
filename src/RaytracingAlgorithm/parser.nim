import exception, scene, geometry, material, color, hdrimage, transformation, shape, camera, world, triangles, renderer, pcg, lights
import std/[streams, sequtils, sugar, strutils, options, typetraits, tables, strformat, sets, marshal]

## ------------- PARSER ---------------
## used to analyze a sequnce of tokens in order to understand the syntactic and semantic strucuture
## 
## before the parser we have the lexer, which reads from a stream and returns a list of token, classified
## by type (TokenKind)

type
    SourceLocation* = object  # A specific position in a source file
        fileName*: string
        lineNum*: int
        colNum*: int
    
    InputStream* = object # A wrapper around a stream
        stream*: Stream
        location*: SourceLocation
        savedChar*: Option[char]
        savedLocation*: SourceLocation
        savedToken*: Option[Token]
        tabulations*: int

    KeywordType* = enum
        NEW,
        MATERIAL,
        RENDERER,
        # SHAPES
        PLANE,
        SPHERE,
        MESH,
        # BRDF
        DIFFUSE,
        SPECULAR,
        PHONG,
        COOKTORRANCE,
        # PIGMENT
        UNIFORM,
        CHECKERED,
        IMAGE,
        GRADIENT,
        # NDFs
        GGX,
        BECKMANN,
        BLINN,
        # TRANSFORMS
        IDENTITY,
        TRANSLATION,
        ROTATIONX,
        ROTATIONY,
        ROTATIONZ,
        SCALE,
        # CAMERAAS
        CAMERA,
        ORTHOGONAL,
        PERSPECTIVE,
        # LIGHTS
        LIGHT,
        # RENDERERS
        POINTLIGHT
        ONOFF, #pointlight is also a renderer keyword  --->  renderer(pointlight, ...) or renderer(pathtracer, ...)
        PATHTRACER,
        FLAT,
        # TYPES
        FLOAT,
        BOOL
        INT,
        STRING,
        # OTHERS
        WIDTH,
        HEIGHT,
        # SETTINGS
        SET,
        LOGGER,
        ANTIALIASING,
        STATS

    TokenKind* = enum  # the different token types (tags)
        tkKeyword,          # keywords of our language
        tkIdentifier,        # variable/function/type name
        tkString,       # string of characters
        tkNumber,          # literal number
        tkSymbol,          # a non-alphanumeric character
        tkStop            # token indicating the end of file

    TokenObj* = object
    # class used when parsing a scene file, to decompose source code into simple elements to be read
        location*: SourceLocation
        case kind*: TokenKind
        of tkKeyword: keywordVal*: KeywordType
        of tkIdentifier: identifierVal*: string
        of tkString: stringVal*: string
        of tkNumber: numberVal*: float32
        of tkSymbol: symbolVal*: char
        of tkStop: stopVal*: string

    Token* = ref TokenObj

# -------------------- EXCEPTIONS --------------------------
type
    InvalidTokenSymbolError* = ref object of ParserError
        symbol*: char
        token*: Token
    InvalidTokenKindError* = ref object of ParserError
        expectedKind*: TokenKind
        kind*: TokenKind
    InvalidTokenKeywordsError* = ref object of ParserError
        token* : Token
    InvalidTokenNumberError* = ref object of ParserError
    InvalidTokenStringError* = ref object of ParserError
    InvalidTokenIdentifierError* = ref object of ParserError

## --- ParserError
proc newInvalidTokenSymbolError*(symbol: char, token: Token): InvalidTokenSymbolError =
    result = InvalidTokenSymbolError(symbol: symbol, token:token, msg: fmt"Expected symbol {symbol} but got token {$$token.symbolVal} in {token.location} ") 
proc newInvalidTokenKindError*(expectedKind: TokenKind, kind: Token.kind): InvalidTokenKindError =
    result = InvalidTokenKindError(expectedKind: expectedKind, kind:kind, msg:fmt"Expected {expectedKind} but got {kind}")
proc newInvalidTokenKeywordsError*(token: Token): InvalidTokenKeywordsError =
    result = InvalidTokenKeywordsError(token:token, msg:fmt" {token.keywordVal} is not a keyword")
#proc newInvalidTokenNumberError*() = discard
#proc newInvalidTokenStringError*() = discard
#proc newInvalidTokenIdentifierError*() = discard

# --------------------------------------------------------------

converter toKeywordType(s: string): KeywordType = parseEnum[KeywordType](s.toUpperAscii())
## Enumeration for all the possible keywords recognized by the lexer

proc newSourceLocation*(filename: string, row: int = 1, col: int = 1): SourceLocation=
    ## Constructor for SourceLocation
    ## Parameters
    ##      filename (string): name of file to be read
    ##      row, col (int): index of row and column _ Default value: 1, 1
    ## Returns
    ##      (SourceLocation)
    return SourceLocation(fileName: filename, lineNum: row, colNum: col)

proc newInputStream*(strm: Stream, location: SourceLocation, tabulations: int = 4): InputStream=
    ## Constructor for InputStream
    ## Parameters
    ##      strm (Stream): stream to be read
    ##      location(SourceLocation): location in the stream
    ##      tabulations(int): number of whitespaces to be considered as a tab _ Default value : 4
    ## Returns
    ##      (InputStream)
    return InputStream(stream: strm, location: location, tabulations: tabulations)
    

proc UpdatePosition(self: var InputStream, c: Option[char])=
    ## Updates `location` after having read `c` from the stream
    ## Parameters
    ##      self (InputStream) : stream
    ##      c (char): char read
    ## Returns
    ##      no returns, just updates 'location'
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
    ## Reads a new character from the stream
    ## Parameters
    ##      self (InputStream) : stream
    ## Returns
    ##      c (Char): the read character
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
    ## Pushes a character back to the stream
    ## Parameters
    ##      self (InputStream): stream
    ##      c (Char): the character to be 'unread'
    ## Returns
    ##       no returns, just pushes back
    self.savedChar = some(c)
    self.location.shallowCopy(self.savedLocation)

proc SkipWhitespacesAndComments*(self: var InputStream): void=
    ## Keeps reading characters until a 'non-whitespace' or 'non-comment' character is found
    ## Parameters
    ##      self (InputStream): stream 
    ## Returns
    ##      no returns
    var WHITESPACE: string = " \t\n\r"
    let s = {'\r','\n'}
    var c: Option[char] = self.ReadChar()
    var x: char = c.get()
    while x in WHITESPACE or x == '#':
        if x == '#':
            while not s.contains(self.stream.readChar()) and not self.stream.atEnd():
                discard
        x = self.ReadChar().get().char
        if self.stream.atEnd() or x == '\x00':
            return
    self.UnreadChar(x)

proc ParseStringToken(self: var InputStream, tokenLocation: SourceLocation): Token=
    ## Returns a Token of kind 'tkString' from the read characters 
    ## Parameters
    ##      self (InputStream): stream
    ##      tokenLocation (SourceLocation): postion in the stream
    ## Returns
    ##      Token of kind 'tkString'
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
    ## Returns a Token of kind 'tkKeyword' or 'tkIdentifier' from the read characters 
    ## Parameters
    ##      self (InputStream): stream
    ##      tokenLocation (SourceLocation): postion in the stream
    ## Returns
    ##      Token of kind 'tkKeyword' or 'tkIdentifier'
    var token: string = $firstChar
    while true:
        let c = self.ReadChar()
        if not (c.get().isAlphaNumeric() or c.get() == '_'):
            self.UnreadChar(c.get())
            break
        token = token & c.get()
    try:
        # if it is a Keyword, it must be listed in the KEYWORDS dictionary
        return Token(kind: tkKeyword, location: tokenLocation, keywordVal: token)
    except:
        # if we got 'exception', it is not a keyword and thus it must be an identifier
        return Token(kind: tkIdentifier, location: tokenLocation, identifierVal: token)

proc ParseFloatToken(self: var InputStream, firstChar: char, tokenLocation: SourceLocation): Token=
    ## Returns a Token of kind 'tkNumber' from the read characters 
    ## Parameters
    ##      self (InputStream): stream
    ##      tokenLocation (SourceLocation): postion in the stream
    ## Returns
    ##      Token of kind 'tkNumber'
    var token: string = $firstChar
    while true:
        let c = self.ReadChar()
        if not (Digits.contains(c.get()) or c.get() == '.' or {'e','E'}.contains(c.get())):
            self.UnreadChar(c.get())
            break
        token = token & c.get()
    var value: float32
    try:
        value = parseFloat(token)
    except:
        raise TestError.newException("ciao")
    return Token(kind: tkNumber, location: tokenLocation, numberVal: value)

proc ReadToken*(self: var InputStream): Token=
    ## Reads a token from a stream
    ## Parameters
    ##      self(InputStream): stream
    ## Returns
    ##      (Token): read token
    let SYMBOLS = "()[],*<>"
    self.SkipWhitespacesAndComments()
    var c: Option[char] = self.ReadChar()
    if not (c.isSome) or c.get() == '\x00':
        # no more character in the file, return the StopToken
        return Token(kind: tkStop, location: self.location, stopVal: "")
    var tokenLocation: SourceLocation
    tokenLocation.shallowCopy(self.location)
     # check what kind of token begins with 'c' character
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
        echo "Char is not valid: ",x
        raise TestError.newException("errore in lettura char")

proc UnreadToken*(self: var InputStream, token: Token): void=
    ## Makes as if `token` has never been read from the stream
    ## Parameters
    ##      self (InputStream): stream
    ##      token (Token): token to be 'unread'
    ## Returns
    ##      no returns, just 'unreads'
    assert not self.savedToken.isSome
    self.savedToken = some(token)





proc ExpectSymbol*(file: var InputStream, symbol: char)=
    ## Reads a token from 'input-file' and check that it matches `symbol`
    ## Parameters
    ##      file (InputStream): stream
    ##      symbol (char): symbol to be matched
    ## Returns
    ##      no returns, it's just a control    
    let token = file.ReadToken()
    if token.kind != TokenKind.tkSymbol:
        raise newInvalidTokenKindError(TokenKind.tkSymbol, token.kind)
    if token.symbolVal != symbol:
        raise newInvalidTokenSymbolError(symbol, token)

proc ExpectKeywords*(file: var InputStream, keywords: seq[KeywordType]): KeywordType=
    ## Reads a token from 'input-file' and check that it is one of KEYWORDTYPE
    ## Parameters
    ##      file (InputStream): stream
    ##      keywords (seq[KeyWordType]): symbol to be matched
    ## Returns
    ##      (KeywordType): the keyword as a '.KeywordType' object
    let token = file.ReadToken()
    if token.kind != TokenKind.tkKeyword:
        raise newInvalidTokenKindError(TokenKind.tkKeyword, token.kind)
    if not (token.keywordVal in keywords):
        raise newInvalidTokenKeywordsError(token)
    return token.keywordVal

proc ExpectNumber*(file: var InputStream, scene: Scene): float32=
    ## Reads a token from 'input-file' and check that it is a literal number or a variable of 'scene'
    ## Parameters
    ##      file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      scene.float_variables (flaot): number 
    let token = file.ReadToken()
    var variable_name: string
    if (token.kind == tkNumber):
        return token.numberVal
    elif (token.kind == tkIdentifier):
        variable_name = token.identifierVal
        if not (scene.float_variables.hasKey(variable_name)):
            raise TestError.newException("Unknown variable")
        return scene.float_variables[variable_name]
    raise newInvalidTokenKindError(TokenKind.tkNumber, token.kind)


proc ExpectString*(input_file: var InputStream): string=
    ## Reads a token from 'input-file' and check that it matches `symbol`
    ## Parameters
    ##      file (InputStream): stream
    ##      symbol (char): symbol to be matched
    ## Returns
    ##      no returns, it's just a control  
    let token = input_file.ReadToken()
    if token.kind != TokenKind.tkString:
        raise newInvalidTokenKindError(TokenKind.tkString, token.kind)
    return token.stringVal


proc ExpectIdentifier*(input_file: var InputStream):string=
    ## Reads a token from 'input-file' and check that it is an identifier
    ## Parameters
    ##      input_file (InputStream): stream
    ## Returns
    ##      token.identifierVal (string): name of the identifier
    let token = input_file.ReadToken()
    if token.kind != TokenKind.tkIdentifier:
        raise newInvalidTokenKindError(TokenKind.tkIdentifier ,token.kind)
    return token.identifierVal


proc ParseVector*(input_file: var InputStream, scene: Scene): Vector3=
    ## Interpretates tokens of input-file and returns the corresponding vector
    ## Parameters
    ##      input_file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      (Vector3)
    ExpectSymbol(input_file, '[')
    let x = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ',')
    let y = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ',')
    let z = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ']')

    return newVector3(x, y, z)


proc ParseColor*(input_file: var InputStream, scene: Scene): Color=
    ## Interpretates tokens of input-file and returns the corresponding color
    ## Parameters
    ##      input_file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      (Color)
    ExpectSymbol(input_file, '<')
    let red = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ',')
    let green = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ',')
    let blue = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, '>')
    return newColor(red, green, blue)


proc ParsePigment*(input_file: var InputStream, scene: Scene): Pigment=
    ## Interpretates tokens of input-file and returns the corresponding pigment
    ## Parameters
    ##      input_file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      (Pigment)
    let keyword = ExpectKeywords(input_file, @[KeywordType.UNIFORM, KeywordType.CHECKERED, KeywordType.IMAGE, KeywordType.GRADIENT])
    ExpectSymbol(input_file, '(')
    if keyword == KeywordType.UNIFORM:
        let color = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ')')
        result = newUniformPigment(color)
    elif keyword == KeywordType.CHECKERED:
        let color1 = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ',')
        let color2 = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ',')
        let num_of_steps = int(ExpectNumber(input_file, scene))
        ExpectSymbol(input_file, ')')
        result = newCheckeredPigment(color1, color2, num_of_steps)
    elif keyword == KeywordType.IMAGE:
        let file_name = ExpectString(input_file)
        var image_file: FileStream = newFileStream(file_name, fmRead)
        if image_file.isNil:
            raise TestError.newException(fmt"File {file_name} does not exist.")
        var image: HdrImage = newHdrImage()
        image.read_pfm(image_file)
        ExpectSymbol(input_file, ')')
        result = newImagePigment(image)
    elif keyword == KeywordType.GRADIENT:
        let c1 = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ',')
        let c2 = ParseColor(input_file, scene)
        ExpectSymbol(input_file,',')
        let uCoefficient = ExpectNumber(input_file, scene)
        ExpectSymbol(input_file, ',')
        let vCoefficient = ExpectNumber(input_file, scene)
        ExpectSymbol(input_file, ')')
        result = newGradientPigment(c1, c2, 1.0, uCoefficient, vCoefficient)
    else:
        raise TestError.newException("This line should be unreachable")



proc ParseBrdf*(input_file: var InputStream, scene: Scene): BRDF=
    ## Interpretates tokens of input-file and returns the corresponding BRDF
    ## Parameters
    ##      input_file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      (BRDF)
    let brdf_keyword = ExpectKeywords(input_file, @[KeywordType.DIFFUSE, KeywordType.SPECULAR, KeywordType.PHONG, KeywordType.COOKTORRANCE])
    ExpectSymbol(input_file, '(')
    let pigment = ParsePigment(input_file, scene)
    ExpectSymbol(input_file, ',')
    if brdf_keyword == KeywordType.DIFFUSE:
        # pigment, reflectance
        let reflectance = ExpectNumber(input_file, scene)
        ExpectSymbol(input_file, ')')
        return newDiffuseBRDF(pigment, reflectance)
    elif brdf_keyword == KeywordType.SPECULAR:
        let thresholdangle = ExpectNumber(input_file, scene)
        ExpectSymbol(input_file, ')')
        return newSpecularBRDF(pigment, thresholdangle)
    elif brdf_keyword == KeywordType.PHONG:
        let shininess = ExpectNumber(input_file, scene)
        ExpectSymbol(input_file,',')
        let diffuseCoefficient = ExpectNumber(input_file, scene)
        ExpectSymbol(input_file,',')
        let specularCoefficient = ExpectNumber(input_file, scene)
        ExpectSymbol(input_file, ')')
        return newPhongBRDF(pigment, shininess, diffuseCoefficient, specularCoefficient)
    elif brdf_keyword == KeywordType.COOKTORRANCE:
        let diffuseCoefficient = ExpectNumber(input_file, scene)
        ExpectSymbol(input_file,',')
        let specularCoefficient = ExpectNumber(input_file, scene)
        ExpectSymbol(input_file, ',')
        let roughness = ExpectNumber(input_file, scene)
        let
            albedo = 1.0
            metallic = 1.0
        ExpectSymbol(input_file, ',')
        let ndf_keyword = ExpectKeywords(input_file, @[KeywordType.GGX, KeywordType.BECKMANN, KeywordType.BLINN])
        var ndf_var: CookTorranceNDF
        if ndf_keyword == KeywordType.GGX:
            ndf_var = CookTorranceNDF.GGX
        elif ndf_keyword == KeywordType.BECKMANN:
            ndf_var = CookTorranceNDF.Beckmann
        elif ndf_keyword == KeywordType.BLINN:
            ndf_var = CookTorranceNDF.Blinn
        else:
            raise TestError.newException("invalid ndf keyword")
        ExpectSymbol(input_file, ')')
        return newCookTorranceBRDF(pigment, diffuseCoefficient, specularCoefficient, roughness, albedo, metallic, ndf_var)
    
    raise TestError.newException("This line should be unreachable")


proc ParseMaterial*(input_file: var InputStream, scene: Scene): (string, Material)=
    ## Interpretates tokens of input-file and returns the corresponding material
    ## Parameters
    ##      input_file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      (string, Material): identifier, material
    let name = ExpectIdentifier(input_file)
    ExpectSymbol(input_file, '(')
    let brdf = ParseBrdf(input_file, scene)
    ExpectSymbol(input_file, ',')
    let emitted_radiance = ParsePigment(input_file, scene)
    ExpectSymbol(input_file, ')')
    return (name, newMaterial(brdf, emitted_radiance))


proc ParseTransformation*(input_file: var InputStream, scene: Scene): Transformation=
    ## Interpretates tokens of input-file and returns the corresponding transformation
    ## Parameters
    ##      input_file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      (Transformation)
    result = newTransformation()

    while true:
        let transformation_kw = ExpectKeywords(input_file, @[
            KeywordType.IDENTITY,
            KeywordType.TRANSLATION,
            KeywordType.ROTATION_X,
            KeywordType.ROTATION_Y,
            KeywordType.ROTATION_Z,
            KeywordType.SCALE,
        ])

        #if transformation_kw == KeywordType.IDENTITY:
        if transformation_kw == KeywordType.TRANSLATION:
            ExpectSymbol(input_file, '(')
            result = result * Transformation.translation(ParseVector(input_file, scene))
            ExpectSymbol(input_file, ')')
        elif transformation_kw == KeywordType.ROTATION_X:
            ExpectSymbol(input_file, '(')
            result = result * Transformation.rotation_x(ExpectNumber(input_file, scene))
            ExpectSymbol(input_file, ')')
        elif transformation_kw == KeywordType.ROTATION_Y:
            ExpectSymbol(input_file, '(')
            result = result * Transformation.rotation_y(ExpectNumber(input_file, scene))
            ExpectSymbol(input_file, ')')
        elif transformation_kw == KeywordType.ROTATION_Z:
            ExpectSymbol(input_file, '(')
            result = result * Transformation.rotation_z(ExpectNumber(input_file, scene))
            ExpectSymbol(input_file, ')')
        elif transformation_kw == KeywordType.SCALE:
            ExpectSymbol(input_file, '(')
            result = result * Transformation.scale(ParseVector(input_file, scene))
            ExpectSymbol(input_file, ')')

        # We must peek the next token to check if there is another transformation that is being
        # chained or if the sequence ends. Thus, this is a LL(1) parser.
        let next_kw = input_file.ReadToken()
        if (next_kw.kind != tkSymbol) or (next_kw.symbolVal != '*'):
            # Pretend you never read this token and put it back!
            input_file.UnreadChar(next_kw.symbolVal)
            break

proc ParseRenderer*(input_file: var InputStream, scene: Scene): Renderer=
    ##
    ExpectSymbol(input_file, '(')
    let renderer_keyword = ExpectKeywords(input_file, @[KeywordType.POINTLIGHT, KeywordType.ONOFF, KeywordType.FLAT, KeywordType.PATHTRACER])
    ExpectSymbol(input_file, ',')
    if renderer_keyword == KeywordType.POINTLIGHT:
        let backgroundColor = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ',')
        let ambientColor = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ')')
        return newPointlightRenderer(scene.world, backgroundColor, ambientColor)
    elif renderer_keyword == KeywordType.ONOFF:
        let backgroundColor = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ',')
        let color = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ')')
        return newOnOffRenderer(scene.world, backgroundColor, color)
    elif renderer_keyword == KeywordType.FLAT:
        let backgroundColor = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ')')
        return newFlatRenderer(scene.world, backgroundColor)
    elif renderer_keyword == KeywordType.PATHTRACER:
        let backgroundColor = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ',')
        let numrays = int(ExpectNumber(input_file, scene))
        ExpectSymbol(input_file, ',')
        let maxRayDepth = int(ExpectNumber(input_file, scene))
        ExpectSymbol(input_file, ',')
        let russianRouletteLimit = int(ExpectNumber(input_file, scene))
        ExpectSymbol(input_file, ')')
        return newPathTracer(scene.world, backgroundColor, newPCG(), numrays, maxRayDepth, russianRouletteLimit)
    else:
        raise TestError.newException("Invalid keyworld for renderer.")

proc ParsePointlight(input_file: var InputStream, scene: Scene): Pointlight=
    ExpectSymbol(input_file, '(')
    let position = ParseVector(input_file, scene)
    ExpectSymbol(input_file, ',')
    let color = ParseColor(input_file, scene)
    ExpectSymbol(input_file, ',')
    let linearRadius = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ')')
    return newPointlight(position.convert(Point), color, linearRadius)

proc ParseSphere*(input_file: var InputStream, scene: Scene): Sphere=
    ## Interpretates tokens of input-file and returns the corresponding sphere
    ## Parameters
    ##      input_file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      (Sphere)
    ExpectSymbol(input_file, '(')

    let material_name = ExpectIdentifier(input_file)
    if not scene.materials.hasKey(material_name):
        # We raise the exception here because input_file is pointing to the end of the wrong identifier
        raise TestError.newException(fmt"unknown material {material_name}")

    ExpectSymbol(input_file, ',')
    let transformation = ParseTransformation(input_file, scene)
    ExpectSymbol(input_file, ')')

    return newSphere(transform=transformation, material=scene.materials[material_name])


proc ParsePlane(input_file: var InputStream, scene: Scene):Plane=
    ## Interpretates tokens of input-file and returns the corresponding plane
    ## Parameters
    ##      input_file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      (Plane)
    ExpectSymbol(input_file, '(')

    let material_name = ExpectIdentifier(input_file)
    if not (scene.materials.hasKey(material_name)):
        # We raise the exception here because input_file is pointing to the end of the wrong identifier
        raise TestError.newException(fmt"unknown material {material_name}")

    ExpectSymbol(input_file, ',')
    var transformation: Transformation = ParseTransformation(input_file, scene)
    ExpectSymbol(input_file, ')')
    return newPlane(transform=transformation, material=scene.materials[material_name])

proc ParseMesh(input_file: var InputStream, scene: Scene): TriangleMesh=
    ExpectSymbol(input_file, '(')
    let filenameOBJ = ExpectString(input_file)
    ExpectSymbol(input_file, ',')
    let transformation: Transformation = ParseTransformation(input_file, scene)
    ExpectSymbol(input_file, ',')
    let material_name = ExpectIdentifier(input_file)
    ExpectSymbol(input_file, ')')
    if not (scene.materials.hasKey(material_name)):
        # We raise the exception here because input_file is pointing to the end of the wrong identifier
        raise TestError.newException(fmt"unknown material {material_name}")
    return newTriangleMeshOBJ(transformation, filenameOBJ, scene.materials[material_name])

proc ParseCamera*(input_file: var InputStream, scene: Scene): Camera=
    ## Interpretates tokens of input-file and returns the corresponding camera
    ## Parameters
    ##      input_file (InputStream): stream
    ##      scene (Scene)
    ## Returns
    ##      (Camera)
    ExpectSymbol(input_file, '(')
    let type_kw = ExpectKeywords(input_file, @[KeywordType.PERSPECTIVE, KeywordType.ORTHOGONAL])
    ExpectSymbol(input_file, ',')
    let transformation = ParseTransformation(input_file, scene)
    ExpectSymbol(input_file, ',')
    let aspect_ratio = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ',')
    let distance = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ')')

    if type_kw == KeywordType.PERSPECTIVE:
        result = newPerspectiveCamera(distance=distance, aspectratio=aspect_ratio, transform=transformation)
    elif type_kw == KeywordType.ORTHOGONAL:
        result = newOrthogonalCamera(aspectratio=aspect_ratio, transform=transformation)

proc BuildVariableTable*(definitions: seq[string]): Table[string, float32] =
    ## Parse the list of `-d` switches and return a dictionary associating variable names with their values"""

    result = initTable[string, float32]()
    for declaration in definitions:
        let parts = declaration.split(":")
        if len(parts) != 2:
            echo(fmt"error, the definition «{declaration}» does not follow the pattern NAME:VALUE")
            raise TestError.newException("ciao")

        var
            name: string = parts[0]
            value: string = parts[1]
            newvalue: float32
        try:
            newvalue = cast[float32](value)
        except ValueError:
            echo(fmt"invalid floating-point value «{value}» in definition «{declaration}»")

        result[name] = newvalue


proc ParseScene*(input_file: var InputStream, variables: Table[string, float32] = initTable[string, float32]()): Scene=
    ## Interpretates tokens of input-file and returns the corresponding scene
    ## Parameters
    ##      input_file (InputStream): stream
    ##      variables (Table[string, float]): characters to be interpretated
    ## Returns
    ##      (Scene)
    var scene: Scene = newScene()
    scene.float_variables.shallowCopy(variables)
    var keyslist: seq[string] = @[]
    for k in variables.keys:
        keyslist.add(k)
    scene.overridden_variables = toHashSet(keyslist)

    while true:
        let what = input_file.ReadToken()
        if what.kind == tkStop:
            break
        
        if what.kind != tkKeyword:
            raise TestError.newException(fmt"expected a keyword instead of '{what.kind}' at {what.location}")
        
        if what.keywordVal == KeywordType.FLOAT:
            let variable_name = ExpectIdentifier(input_file)

            # Save this for the error message
            let variable_loc = input_file.location

            ExpectSymbol(input_file, '(')
            let variable_value = ExpectNumber(input_file, scene)
            ExpectSymbol(input_file, ')')

            if (variable_name in scene.float_variables) and not (variable_name in scene.overridden_variables):
                #raise GrammarError(location=variable_loc, message=f"variable «{variable_name}» cannot be redefined")
                raise TestError.newException("ciao")

            if not (scene.overridden_variables.contains(variable_name)):
                # Only define the variable if it was not defined by the user *outside* the scene file
                # (e.g., from the command line)
                scene.float_variables[variable_name] = variable_value

        elif what.keywordVal == KeywordType.SPHERE:
            scene.world.Add(ParseSphere(input_file, scene))
        elif what.keywordVal == KeywordType.PLANE:
            scene.world.Add(ParsePlane(input_file, scene))
        elif what.keywordVal == KeywordType.MESH:
            var mesh_triangles: seq[Triangle] = CreateTriangleMesh(ParseMesh(input_file, scene))
            for mesh_triangle in mesh_triangles:
                scene.world.Add(mesh_triangle)
        elif what.keywordVal == KeywordType.CAMERA:
            if not scene.camera.isNil:
                raise TestError.newException(fmt"[] Cannot define more than one camera")
            scene.camera = ParseCamera(input_file, scene)
        elif what.keywordVal == KeywordType.MATERIAL:
            var name: string
            var mat: Material
            (name, mat) = ParseMaterial(input_file, scene)
            scene.materials[name] = mat
        elif what.keywordVal == KeywordType.RENDERER:
            if not scene.renderer.isNil:
                    raise TestError.newException(fmt"[] Cannot define more than one renderer")
            scene.renderer = ParseRenderer(input_file, scene)
        elif what.keywordVal == KeywordType.LIGHT:
            let pointLight = ParsePointlight(input_file, scene)
            scene.world.AddLight(pointLight)
    if scene.camera.isNil:
        raise TestError.newException("Scene must contain at least one camera.")
    if scene.renderer.isNil:
        raise TestError.newException("Scene must contain at least one renderer.")
    return scene



