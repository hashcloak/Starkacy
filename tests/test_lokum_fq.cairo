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
    //local zero: BigInt3 = BigInt3(0, 0, 0);
    //local Xb: BigInt3 = BigInt3(BASE - 2, BASE - 2, 12);
    //local Yb: BigInt3 = BigInt3(9, 10, 11);
    local zero: BigInt5 = BigInt5(0, 0, 0, 0, 0);
    local one: BigInt5 = BigInt5(1, 0, 0, 0, 0);
    //local p_lokum: BigInt5 = BigInt5(P0, P1, P2, P3, P4); // this gives an error
    //local p_lokum2: BigInt5 = BigInt5(P0 + 1, P1, P2, P3, P4); // this gives an error
    //let zero_mul_x: UnreducedBigInt9 = bigint5_mul(zero, p_lokum);
    //let zero_mul_p: UnreducedBigInt9 = bigint5_mul(p_lokum, p_lokum);
    
    // Parameters for addition test
    local p_lokum: BigInt5 = BigInt5(P0, P1, P2, P3, P4);
    local p_lokum2: BigInt5 = BigInt5(P0 - 1, P1, P2, P3, P4);

    // Test for fq_eq_zero and fq_eq_one works well
    //let res0 = fq_eq_zero(&zero);
    //let res1 = fq_eq_one(&one);
    //assert res0 = 1;
    //assert res1 = 1;

    // Test for add works well
    let x = fq_bigint5.add(&p_lokum, &p_lokum2);
    //serialize_word(x.d0);
    //serialize_word(x.d1);
    //serialize_word(x.d2);
    //serialize_word(x.d3);
    //serialize_word(x.d4);
    //

    // Test for sub works well
    let sub_zero_one = fq_bigint5.sub(&zero, &one);
    //serialize_word(sub_zero_one.d0);
    //serialize_word(sub_zero_one.d1);
    //serialize_word(sub_zero_one.d2);
    //serialize_word(sub_zero_one.d3);
    //serialize_word(sub_zero_one.d4);

    assert x.d0 = sub_zero_one.d0;
    assert x.d1 = sub_zero_one.d1;
    assert x.d2 = sub_zero_one.d2;
    assert x.d3 = sub_zero_one.d3;
    assert x.d4 = sub_zero_one.d4;

    // Test for mul zero * one
    //let sub_mul_one = fq_bigint5.mul(&zero, &one);
    //serialize_word(sub_mul_one.d0);
    //serialize_word(sub_mul_one.d1);
    //serialize_word(sub_mul_one.d2);
    //serialize_word(sub_mul_one.d3);
    //serialize_word(sub_mul_one.d4);

    // Test (p - 1) * (p - 1) = 1
    // (p-1) * (p -1) = p^2 -2p * 1 = 1
    let p_mul_p_min_1 = fq_bigint5.mul(&p_lokum2, &p_lokum2);
    let res_mul = fq_eq_one(p_mul_p_min_1);
    assert res_mul = 1;

    // Test mul_by_9
    //let one_mul_9 = fq_bigint5.mul_by_9(&one);
    //serialize_word(one_mul_9.d0);
    //serialize_word(one_mul_9.d1);
    //serialize_word(one_mul_9.d2);
    //serialize_word(one_mul_9.d3);
    //serialize_word(one_mul_9.d4);

    // Test add and mul_by_9
    //let two = fq_bigint5.add(&one, &one);
    //let two_mul_9 = fq_bigint5.mul_by_9(two);
    //serialize_word(two_mul_9.d0);
    //serialize_word(two_mul_9.d1);
    //serialize_word(two_mul_9.d2);
    //serialize_word(two_mul_9.d3);
    //serialize_word(two_mul_9.d4);

    // Test mul_by_10
    //let one_mul_10 = fq_bigint5.mul_by_10(&one);
    //serialize_word(one_mul_10.d0);
    //serialize_word(one_mul_10.d1);
    //serialize_word(one_mul_10.d2);
    //serialize_word(one_mul_10.d3);
    //serialize_word(one_mul_10.d4);

    // Test add and mul_by_9
    //let two = fq_bigint5.add(&one, &one);
    //let two_mul_10 = fq_bigint5.mul_by_10(two);
    //serialize_word(two_mul_10.d0);
    //serialize_word(two_mul_10.d1);
    //serialize_word(two_mul_10.d2);
    //serialize_word(two_mul_10.d3);
    //serialize_word(two_mul_10.d4);

    // Test neg
    //let two = fq_bigint5.add(&one, &one);
    //let zero_min_two = fq_bigint5.neg(two);
    //serialize_word(zero_min_two.d0);
    //serialize_word(zero_min_two.d1);
    //serialize_word(zero_min_two.d2);
    //serialize_word(zero_min_two.d3);
    //serialize_word(zero_min_two.d4);

    //let res_zero = fq_bigint5.add(two, zero_min_two);
    //let res0 = fq_eq_zero(res_zero);
    //assert res0 = 1;

    ////%{ value = 456 + 456*2**86 + 15*2**(86*2) %}
    ////let value = nd();

    //let inv_two = fq_bigint5.inv(two);
    //serialize_word(inv_two.d0);
    //serialize_word(inv_two.d1);
    //serialize_word(inv_two.d2);
    //serialize_word(inv_two.d3);
    //serialize_word(inv_two.d4);

    // parameters for testing
    //local Xb: BigInt5 = BigInt5(BASE - 2, BASE - 2, 12, 13, 14);
    //local Yb: BigInt5 = BigInt5(9, 10, 11, 12, 13);

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
