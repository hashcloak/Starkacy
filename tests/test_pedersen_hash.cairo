%builtins output pedersen 

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.serialize import serialize_word
from src.math_utils import ec_mul
from src.pedersen_commitment_verifier import verify_pedersen_commitment
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from src.constants import BASE_POINT_X, BASE_POINT_Y, BASE_BLINDING_POINT_X, BASE_BLINDING_POINT_Y


func main{output_ptr: felt*, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    serialize_word(2);
    let x: felt = BASE_POINT_X;
    let y: felt = BASE_POINT_Y;
    let (res) = hash2{hash_ptr=pedersen_ptr}(x, y);
    tempvar a: felt;
    
    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)

        from src.fast_pedersen_starkware import *
        #from src.schnorr import SchnorrSignature
        base1 = ids.x
        base2 = ids.y

        resulting = pedersen_hash(base1, base2)
        ids.a = resulting
    %}

    assert a = res;
    
    serialize_word(a);
    serialize_word(res);
    return();
}



