import "../src/RaytracingAlgorithm/matrix.nim"
import "../src/RaytracingAlgorithm/geometry.nim"
import "../src/RaytracingAlgorithm/utils.nim"

proc test_matrix_operations=
    var
        id: Matrix = IdentityMatrix()
        zero: Matrix = Zeros()
        ones: Matrix = Ones()
        m1: Matrix = [
            float32(1.0), float32(2.0), float32(3.0), float32(0.0),
            float32(2.0), float32(1.0), float32(0.0), float32(0.0),
            float32(3.0), float32(0.0), float32(1.0), float32(0.0),
            float32(0.0), float32(0.0), float32(0.0), float32(1.0)
        ]

        ones_times_m1 = [
            float32(6.0), float32(3.0), float32(4.0), float32(1.0),
            float32(6.0), float32(3.0), float32(4.0), float32(1.0),
            float32(6.0), float32(3.0), float32(4.0), float32(1.0),
            float32(6.0), float32(3.0), float32(4.0), float32(1.0)
        ]

        m1_times_ones = [
            float32(6.0), float32(6.0), float32(6.0), float32(6.0),
            float32(3.0), float32(3.0), float32(3.0), float32(3.0),
            float32(4.0), float32(4.0), float32(4.0), float32(4.0),
            float32(1.0), float32(1.0), float32(1.0), float32(1.0)
        ]

    # Mul
    assert (m1*id).are_matrix_close(m1)
    assert (m1*zero).are_matrix_close(zero)
    assert (ones*m1).are_matrix_close(ones_times_m1)
    assert (m1*ones).are_matrix_close(m1_times_ones)
    assert (m1*zero).are_matrix_close((m1*zero).Transpose())
    # Sum
    assert (m1 + id).are_matrix_close(newMatrix(@[
            @[2.0.float32, 2.0, 3.0, 0.0],
            @[2.0.float32, 2.0, 0.0, 0.0],
            @[3.0.float32, 0.0, 2.0, 0.0],
            @[0.0.float32, 0.0, 0.0, 2.0]
        ]
    ))

proc test_matrix_decomposition=
    let
        m1: Matrix = [
            float32(1.0), float32(2.0), float32(3.0), float32(1.0),
            float32(2.0), float32(1.0), float32(0.0), float32(2.0),
            float32(3.0), float32(0.0), float32(1.0), float32(3.0),
            float32(0.0), float32(0.0), float32(0.0), float32(1.0)
        ]
        m1_times_ones = [
            float32(6.0), float32(6.0), float32(6.0), float32(6.0),
            float32(3.0), float32(3.0), float32(3.0), float32(3.0),
            float32(4.0), float32(4.0), float32(4.0), float32(4.0),
            float32(1.0), float32(1.0), float32(1.0), float32(1.0)
        ]

    assert ExtractTranslation(m1).isClose(newVector3(1.0, 2.0, 3.0))
    assert ExtractTranslation(m1_times_ones).isClose(newVector3(6.0, 3.0, 4.0))

proc test_determinant=
    let
        m1: Matrix = [
            float32(1.0), float32(2.0), float32(3.0), float32(1.0),
            float32(2.0), float32(1.0), float32(0.0), float32(2.0),
            float32(3.0), float32(0.0), float32(1.0), float32(3.0),
            float32(0.0), float32(0.0), float32(0.0), float32(1.0)
        ]
        m1_times_ones = [
            float32(6.0), float32(6.0), float32(6.0), float32(6.0),
            float32(3.0), float32(3.0), float32(3.0), float32(3.0),
            float32(4.0), float32(4.0), float32(4.0), float32(4.0),
            float32(1.0), float32(1.0), float32(1.0), float32(1.0)
        ]
    
    assert Determinant(m1).IsEqual(-12)
    assert Determinant(m1_times_ones).IsEqual(0.0)

proc test_inverse=
    let
        m1: Matrix = [
            float32(1.0), float32(2.0), float32(3.0), float32(1.0),
            float32(2.0), float32(1.0), float32(0.0), float32(2.0),
            float32(3.0), float32(0.0), float32(1.0), float32(3.0),
            float32(0.0), float32(0.0), float32(0.0), float32(1.0)
        ]
    
    assert Inverse(m1).are_matrix_close([
        -0.0833.float32, 0.1666, 0.25, -1,
        0.1666, 0.6666, -0.5, 0,
        0.25, -0.5, 0.25, 0,
        0,0,0,1
    ])

test_matrix_operations()
test_matrix_decomposition()
test_determinant()
test_inverse()