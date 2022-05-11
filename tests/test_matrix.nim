import "../src/RaytracingAlgorithm/transformation.nim"


var
    id: Matrix = IdentityMatrix()
    zero: Matrix = Zeros()
    ones: Matrix = Ones()
    m1: Matrix = cast[Matrix](@[
        @[float32(1.0), float32(2.0), float32(3.0), float32(0.0)],
        @[float32(2.0), float32(1.0), float32(0.0), float32(0.0)],
        @[float32(3.0), float32(0.0), float32(1.0), float32(0.0)],
        @[float32(0.0), float32(0.0), float32(0.0), float32(1.0)],
    ])

    ones_times_m1 = cast[Matrix](@[
        @[float32(6.0), float32(3.0), float32(4.0), float32(1.0)],
        @[float32(6.0), float32(3.0), float32(4.0), float32(1.0)],
        @[float32(6.0), float32(3.0), float32(4.0), float32(1.0)],
        @[float32(6.0), float32(3.0), float32(4.0), float32(1.0)],
    ])

    m1_times_ones = cast[Matrix](@[
        @[float32(6.0), float32(6.0), float32(6.0), float32(6.0)],
        @[float32(3.0), float32(3.0), float32(3.0), float32(3.0)],
        @[float32(4.0), float32(4.0), float32(4.0), float32(4.0)],
        @[float32(6.0), float32(3.0), float32(4.0), float32(1.0)],
    ])

assert (m1*id).are_matrix_close(m1)
assert (m1*zero).are_matrix_close(zero)
assert (ones*m1).are_matrix_close(ones_times_m1)
assert (m1*ones).are_matrix_close(m1_times_ones)
assert (m1*zero).are_matrix_close((m1*zero).transpose())