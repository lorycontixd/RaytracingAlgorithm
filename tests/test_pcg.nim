import "../src/RaytracingAlgorithm/pcg.nim"

proc test_random =
    var pcg: PCG = newPCG()

    assert pcg.state == cast[uint64](1753877967969059832)
    assert pcg.inc == 109

    for expected in @[2707161783'u32, 2068313097'u32, 3122475824'u32, 2211639955'u32, 3215226955'u32, 3421331566'u32]:
        assert expected == pcg.random()

test_random()