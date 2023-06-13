from starkware.cairo.common.uint256 import SHIFT
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.registers import get_fp_and_pc
from src.lokum.curve import P0, P1, P2, P3, P4, N_LIMBS, N_LIMBS_UNREDUCED, DEGREE, BASE
from src.lokum.bigint import BigInt5, UnreducedBigInt5, UnreducedBigInt9, bigint5_mul

const BASE_MIN_1 = BASE - 1;
const SHIFT_MIN_BASE = SHIFT - BASE;
const SHIFT_MIN_P4 = SHIFT - P4 - 1;


func fq_zero() -> BigInt5 {
    let res = BigInt5(0, 0, 0, 0, 0);
    return res;
}

func fq_eq_zero(x: BigInt5*) -> felt {
    if (x.d0 != 0) {
        return 0;
    }
    if (x.d1 != 0) {
        return 0;
    }
    if (x.d2 != 0) {
        return 0;
    }
    if (x.d3 != 0) {
        return 0;
    }
    if (x.d4 != 0) {
        return 0;
    }
    return 1;
}

func fq_eq_one(x: BigInt5*) -> felt {
    if (x.d0 != 1) {
        return 0;
    }
    if (x.d1 != 0) {
        return 0;
    }
    if (x.d2 != 0) {
        return 0;
    }
    if (x.d3 != 0) {
        return 0;
    }
    if (x.d4 != 0) {
        return 0;
    }
    return 1;
}

namespace fq_bigint5 {
    func add{range_check_ptr}(a: BigInt5*, b: BigInt5*) -> BigInt5* {
        alloc_locals;
        local res: BigInt5;
        let (__fp__, _) = get_fp_and_pc();

        %{
            BASE = ids.BASE
            assert 1 < ids.N_LIMBS <= 12

            p, sum_limbs = 0, []
            for i in range(ids.N_LIMBS):
                p+=getattr(ids, 'P'+str(i)) * BASE**i

            p_limbs = [getattr(ids, 'P'+str(i)) for i in range(ids.N_LIMBS)]
            sum_limbs = [getattr(getattr(ids, 'a'), 'd'+str(i)) + getattr(getattr(ids, 'b'), 'd'+str(i)) for i in range(ids.N_LIMBS)]
            sum_unreduced = sum([sum_limbs[i] * BASE**i for i in range(ids.N_LIMBS)])
            sum_reduced = [sum_limbs[i] - p_limbs[i] for i in range(ids.N_LIMBS)]
            has_carry = [1 if sum_limbs[0] >= BASE else 0]
            for i in range(1,ids.N_LIMBS):
                if sum_limbs[i] + has_carry[i-1] >= BASE:
                    has_carry.append(1)
                else:
                    has_carry.append(0)
            needs_reduction = 1 if sum_unreduced >= p else 0
            has_borrow_carry_reduced = [-1 if sum_reduced[0] < 0 else (1 if sum_reduced[0]>=BASE else 0)]
            for i in range(1,ids.N_LIMBS):
                if (sum_reduced[i] + has_borrow_carry_reduced[i-1]) < 0:
                    has_borrow_carry_reduced.append(-1)
                elif (sum_reduced[i] + has_borrow_carry_reduced[i-1]) >= BASE:
                    has_borrow_carry_reduced.append(1)
                else:
                    has_borrow_carry_reduced.append(0)

            memory[ap] = needs_reduction
            for i in range(ids.N_LIMBS-1):
                if needs_reduction:
                    memory[ap+1+i] = has_borrow_carry_reduced[i]
                else:
                    memory[ap+1+i] = has_carry[i]
        %}

        ap += N_LIMBS;

        let needs_reduction = [ap - 5];
        let cb_d0 = [ap - 4];
        let cb_d1 = [ap - 3];
        let cb_d2 = [ap - 2];
        let cb_d3 = [ap - 1];

        if (needs_reduction != 0) {

            assert res.d0 = (-P0) + a.d0 + b.d0 - cb_d0 * BASE;
            assert res.d1 = (-P1) + a.d1 + b.d1 + cb_d0 - cb_d1 * BASE;
            assert res.d2 = (-P2) + a.d2 + b.d2 + cb_d1 - cb_d2 * BASE;
            assert res.d3 = (-P3) + a.d3 + b.d3 + cb_d2 - cb_d3 * BASE;
            assert res.d4 = (-P4) + a.d4 + b.d4 + cb_d3;

            assert [range_check_ptr] = BASE_MIN_1 - res.d0;
            assert [range_check_ptr + 1] = BASE_MIN_1 - res.d1;
            assert [range_check_ptr + 2] = BASE_MIN_1 - res.d2;
            assert [range_check_ptr + 3] = BASE_MIN_1 - res.d3;
            assert [range_check_ptr + 4] = P4 - res.d4;

            if (res.d4 == P4) {
                if (res.d3 == P3) {
                    if (res.d2 == P2) {
                        if (res.d1 == P1) {
                            assert [range_check_ptr + 5] = P0 - 1 - res.d0;
                            tempvar range_check_ptr = range_check_ptr + 6;
                            return &res;
                        } else {
                            assert [range_check_ptr + 5] = P1 - 1 - res.d1;
                            tempvar range_check_ptr = range_check_ptr + 6;
                            return &res;
                        }
                    } else {
                        assert [range_check_ptr + 5] = P2 - 1 - res.d2;
                        tempvar range_check_ptr = range_check_ptr + 6;
                        return &res;
                    }
                } else {
                    assert [range_check_ptr + 5] = P3 - 1 - res.d3;
                    tempvar range_check_ptr = range_check_ptr + 6;
                    return & res;
                }
            } else {
                tempvar range_check_ptr = range_check_ptr + 5;
                return &res;
            }

        } else {
            assert res.d0 = a.d0 + b.d0 - cb_d0 * BASE;
            assert res.d1 = a.d1 + b.d1 + cb_d0 - cb_d1 * BASE;
            assert res.d2 = a.d2 + b.d2 + cb_d1 - cb_d2 * BASE;
            assert res.d3 = a.d3 + b.d3 + cb_d2 - cb_d3 * BASE;
            assert res.d4 = a.d4 + b.d4 + cb_d3;

            assert [range_check_ptr] = BASE_MIN_1 + res.d0;
            assert [range_check_ptr + 1] = BASE_MIN_1 + res.d1;
            assert [range_check_ptr + 2] = BASE_MIN_1 + res.d2;
            assert [range_check_ptr + 3] = BASE_MIN_1 + res.d3;
            assert [range_check_ptr + 4] = res.d4 + (SHIFT - P4 - 1);

            if (res.d4 == P4) {
                if (res.d3 == P3) {
                    if (res.d2 == P2) {
                        if (res.d1 == P1) {
                            assert [range_check_ptr + 5] = P0 - 1 - res.d0;
                            tempvar range_check_ptr = range_check_ptr + 6;
                            return &res;
                        } else {
                            assert [range_check_ptr + 5] = P1 - 1 - res.d1;
                            tempvar range_check_ptr = range_check_ptr + 6;
                            return &res;
                        }
                    } else {
                        assert [range_check_ptr + 5] = P2 - 1 - res.d2;
                        tempvar range_check_ptr = range_check_ptr + 6;
                        return &res;
                    }
                } else {
                    assert [range_check_ptr + 5] = P3 - 1 - res.d3;
                    tempvar range_check_ptr = range_check_ptr + 6;
                    return & res;
                }
            } else {
                tempvar range_check_ptr = range_check_ptr + 5;
                return &res;
            }
        }
    }

    func sub{range_check_ptr}(a: BigInt5*, b: BigInt5*) -> BigInt5* {
        alloc_locals;
        local res: BigInt5;
        let (__fp__, _) = get_fp_and_pc();

        %{
            BASE = ids.BASE
            assert 1 < ids.N_LIMBS <= 12

            p, sub_limbs = 0, []
            for i in range(ids.N_LIMBS):
                p+=getattr(ids, 'P'+str(i)) * BASE**i

            p_limbs = [getattr(ids, 'P'+str(i)) for i in range(ids.N_LIMBS)]
            sub_limbs = [getattr(getattr(ids, 'a'), 'd'+str(i)) - getattr(getattr(ids, 'b'), 'd'+str(i)) for i in range(ids.N_LIMBS)]
            sub_unreduced = sum([sub_limbs[i] * BASE**i for i in range(ids.N_LIMBS)])
            sub_reduced = [sub_limbs[i] + p_limbs[i] for i in range(ids.N_LIMBS)]
            has_borrow = [-1 if sub_limbs[0] < 0 else 0]
            for i in range(1,ids.N_LIMBS):
                if sub_limbs[i] + has_borrow[i-1] < 0:
                    has_borrow.append(-1)
                else:
                    has_borrow.append(0)
            needs_reduction = 1 if sub_unreduced < 0 else 0
            has_borrow_carry_reduced = [-1 if sub_reduced[0] < 0 else (1 if sub_reduced[0]>=BASE else 0)]
            for i in range(1,ids.N_LIMBS):
                if (sub_reduced[i] + has_borrow_carry_reduced[i-1]) < 0:
                    has_borrow_carry_reduced.append(-1)
                elif (sub_reduced[i] + has_borrow_carry_reduced[i-1]) >= BASE:
                    has_borrow_carry_reduced.append(1)
                else:
                    has_borrow_carry_reduced.append(0)
                    
            memory[ap] = needs_reduction
            for i in range(ids.N_LIMBS-1):
                if needs_reduction:
                    memory[ap+1+i] = has_borrow_carry_reduced[i]
                else:
                    memory[ap+1+i] = has_borrow[i]
        %}

        ap += N_LIMBS;
        let needs_reduction = [ap - 5];
        let cb_d0 = [ap - 4];
        let cb_d1 = [ap - 3];
        let cb_d2 = [ap - 2];
        let cb_d3 = [ap - 1];

        if (needs_reduction != 0) {

            assert res.d0 = P0 + a.d0 - b.d0 - cb_d0 * BASE;
            assert res.d1 = P1 + a.d1 - b.d1 + cb_d0 - cb_d1 * BASE;
            assert res.d2 = P2 + a.d2 - b.d2 + cb_d1 - cb_d2 * BASE;
            assert res.d3 = P3 + a.d3 - b.d3 + cb_d2 - cb_d3 * BASE;
            assert res.d4 = P4 + a.d4 - b.d4 + cb_d3;

            assert [range_check_ptr] = res.d0 + (SHIFT_MIN_BASE);
            assert [range_check_ptr + 1] = res.d1 + (SHIFT_MIN_BASE);
            assert [range_check_ptr + 2] = res.d2 + (SHIFT_MIN_BASE);
            assert [range_check_ptr + 3] = res.d3 + (SHIFT_MIN_BASE);
            assert [range_check_ptr + 4] = res.d4 + (SHIFT_MIN_P4);

            if (res.d4 == P4) {
                if (res.d3 == P3) {
                    if (res.d2 == P2) {
                        if (res.d1 == P1) {
                            assert [range_check_ptr + 5] = P0 - 1 - res.d0;
                            tempvar range_check_ptr = range_check_ptr + 6;
                            return &res;
                        } else {
                            assert [range_check_ptr + 5] = P1 - 1 - res.d1;
                            tempvar range_check_ptr = range_check_ptr + 6;
                            return &res;
                        }
                    } else {
                        assert [range_check_ptr + 5] = P2 - 1 - res.d2;
                        tempvar range_check_ptr = range_check_ptr + 6;
                        return &res;
                    }
                } else {
                    assert [range_check_ptr + 5] = P3 - 1 - res.d3;
                    tempvar range_check_ptr = range_check_ptr + 6;
                    return & res;
                }
            } else {
                tempvar range_check_ptr = range_check_ptr + 5;
                return &res;
            }

        } else {
            assert res.d0 = a.d0 - b.d0 - cb_d0 * BASE;
            assert res.d1 = a.d1 - b.d1 + cb_d0 - cb_d1 * BASE;
            assert res.d2 = a.d2 - b.d2 + cb_d1 - cb_d2 * BASE;
            assert res.d3 = a.d3 - b.d3 + cb_d2 - cb_d3 * BASE;
            assert res.d4 = a.d4 - b.d4 + cb_d3;

            assert [range_check_ptr] = res.d0 + (SHIFT_MIN_BASE);
            assert [range_check_ptr + 1] = res.d1 + (SHIFT_MIN_BASE);
            assert [range_check_ptr + 2] = res.d2 + (SHIFT_MIN_BASE);
            assert [range_check_ptr + 3] = res.d3 + (SHIFT_MIN_BASE);
            assert [range_check_ptr + 4] = res.d4 + (SHIFT_MIN_P4);

            if (res.d4 == P4) {
                if (res.d3 == P3) {
                    if (res.d2 == P2) {
                        if (res.d1 == P1) {
                            assert [range_check_ptr + 5] = P0 - 1 - res.d0;
                            tempvar range_check_ptr = range_check_ptr + 6;
                            return &res;
                        } else {
                            assert [range_check_ptr + 5] = P1 - 1 - res.d1;
                            tempvar range_check_ptr = range_check_ptr + 6;
                            return &res;
                        }
                    } else {
                        assert [range_check_ptr + 5] = P2 - 1 - res.d2;
                        tempvar range_check_ptr = range_check_ptr + 6;
                        return &res;
                    }
                } else {
                    assert [range_check_ptr + 5] = P3 - 1 - res.d3;
                    tempvar range_check_ptr = range_check_ptr + 6;
                    return & res;
                }
            } else {
                tempvar range_check_ptr = range_check_ptr + 5;
                return &res;
            }
        }
        
    }
}