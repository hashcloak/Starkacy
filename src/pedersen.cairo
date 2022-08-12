from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from src.math_utils import ec_mul

func pedersen_commitment{ec_op_ptr : EcOpBuiltin*}(G : EcPoint, message : felt, H : EcPoint, r : felt) -> (C : EcPoint):
    alloc_locals
    let (mG) = ec_mul(G, message)
    let (rH) = ec_mul(H, r)

    let (C) = ec_add(mG, rH)
    return(C = C)
end