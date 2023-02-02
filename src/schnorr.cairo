from starkware.cairo.common.cairo_keccak.keccak import keccak_uint256s, keccak_felts, finalize_keccak
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from src.math_utils import ec_mul, felt_to_uint256, uint256_to_felt
from src.constants import BASE_POINT_X, BASE_POINT_Y
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_unsigned_div_rem
from starkware.cairo.common.serialize import serialize_word


func verify_schnorr_signature{output_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*, ec_op_ptr: EcOpBuiltin*}(alpha_G : EcPoint, response : felt, public_key : EcPoint, _challenge : felt){
    alloc_locals;

    assert_on_curve(alpha_G);

    local G: EcPoint = EcPoint(BASE_POINT_X, BASE_POINT_Y);
    assert_on_curve(G);

    // challenge needs to be hashed! So don't use this function for the privacy reason for now!
    // In other versions, hash function will be added for hashing the challenge
    //let (keccak_ptr : felt*) = alloc();
    //local keccak_ptr_start : felt* = keccak_ptr;

    //let (local keccak_inputs : felt*) = alloc();
    //assert keccak_inputs[0] = alpha_G.x;
    //assert keccak_inputs[1] = alpha_G.y;
    
    //with keccak_ptr{
    //let (hashed) = keccak_felts(2, keccak_inputs);
    //}


    // Precompiled Q, which is equal to Q = 3618502788666131213697322783095070105526743751716087489154079457884512865583 for Starkcurve.
    //local Q : Uint256 = Uint256(low = 243918903305429252644362009180409056559, high = 10633823966279327296825105735305134079);

    //let (_, r) = uint256_unsigned_div_rem(a = hashed, div = Q);

    //tempvar _challenge : felt = 1;
    

    let (R) = ec_mul(G, response);
    let (c_k) = ec_mul(public_key, _challenge);
    let (R_) = ec_add(alpha_G, c_k);

    // It doesn't give a correct result since the result of keccak_felts in Cairo doesn't match with the result of Web3.SolidityKeccak
    assert R = R_;

    //finalize_keccak(keccak_ptr_start = keccak_ptr_start, keccak_ptr_end = keccak_ptr);

    return();
}