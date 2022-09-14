# BASE_POINT is the generator point used in the ECDSA scheme
# https://docs.starkware.co/starkex-v4/crypto/stark-curve

# To generate BASE_BLINDING_POINT, a cryptographic random number is generated
# BASE_BLINDING_POINT is the result of elliptic curve scalar multiplication of
# "cryptographic number" and "BASE_POINT", which the operation is done as offline

# Note that the generated number is less than the order of the starkcurve:
# 3618502788666131213697322783095070105526743751716087489154079457884512865583
# The order of the elliptic curve is found thanks to:
# https://crypto.stackexchange.com/questions/95666/how-to-find-out-what-the-order-of-the-base-point-of-the-elliptic-curve-is

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from src.math_utils import ec_mul
from src.constants import BASE_POINT_X, BASE_POINT_Y, BASE_BLINDING_POINT_X, BASE_BLINDING_POINT_Y

func verify_pedersen_commitment{ec_op_ptr : EcOpBuiltin*}(message : felt, blinding_factor : felt, commitment : EcPoint):
    alloc_locals

    assert_on_curve(commitment)

    local BASE_POINT : EcPoint = EcPoint(BASE_POINT_X, BASE_POINT_Y)
    local BASE_BLINDING_POINT : EcPoint = EcPoint(BASE_BLINDING_POINT_X, BASE_BLINDING_POINT_Y)

    assert_on_curve(BASE_POINT)
    assert_on_curve(BASE_BLINDING_POINT)

    let (mG) = ec_mul(BASE_POINT, message)
    let (rH) = ec_mul(BASE_BLINDING_POINT, blinding_factor)

    assert_on_curve(mG)
    assert_on_curve(rH)

    let (committed_value) = ec_add(mG, rH)

    assert_on_curve(committed_value)

    assert committed_value = commitment

    return()
end