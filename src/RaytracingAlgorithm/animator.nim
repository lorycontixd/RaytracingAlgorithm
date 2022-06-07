import transformation, matrix, geometry, quaternion, mathutils
import std/[sequtils, tables, enumerate, algorithm, strformat, marshal]

type
    InterpolationFunction = proc(x: float32, a,b: float32): float32
    Animator* = object
        keyframes*: OrderedTable[float32, Transformation] # seq Transformation or Table[float, Transformation] ??

        translations*: OrderedTable[float32, Vector3]
        rotations*: OrderedTable[float32, Quaternion]
        scales*: OrderedTable[float32, Matrix]
        decomposed*: seq[float32] # whether the transformation at time t has been decomposed (performance)

        interpolationFunction*: InterpolationFunction

## Constructors

proc newAnimator*(initialKeyframes: var OrderedTable[float32, Transformation], f: InterpolationFunction): Animator=
    #initialKeyframes.sort(system.cmp)
    result = Animator()
    result.interpolationFunction = f
    result.keyframes = initialKeyframes
    for i, key in enumerate(initialKeyframes.keys):
        result.translations[key] = newVector3()
        result.rotations[key] = newQuaternion()
        result.scales[key] = Zeros()
        Decompose(initialKeyframes[key].m, result.translations[key], result.rotations[key], result.scales[key])
        result.decomposed.add(key)

## -- Methods
proc AddKeyframe*(self: var Animator, time: float32, t: Transformation): void =
    self.keyframes[time] = t
    self.translations[time] = newVector3()
    self.rotations[time] = newQuaternion()
    self.scales[time] = Zeros()
    Decompose(self.keyframes[time].m, self.translations[time], self.rotations[time], self.scales[time])
    self.decomposed.add(time)
    #self.keyframes.sort(system.cmp)

proc DecomposeAll*(self: var Animator): void=
    for i, key in enumerate(self.keyframes.keys):
        Decompose(self.keyframes[key].m, self.translations[key], self.rotations[key], self.scales[key])
        if not (self.decomposed.contains(key)):
            self.decomposed.add(key)
    self.decomposed.sort(cmp)

proc Decompose*(self: var Animator): void=
    for i, key in enumerate(self.keyframes.keys):
        if not (self.decomposed.contains(key)):
            Decompose(self.keyframes[key].m, self.translations[key], self.rotations[key], self.scales[key])
    self.decomposed.sort(cmp)

func FindIndexByKey*(self: Animator, key: float32): int=
    for i,k in enumerate(self.keyframes.keys):
        if k == key:
            return i
    raise ValueError.newException("Key not found")

proc FindKeyByIndex*(self: Animator, index: int): float32=
    for i,k in enumerate(self.keyframes.keys):
        if i==index:
            return k
    raise ValueError.newException("Index not in keyframes range")

proc FindLastKey*(self: Animator): float32=
    return self.FindKeyByIndex(len(self.keyframes)-1)

proc GetPreviousKey*(self: Animator, t: float32): float32=
    for i, key in enumerate(self.keyframes.keys):
        if t < key:
            return self.FindKeyByIndex(i-1)

proc GetPreviousKeyframe*(self: Animator, t: float32): Transformation=
    for i, key in enumerate(self.keyframes.keys):
        if t < key:
            return self.keyframes[self.FindKeyByIndex(i-1)]

func GetNextKey*(self: Animator, t: float32): float32=
    for i, key in enumerate(self.keyframes.keys):
        if t < key:
            return key

proc GetNextKeyframe*(self: Animator, t: float32): Transformation=
    for i, key in enumerate(self.keyframes.keys):
        if t < key:
            return self.keyframes[self.FindKeyByIndex(i)]

proc Interpolate*(self: var Animator, a,b: float32, dt: var float32, debug: bool = false): Transformation {.inline.}=
    var
        transA: Vector3 = self.translations[a]
        transB: Vector3 = self.translations[b]
        rotA: Quaternion = self.rotations[a]
        rotB: Quaternion = self.rotations[b]
        scaleA: Matrix = self.scales[a]
        scaleB: Matrix = self.scales[b]

    # Interpolate translation at _dt_
    var trans: Vector3 = (1.0 - dt) * transA + dt * transB
    if debug:
        echo "Translation:"
        echo $trans,"\n"
    # Interpolate rotation at _dt_
    var rotate: Quaternion = Slerp(rotA, rotB, dt)
    if debug:
        echo "Rotation:"
        echo $rotate,"\n"
        echo "\n"
    # Interpolate scale at _dt_
    var scale: Matrix = Zeros()
    for i in countup(0,3):
        for j in countup(0,3):
            scale[i,j] = Lerp(scaleA[i,j], scaleB[i,j], dt)
    if debug:
        echo "Scale:"
        scale.Show()
        echo "\n"
    let
        transTranform = Transformation.translation(trans)
        rotTransform = newTransformation(rotate.ToRotation())
        scaleTransform = newTransformation(scale)
    # Compute interpolated matrix as product of interpolated components
    return rotTransform * transTranform * scaleTransform

func RemoveKeyframe*(self: var Animator, index: int): void=
    for i,key in enumerate(self.keyframes.keys):
        if i == index:
            self.keyframes.del(key)
    
func RemoveKeyframe*(self: var Animator, time: float32): void=
    self.keyframes.del(time)

func SetInterpolationFunction*(self: var Animator, f: InterpolationFunction): void=
    self.interpolationFunction = f

proc Play*(self: var Animator, t: float32): Transformation =
    let
        firstkey = self.FindKeyByIndex(0)
        lastkey = self.FindLastKey()
    if t <= firstkey:
        return self.keyframes[firstkey]
    if t >= lastkey:
        return self.keyframes[lastkey]
    #echo self.keyframes
    var
        a: float32 = self.GetPreviousKey(t)
        b: float32 = self.GetNextKey(t)
    var dt: float32 = (t-a)/(b-a)
    #echo "t: ",t,"\ta: ",a,"\tb: ",b
    var f_dt: float32 = self.interpolationFunction(dt, 1.0, 1.0)
    return self.Interpolate(a, b, f_dt)
    


