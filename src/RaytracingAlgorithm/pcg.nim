import std/[bitops, math]

type
    PCG* = object
        state*: uint64
        inc*: uint64



proc random*(self: var PCG): uint32=
    let oldstate = self.state
    self.state = cast[uint64]( oldstate * 6364136223846793005'u64 + self.inc)
    let xorshifted = cast[uint32]( ((oldstate shr 18) xor oldstate ) shr 27 )
    let rot = oldstate shr 59 # uint64
    
    let
        a1 = xorshifted shr rot
    var rot_term: int = 0 - cast[int](rot)
    let
        rot_term2 = rot_term.bitand(31)
        a2 = xorshifted shl rot_term2
        a3 = bitor(a1, a2)
        final = cast[uint32](a3)
    return final

proc newPCG*(init_state: uint64 = 42, init_seq: uint64 = 54): PCG=
    result = PCG(state: 0)
    result.inc = (init_seq shl 1).bitor(1)
    discard result.random()
    result.state += init_state
    discard result.random()

proc random_float*(self: var PCG): float32=
    var num: uint32 = cast[uint32](self.random())
    var den: float32 = pow(2.0, 32.0) - 1
    return num.float32 / den
    

