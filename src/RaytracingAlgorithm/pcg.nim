import std/[bitops, math]

type
    PCG* = object #class to generate pseudo-random numbers, 32 bit with period 2^32 -1
        state*: uint64
        inc*: uint64



proc random*(self: var PCG): uint32=
    ## Returns a random number (between 0 and 2^32 -1) and updates PCG internal state
    ## Parameters
    ##      self (PCG)
    ## Returns
    ##      final (uint32): random number
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
    ## Constructor for PCG
    ## Parameters
    ##      init_state (uint64) : Default_value = 42
    ##      init_seq (uint64) : Default_value = 54
    ## Returns
    ##      (PCG)
    result = PCG(state: 0)
    result.inc = (init_seq shl 1).bitor(1)
    discard result.random() #throw a random number and discard it
    result.state += init_state
    discard result.random() #throw a random number and discard it

proc random_float*(self: var PCG): float32=
    ## Returns a random number uniformly distributed between 0 and 1 and updates PCG internal state
    ## Parameters
    ##      self (PCG)
    ## Returns
    ##      (float32): random number
    var num: uint32 = cast[uint32](self.random())
    var den: float32 = pow(2.0, 32.0) - 1
    return num.float32 / den
    

