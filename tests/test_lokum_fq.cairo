%builtins output range_check

from starkware.cairo.common.uint256 import SHIFT
from src.lokum.fq import fq_zero, fq_eq_zero, fq_eq_one, fq_bigint5
from src.lokum.curve import P0, P1, P2, P3, P4
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
    serialize_word(x.d0);
    serialize_word(x.d1);
    serialize_word(x.d2);
    serialize_word(x.d3);
    serialize_word(x.d4);

    // Test for sub works well
    let sub_zero_one = fq_bigint5.sub(&zero, &one);
    serialize_word(sub_zero_one.d0);
    serialize_word(sub_zero_one.d1);
    serialize_word(sub_zero_one.d2);
    serialize_word(sub_zero_one.d3);
    serialize_word(sub_zero_one.d4);

    assert x.d0 = sub_zero_one.d0;
    assert x.d1 = sub_zero_one.d1;
    assert x.d2 = sub_zero_one.d2;
    assert x.d3 = sub_zero_one.d3;
    assert x.d4 = sub_zero_one.d4;

    //%{ value = 456 + 456*2**86 + 15*2**(86*2) %}
    //let value = nd();
    let (__fp__, _) = get_fp_and_pc();
    tempvar y = fp + 1;
    return ();
}
