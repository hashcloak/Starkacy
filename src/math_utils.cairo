from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.uint256 import Uint256, uint256_le


func ec_mul{ec_op_ptr: EcOpBuiltin*}(p: EcPoint, m: felt) -> (product: EcPoint) {
    alloc_locals;
    local id_point: EcPoint = EcPoint(0, 0);
    let (r: EcPoint) = ec_op(id_point, m, p);
    return (product=r);
}

func felt_to_uint256{range_check_ptr}(x : felt) -> (x_ : Uint256){
    alloc_locals;
    let split = split_felt(x);
    local res : Uint256 = Uint256(low = split.low, high = split.high);
    return (x_ = res);
}

func uint256_to_felt(x : Uint256) -> (x_ : felt){
    alloc_locals;
    local res = x.low + x.high * 2 ** 128;
    return (x_ = res);
}



