import transformation, shape
import std/[sequtils]

type
    Animator* = object
        obj*: Shape
        keyframes*: seq[Transformation] # seq Transformation or Table[float, Transformation] ??

## Constructors
func newAnimator*(obj: Shape): Animator=
    return Animator(obj: obj)

func newAnimator*(obj: Shape, initialKeyframes: seq[Transformation]): Animator=
    return Animator(obj: obj, keyframes: initialKeyframes)

## Methods
func AddKeyframe*(self: var Animator, t: Transformation, index: int): void =
    self.keyframes.insert(t, index)

func AppendKeyframe*(self: var Animator, t: Transformation): void=
    self.keyframes.add(t)

func RemoveKeyframe*(self: var Animator, index: int): void=
    self.keyframes.delete(index..index)

func RemoveKeyframes*(self: var Animator, slice: Slice[int]): void=
    self.keyframes.delete(slice)

func Play*(): void = discard

