%builtins output pedersen range_check bitwise ec_op

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.serialize import serialize_word
from src.math_utils import ec_mul
from src.schnorr import verify_schnorr_signature
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

func main{output_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, ec_op_ptr: EcOpBuiltin*}() {
    alloc_locals;

    local message: felt;
    local blinding_factor: felt;
    local commitment: EcPoint;

    local alpha_G: EcPoint;
    local response: felt;
    local public_key: EcPoint;  

    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)

        from src.schnorrpy import SchnorrSignature
        
        secret = 12
        schnorr = SchnorrSignature()
        (alpha, response, pk) = schnorr.prove(secret)
        print("Off-chain proof sent")
        schnorr.verify(alpha, response, pk)
        print("Off-chain verification done")
        print("Assertting on-chain verification")
        print("If there is no error, on-chain verification is completed")

        ids.alpha_G.x = alpha.x
        ids.alpha_G.y = alpha.y
        ids.response = response
        ids.public_key.x = pk.x
        ids.public_key.y = pk.y
    %}

    verify_schnorr_signature(alpha_G = alpha_G, response = response, public_key = public_key);

    return ();
}