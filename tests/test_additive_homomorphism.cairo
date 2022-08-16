%builtins output ec_op

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.serialize import serialize_word
from src.math_utils import ec_mul
from src.pedersen import commit_pedersen, PedersenCommitment

func test_additive_homomorphism{output_ptr : felt*, ec_op_ptr : EcOpBuiltin*}():
    alloc_locals

    local pedersen_commitment_1 : PedersenCommitment
    local pedersen_commitment_2 : PedersenCommitment
    local pedersen_commitment_3 : PedersenCommitment

    pedersen_commitment_1.message = 100
    pedersen_commitment_2.message = 200
    pedersen_commitment_3.message = 300

    pedersen_commitment_1.blinding_factor = 10
    pedersen_commitment_2.blinding_factor = 20
    pedersen_commitment_3.blinding_factor = 30

    let (committed_value_1) = commit_pedersen(pedersen_commitment_1)
    let (committed_value_2) = commit_pedersen(pedersen_commitment_2)
    let (committed_value_3) = commit_pedersen(pedersen_commitment_3)

    assert_on_curve(committed_value_1)
    assert_on_curve(committed_value_2)
    assert_on_curve(committed_value_3)

    let (left_hand_side) = ec_add(committed_value_1, committed_value_2)

    assert_on_curve(left_hand_side)

    assert left_hand_side.x = committed_value_3.x
    assert left_hand_side.y = committed_value_3.y
    
    serialize_word(left_hand_side.x)
    serialize_word(left_hand_side.y)
    serialize_word(committed_value_3.x)
    serialize_word(committed_value_1.y)
    
    return()
end


func main{output_ptr : felt*, ec_op_ptr : EcOpBuiltin*}():
    alloc_locals

    test_additive_homomorphism()

    return()
end