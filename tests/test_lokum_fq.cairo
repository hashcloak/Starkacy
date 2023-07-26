%builtins output range_check

from starkware.cairo.common.uint256 import SHIFT
from src.lokum.fq import fq_zero, fq_eq_zero, fq_eq_one, fq_bigint5
from src.lokum.curve import P0, P1, P2, P3, P4, BASE
from src.lokum.bigint import BigInt5, UnreducedBigInt9, bigint5_mul
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();
    local zero: BigInt5 = BigInt5(0, 0, 0, 0, 0);
    local one: BigInt5 = BigInt5(1, 0, 0, 0, 0);
    
    // Parameters for addition test
    local p_lokum: BigInt5 = BigInt5(P0, P1, P2, P3, P4);
    local p_lokum2: BigInt5 = BigInt5(P0 - 1, P1, P2, P3, P4);

    // Test for add works well
    let x = fq_bigint5.add(&p_lokum, &p_lokum2);
    // Test for sub works well
    let sub_zero_one = fq_bigint5.sub(&zero, &one);

    assert x.d0 = sub_zero_one.d0;
    assert x.d1 = sub_zero_one.d1;
    assert x.d2 = sub_zero_one.d2;
    assert x.d3 = sub_zero_one.d3;
    assert x.d4 = sub_zero_one.d4;

    // Test (p - 1) * (p - 1) = 1
    // (p-1) * (p -1) = p^2 -2p * 1 = 1
    let p_mul_p_min_1 = fq_bigint5.mul(&p_lokum2, &p_lokum2);
    let res_mul = fq_eq_one(p_mul_p_min_1);
    assert res_mul = 1;

    let res_zero = fq_bigint5.add(two, zero_min_two);
    let res0 = fq_eq_zero(res_zero);
    assert res0 = 1;

    local Xb: BigInt5 = BigInt5(1, 0, 0, 0, 0);
    local Yb: BigInt5 = BigInt5(1, 0, 0, 0, 0);

    // test add and add_unsafe together
    let xb_add_yb = fq_bigint5.add(&Xb, &Yb);
    let xb_add_unsafe_yb = fq_bigint5.add_unsafe(&Xb, &Yb);
    
    assert xb_add_yb.d0 = xb_add_unsafe_yb.d0;
    assert xb_add_yb.d1 = xb_add_unsafe_yb.d1;
    assert xb_add_yb.d2 = xb_add_unsafe_yb.d2;
    assert xb_add_yb.d3 = xb_add_unsafe_yb.d3;
    assert xb_add_yb.d4 = xb_add_unsafe_yb.d4;

    let xb_sub_yb = fq_bigint5.sub(&Xb, &Yb);
    let xb_sub_unsafe_yb = fq_bigint5.sub_unsafe(&Xb, &Yb);
    assert xb_sub_yb.d0 = xb_sub_unsafe_yb.d0;
    assert xb_sub_yb.d1 = xb_sub_unsafe_yb.d1;
    assert xb_sub_yb.d2 = xb_sub_unsafe_yb.d2;
    assert xb_sub_yb.d3 = xb_sub_unsafe_yb.d3;
    assert xb_sub_yb.d4 = xb_sub_unsafe_yb.d4;

    let xb_mul_yb = fq_bigint5.mul(&Xb, &Yb);
    let xb_mul_unsafe_yb = fq_bigint5.mul_unsafe(&Xb, &Yb);
    assert xb_mul_yb.d0 = xb_mul_unsafe_yb.d0;
    assert xb_mul_yb.d1 = xb_mul_unsafe_yb.d1;
    assert xb_mul_yb.d2 = xb_mul_unsafe_yb.d2;
    assert xb_mul_yb.d3 = xb_mul_unsafe_yb.d3;
    assert xb_mul_yb.d4 = xb_mul_unsafe_yb.d4;


    let (__fp__, _) = get_fp_and_pc();
    tempvar y = fp + 1;
    return ();
}
