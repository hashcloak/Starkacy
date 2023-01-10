from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.uint256 import Uint256, uint256_le, uint256_unsigned_div_rem


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

func mul_mod_Q{range_check_ptr}(x : felt, y : felt) -> (res : felt) {
    alloc_locals;
    local inter = x * y;
    let (inter_256) = felt_to_uint256(inter);
    
    local Q : Uint256 = Uint256(low = 243918903305429252644362009180409056559, high = 10633823966279327296825105735305134079);
    let (_, r) = uint256_unsigned_div_rem(a = inter_256, div = Q);
    let (r_felt) = uint256_to_felt(r);
    
    return (res = r_felt);
}

func uint256_to_address_felt(x : Uint256) -> (address : felt){
    return (x.low + x.high * 2 ** 128);
}