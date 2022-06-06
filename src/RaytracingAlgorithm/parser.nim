import exception, scene, geometry, material, color, hdrimage, transformation, shape, camera, world
import std/[streams, sequtils, sugar, strutils, options, typetraits, tables, strformat, sets]

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
        WIDTH,
        HEIGHT

    TokenKind* = enum  # the different token types
        tkKeyword,          # 
        tkIdentifier,        # 
        tkString,       # 
        tkNumber,          # 
        tkSymbol,          # 
        tkStop            #

    TokenObj* = object
        location*: SourceLocation
        case kind*: TokenKind
        of tkKeyword: keywordVal*: KeywordType
        of tkIdentifier: identifierVal*: string
        of tkString: stringVal*: string
        of tkNumber: numberVal*: float32
        of tkSymbol: symbolVal*: char
        of tkStop: stopVal*: string

    Token* = ref TokenObj

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
    echo "c from readChar", c
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
    echo "@@@@@@@", c
    if not c.isSome:
        return Token(kind: tkStop, location: self.location, stopVal: "")
    var tokenLocation: SourceLocation
    tokenLocation.shallowCopy(self.location)
    echo "------", c

    var x: char = c.get()
    echo "char is ", x
    if x in SYMBOLS:
        return Token(kind: tkSymbol, location: tokenLocation, symbolVal: x)
    elif x == '"':
        return self.ParseStringToken(tokenLocation)
    elif Digits.contains(x) or {'+','-','.'}.contains(x):
        return self.ParseFloatToken(x, tokenLocation)
    elif x.isAlphaNumeric() or x == '_':
        return self.ParseKeywordOrIdentifierToken(x, tokenLocation)
    else:
        raise TestError.newException("errore in lettura char")

proc UnreadToken*(self: var InputStream, token: Token): void=
    assert not self.savedToken.isSome
    self.savedToken = some(token)





proc ExpectSymbol*(file: var InputStream, symbol: char)=
    let token = file.ReadToken()
    if token.kind != TokenKind.tkSymbol or token.symbolVal != symbol:
        raise TestError.newException("ciao")

proc ExpectKeywords*(file: var InputStream, keywords: seq[KeywordType]): KeywordType=
    let token = file.ReadToken()
    if not (token.kind == tkKeyword):
        raise TestError.newException("ciao")

    if not (token.keywordVal in keywords):
        raise TestError.newException("ciao")
    return token.keywordVal

proc ExpectNumber*(file: var InputStream, scene: Scene): float32=
    let token = file.ReadToken()
    var variable_name: string
    if (token.kind == tkNumber):
        return token.numberVal
    elif (token.kind == tkIdentifier):
        variable_name = token.identifierVal
        if not (scene.float_variables.hasKey(variable_name)):
            raise TestError.newException("ciao")
        return scene.float_variables[variable_name]
    raise TestError.newException("ciao")


proc ExpectString*(input_file: var InputStream): string=
    let token = input_file.ReadToken()
    if not (token.kind == tkString):
        raise TestError.newException("ciao")

    return token.stringVal


proc ExpectIdentifier*(input_file: var InputStream):string=
    let token = input_file.ReadToken()
    if not (token.kind == tkIdentifier):
        raise TestError.newException("ciao")

    return token.identifierVal


proc ParseVector*(input_file: var InputStream, scene: Scene): Vector3=
    ExpectSymbol(input_file, '[')
    let x = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ',')
    let y = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ',')
    let z = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ']')

    return newVector3(x, y, z)


proc ParseColor*(input_file: var InputStream, scene: Scene): Color=
    ExpectSymbol(input_file, '<')
    let red = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ',')
    let green = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, ',')
    let blue = ExpectNumber(input_file, scene)
    ExpectSymbol(input_file, '>')

    return newColor(red, green, blue)


proc ParsePigment*(input_file: var InputStream, scene: Scene): Pigment=
    let keyword = ExpectKeywords(input_file, @[KeywordType.UNIFORM, KeywordType.CHECKERED, KeywordType.IMAGE])

    ExpectSymbol(input_file, '(')
    if keyword == KeywordType.UNIFORM:
        let color = ParseColor(input_file, scene)
        result = newUniformPigment(color)
    elif keyword == KeywordType.CHECKERED:
        let color1 = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ',')
        let color2 = ParseColor(input_file, scene)
        ExpectSymbol(input_file, ',')
        let num_of_steps = int(ExpectNumber(input_file, scene))
        result = newCheckeredPigment(color1, color2, num_of_steps)
    elif keyword == KeywordType.IMAGE:
        let file_name = ExpectString(input_file)
        let image_file = newFileStream(file_name, fmRead)
        var image: HdrImage = newHdrImage()
        image.read_pfm(image_file)
        result = newImagePigment(image)
    else:
        raise TestError.newException("This line should be unreachable")
    ExpectSymbol(input_file, ')')


proc ParseBrdf*(input_file: var InputStream, scene: Scene): BRDF=
    let brdf_keyword = ExpectKeywords(input_file, @[KeywordType.DIFFUSE, KeywordType.SPECULAR])
    ExpectSymbol(input_file, '(')
    let pigment = ParsePigment(input_file, scene)
    ExpectSymbol(input_file, ')')

    if brdf_keyword == KeywordType.DIFFUSE:
        return newDiffuseBRDF(pigment)
    elif brdf_keyword == KeywordType.SPECULAR:
        return newSpecularBRDF(pigment)
    raise TestError.newException("This line should be unreachable")


proc ParseMaterial*(input_file: var InputStream, scene: Scene): (string, Material)=
    let name = ExpectIdentifier(input_file)

    ExpectSymbol(input_file, '(')
    let brdf = ParseBrdf(input_file, scene)
    ExpectSymbol(input_file, ',')
    let emitted_radiance = ParsePigment(input_file, scene)
    ExpectSymbol(input_file, ')')

    return (name, newMaterial(brdf, emitted_radiance))


proc ParseTransformation*(input_file: var InputStream, scene: Scene): Transformation=
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


proc ParseSphere*(input_file: var InputStream, scene: Scene): Sphere=
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
    ExpectSymbol(input_file, '(')

    let material_name = ExpectIdentifier(input_file)
    if not (scene.materials.hasKey(material_name)):
        # We raise the exception here because input_file is pointing to the end of the wrong identifier
        raise TestError.newException(fmt"unknown material {material_name}")

    ExpectSymbol(input_file, ',')
    var transformation: Transformation = ParseTransformation(input_file, scene)
    ExpectSymbol(input_file, ')')

    return newPlane(transform=transformation, material=scene.materials[material_name])


proc ParseCamera*(input_file: var InputStream, scene: Scene): Camera=
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


proc ParseScene(input_file: var InputStream, variables: Table[string, float32]): Scene=
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
            raise TestError.newException(fmt"expected a keyword instead of '{what.kind}'")

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
        elif what.keywordVal == KeywordType.CAMERA:
            if not scene.camera.isNil:
                #raise GrammarError(what.location, "You cannot define more than one camera")
                raise TestError.newException(fmt"[] Cannot define more than one camera")

            scene.camera = ParseCamera(input_file, scene)
        elif what.keywordVal == KeywordType.MATERIAL:
            var name: string
            var mat: Material
            (name, mat) = ParseMaterial(input_file, scene)
            scene.materials[name] = mat
    return scene

