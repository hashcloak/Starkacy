%builtins output range_check bitwise ec_op

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.serialize import serialize_word
from src.math_utils import ec_mul
from src.schnorr import verify_schnorr_signature

func main{output_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, ec_op_ptr: EcOpBuiltin*}() {
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
        
        zz = SchnorrSignature()
        # For testing purposes, challenge is taken as 1.
        # After adding a suitable hash function for both cairo and python int the future versions, schnorr prover and verifier can be used.
        (aa,ab,ac) = zz.prove(13, 1)

        ids.alpha_G.x = aa.x
        ids.alpha_G.y = aa.y
        ids.response = ab
        ids.public_key.x = ac.x
        ids.public_key.y = ac.y
    %}

    verify_schnorr_signature(alpha_G = alpha_G, response = response, public_key = public_key, _challenge = 1);

    return ();
}