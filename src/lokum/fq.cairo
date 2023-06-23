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

    func mul{range_check_ptr}(a: BigInt5*, b: BigInt5*) -> BigInt5* {
        alloc_locals;
        let (__fp__, _) = get_fp_and_pc();

        local q: BigInt5;
        local r: BigInt5;
        local flag0: felt;
        local flag1: felt;
        local flag2: felt;
        local flag3: felt;
        local flag4: felt;
        local flag5: felt;
        local flag6: felt;
        local flag7: felt;
        local q0: felt;
        local q1: felt;
        local q2: felt;
        local q3: felt;
        local q4: felt;
        local q5: felt;
        local q6: felt;
        local q7: felt;

        %{
            from starkware.cairo.common.math_utils import as_int
            assert 1 < ids.N_LIMBS <= 12
            assert ids.DEGREE == ids.N_LIMBS-1
            a,b,p=0,0,0
            a_limbs, b_limbs, p_limbs = ids.N_LIMBS*[0], ids.N_LIMBS*[0], ids.N_LIMBS*[0]
            def split(x, degree=ids.DEGREE, base=ids.BASE):
                coeffs = []
                for n in range(degree, 0, -1):
                    q, r = divmod(x, base ** n)
                    coeffs.append(q)
                    x = r
                coeffs.append(x)
                return coeffs[::-1]

            def poly_mul(a:list, b:list,n=ids.N_LIMBS) -> list:
                assert len(a) == len(b) == n
                result = [0] * ids.N_LIMBS_UNREDUCED
                for i in range(n):
                    for j in range(n):
                        result[i+j] += a[i]*b[j]
                return result
            def poly_mul_plus_c(a:list, b:list, c:list, n=ids.N_LIMBS) -> list:
                assert len(a) == len(b) == n
                result = [0] * ids.N_LIMBS_UNREDUCED
                for i in range(n):
                    for j in range(n):
                        result[i+j] += a[i]*b[j]
                for i in range(n):
                    result[i] += c[i]
                return result
            def poly_sub(a:list, b:list, n=ids.N_LIMBS_UNREDUCED) -> list:
                assert len(a) == len(b) == n
                result = [0] * n
                for i in range(n):
                    result[i] = a[i] - b[i]
                return result

            def abs_poly(x:list):
                result = [0] * len(x)
                for i in range(len(x)):
                    result[i] = abs(x[i])
                return result

            def reduce_zero_poly(x:list):
                x = x.copy()
                carries = [0] * (len(x)-1)
                for i in range(0, len(x)-1):
                    carries[i] = x[i] // ids.BASE
                    x[i] = x[i] % ids.BASE
                    assert x[i] == 0
                    x[i+1] += carries[i]
                assert x[-1] == 0
                return x, carries

            for i in range(ids.N_LIMBS):
                a+=as_int(getattr(ids.a, 'd'+str(i)),PRIME) * ids.BASE**i
                b+=as_int(getattr(ids.b, 'd'+str(i)),PRIME) * ids.BASE**i
                p+=getattr(ids, 'P'+str(i)) * ids.BASE**i
                a_limbs[i]=as_int(getattr(ids.a, 'd'+str(i)),PRIME)
                b_limbs[i]=as_int(getattr(ids.b, 'd'+str(i)),PRIME)
                p_limbs[i]=getattr(ids, 'P'+str(i))

            mul = a*b
            q, r = divmod(mul, p)
            qs, rs = split(q), split(r)
            for i in range(ids.N_LIMBS):
                setattr(ids.r, 'd'+str(i), rs[i])
                setattr(ids.q, 'd'+str(i), qs[i])

            val_limbs = poly_mul(a_limbs, b_limbs)
            q_P_plus_r_limbs = poly_mul_plus_c(qs, p_limbs, rs)
            diff_limbs = poly_sub(q_P_plus_r_limbs, val_limbs)
            _, carries = reduce_zero_poly(diff_limbs)
            carries = abs_poly(carries)
            for i in range(ids.N_LIMBS_UNREDUCED-1):
                setattr(ids, 'flag'+str(i), 1 if diff_limbs[i] >= 0 else 0)
                setattr(ids, 'q'+str(i), carries[i])
        %}

        assert [range_check_ptr + 0] = q0;
        assert [range_check_ptr + 1] = q1;
        assert [range_check_ptr + 2] = q2;
        assert [range_check_ptr + 3] = q3;
        assert [range_check_ptr + 4] = q4;
        assert [range_check_ptr + 5] = q5;
        assert [range_check_ptr + 6] = q6;
        assert [range_check_ptr + 7] = q7;

        assert [range_check_ptr + 8] = BASE_MIN_1 - r.d0;
        assert [range_check_ptr + 9] = BASE_MIN_1 - r.d1;
        assert [range_check_ptr + 10] = BASE_MIN_1 - r.d2;
        assert [range_check_ptr + 11] = BASE_MIN_1 - r.d3;
        assert [range_check_ptr + 12] = P4 - r.d4;

        assert [range_check_ptr + 13] = BASE_MIN_1 - q.d0;
        assert [range_check_ptr + 14] = BASE_MIN_1 - q.d1;
        assert [range_check_ptr + 15] = BASE_MIN_1 - q.d2;
        assert [range_check_ptr + 16] = BASE_MIN_1 - q.d3;
        assert [range_check_ptr + 17] = P4 - q.d4;

        tempvar diff_d0 = q.d0 * P0 + r.d0 - a.d0 * b.d0;
        tempvar diff_d1 = q.d0 * P1 + q.d1 * P0 + r.d1 - a.d0 * b.d1 - a.d1 * b.d0;
        tempvar diff_d2 = q.d0 * P2 + q.d1 * P1 + q.d2 * P0 + r.d2 - a.d0 * b.d2 - a.d1 * b.d1 - a.d2 * b.d0;
        tempvar diff_d3 = q.d0 * P3 + q.d1 * P2 + q.d2 * P1 + q.d3 * P0 + r.d3 - a.d0 * b.d3 - a.d1 * b.d2 - a.d2 * b.d1 - a.d3 * b.d0;
        tempvar diff_d4 = q.d0 * P4 + q.d1 * P3 + q.d2 * P2 + q.d3 * P1 + q.d4 * P0 + r.d4 - a.d0 * b.d4 - a.d1 * b.d3 - a.d2 * b.d2 - a.d3 * b.d1 - a.d4 * b.d0;
        tempvar diff_d5 = q.d1 * P4 + q.d2 * P3 + q.d3 * P2 + q.d4 * P1 - a.d1 * b.d4 - a.d2 * b.d3 - a.d3 * b.d2 - a.d4 * b.d1;
        tempvar diff_d6 = q.d2 * P4 + q.d3 * P3 + q.d4 * P2 - a.d2 * b.d4 - a.d3 * b.d3 - a.d4 * b.d2;
        tempvar diff_d7 = q.d3 * P4 + q.d4 * P3 - a.d4 * b.d3 - a.d3 * b.d4;
        tempvar diff_d8 = q.d4 * P4 - a.d4 * b.d4;

        local carry0: felt;
        local carry1: felt;
        local carry2: felt;
        local carry3: felt;
        local carry4: felt;
        local carry5: felt;
        local carry6: felt;
        local carry7: felt;

        if (flag0 != 0) {
            assert diff_d0 = q0 * BASE;
            assert carry0 = q0;
        } else {
            assert carry0 = (-1) * q0;
            assert diff_d0 = carry0 * BASE;
        }

        if (flag1 != 0) {
            assert diff_d1 + carry0 = q1 * BASE;
            assert carry1 = q1;
        } else {
            assert carry1 = (-1) * q1;
            assert diff_d1 + carry0 = carry1 * BASE;
        }

        if (flag2 != 0) {
            assert diff_d2 + carry1 = q2 * BASE;
            assert carry2 = q2;
        } else {
            assert carry2 = (-1) * q2;
            assert diff_d2 + carry1 = carry2 * BASE;
        }

        if (flag3 != 0) {
            assert diff_d3 + carry2 = q3 * BASE;
            assert carry3 = q3;
        } else {
            assert carry3 = (-1) * q3;
            assert diff_d3 + carry2 = carry3 * BASE;
        }

        if (flag4 != 0) {
            assert diff_d4 + carry3 = q4 * BASE;
            assert carry4 = q4;
        } else {
            assert carry4 = (-1) * q4;
            assert diff_d4 + carry3 = carry4 * BASE;
        }

        if (flag5 != 0) {
            assert diff_d5 + carry4 = q5 * BASE;
            assert carry5 = q5;
        } else {
            assert carry5 = (-1) * q5;
            assert diff_d5 + carry4 = carry5 * BASE;
        }

        if (flag6 != 0) {
            assert diff_d6 + carry5 =q6 * BASE;
            assert carry6 = q6;
        } else {
            assert carry6 = (-1) * q6;
            assert diff_d6 + carry5 = carry6 * BASE;
        }

        if (flag7 != 0) {
            assert diff_d7 + carry6 =q7 * BASE;
            assert carry7 = q7;
        } else {
            assert carry7 = (-1) * q7;
            assert diff_d7 + carry6 = carry7 * BASE;
        }

        assert diff_d8 + carry7 = 0;
        tempvar range_check_ptr = range_check_ptr + 18;
        return &r;
    }

    func mul_by_9{range_check_ptr}(a: BigInt5*) -> BigInt5* {
        alloc_locals;
        let (__fp__, _) = get_fp_and_pc();

        local r: BigInt5;
        local q: felt;
        local flag0: felt;
        local flag1: felt;
        local flag2: felt;
        local flag3: felt;
        local q0: felt;
        local q1: felt;
        local q2: felt;
        local q3: felt;

        %{
            from starkware.cairo.common.math_utils import as_int
            assert 1 < ids.N_LIMBS <= 12
            assert ids.DEGREE == ids.N_LIMBS-1
            a,p=0,0
            a_limbs, p_limbs = ids.N_LIMBS*[0], ids.N_LIMBS*[0]
            def split(x, degree=ids.DEGREE, base=ids.BASE):
                coeffs = []
                for n in range(degree, 0, -1):
                    q, r = divmod(x, base ** n)
                    coeffs.append(q)
                    x = r
                coeffs.append(x)
                return coeffs[::-1]

            def poly_sub(a:list, b:list, n=ids.N_LIMBS_UNREDUCED) -> list:
                assert len(a) == len(b) == n
                result = [0] * n
                for i in range(n):
                    result[i] = a[i] - b[i]
                return result

            def abs_poly(x:list):
                result = [0] * len(x)
                for i in range(len(x)):
                    result[i] = abs(x[i])
                return result

            def reduce_zero_poly(x:list):
                x = x.copy()
                carries = [0] * (len(x)-1)
                for i in range(0, len(x)-1):
                    carries[i] = x[i] // ids.BASE
                    x[i] = x[i] % ids.BASE
                    assert x[i] == 0
                    x[i+1] += carries[i]
                assert x[-1] == 0
                return x, carries

            for i in range(ids.N_LIMBS):
                a+=as_int(getattr(ids.a, 'd'+str(i)),PRIME) * ids.BASE**i
                p+=getattr(ids, 'P'+str(i)) * ids.BASE**i
                a_limbs[i]=as_int(getattr(ids.a, 'd'+str(i)),PRIME)
                p_limbs[i]=getattr(ids, 'P'+str(i))

            mul = a*9
            q, r = divmod(mul, p)
            rs = split(r)
            for i in range(ids.N_LIMBS):
                setattr(ids.r, 'd'+str(i), rs[i])
            ids.q=q

            val_limbs = [a_limbs[i] * 9 for i in range(ids.N_LIMBS)]
            q_P_plus_r_limbs = [q * p_limbs[i] + rs[i] for i in range(ids.N_LIMBS)]

            diff_limbs = poly_sub(q_P_plus_r_limbs, val_limbs, ids.N_LIMBS)
            _, carries = reduce_zero_poly(diff_limbs)
            carries = abs_poly(carries)
            for i in range(ids.N_LIMBS-1):
                setattr(ids, 'flag'+str(i), 1 if diff_limbs[i] >= 0 else 0)
                setattr(ids, 'q'+str(i), carries[i])
        %}

        assert [range_check_ptr + 0] = q0;
        assert [range_check_ptr + 1] = q1;
        assert [range_check_ptr + 2] = q2;
        assert [range_check_ptr + 3] = q3;
        assert [range_check_ptr + 4] = q;

        tempvar diff_d0 = q * P0 + r.d0 - a.d0 * 9;
        tempvar diff_d1 = q * P1 + r.d1 - a.d1 * 9;
        tempvar diff_d2 = q * P2 + r.d2 - a.d2 * 9;
        tempvar diff_d3 = q * P3 + r.d3 - a.d3 * 9;
        tempvar diff_d4 = q * P4 + r.d4 - a.d4 * 9;

        local carry0: felt;
        local carry1: felt;
        local carry2: felt;
        local carry3: felt;

        if (flag0 != 0) {
            assert diff_d0 = q0 * BASE;
            assert carry0 = q0;
        } else {
            assert carry0 = (-1) * q0;
            assert diff_d0 = carry0 * BASE;
        }

        if (flag1 != 0) {
            assert diff_d1 + carry0 = q1 * BASE;
            assert carry1 = q1;
        } else {
            assert carry1 = (-1) * q1;
            assert diff_d1 + carry0 = carry1 * BASE;
        }

        if (flag2 != 0) {
            assert diff_d2 + carry1 = q2 * BASE;
            assert carry2 = q2;
        } else {
            assert carry2 = (-1) * q2;
            assert diff_d2 + carry1 = carry2 * BASE;
        }

        if (flag3 != 0) {
            assert diff_d3 + carry2 = q3 * BASE;
            assert carry3 = q3;
        } else {
            assert carry3 = (-1) * q3;
            assert diff_d3 + carry2 = carry3 * BASE;
        }

        assert diff_d4 + carry3 = 0;
        tempvar range_check_ptr = range_check_ptr + 5;
        return &r;
    }

    func mul_by_10{range_check_ptr}(a: BigInt5*) -> BigInt5* {
        alloc_locals;
        let (__fp__, _) = get_fp_and_pc();

        local r: BigInt5;
        local q: felt;
        local flag0: felt;
        local flag1: felt;
        local flag2: felt;
        local flag3: felt;
        local q0: felt;
        local q1: felt;
        local q2: felt;
        local q3: felt;

        %{
            from starkware.cairo.common.math_utils import as_int
            assert 1 < ids.N_LIMBS <= 12
            assert ids.DEGREE == ids.N_LIMBS-1
            a,p=0,0
            a_limbs, p_limbs = ids.N_LIMBS*[0], ids.N_LIMBS*[0]
            def split(x, degree=ids.DEGREE, base=ids.BASE):
                coeffs = []
                for n in range(degree, 0, -1):
                    q, r = divmod(x, base ** n)
                    coeffs.append(q)
                    x = r
                coeffs.append(x)
                return coeffs[::-1]

            def poly_sub(a:list, b:list, n=ids.N_LIMBS_UNREDUCED) -> list:
                assert len(a) == len(b) == n
                result = [0] * n
                for i in range(n):
                    result[i] = a[i] - b[i]
                return result

            def abs_poly(x:list):
                result = [0] * len(x)
                for i in range(len(x)):
                    result[i] = abs(x[i])
                return result

            def reduce_zero_poly(x:list):
                x = x.copy()
                carries = [0] * (len(x)-1)
                for i in range(0, len(x)-1):
                    carries[i] = x[i] // ids.BASE
                    x[i] = x[i] % ids.BASE
                    assert x[i] == 0
                    x[i+1] += carries[i]
                assert x[-1] == 0
                return x, carries

            for i in range(ids.N_LIMBS):
                a+=as_int(getattr(ids.a, 'd'+str(i)),PRIME) * ids.BASE**i
                p+=getattr(ids, 'P'+str(i)) * ids.BASE**i
                a_limbs[i]=as_int(getattr(ids.a, 'd'+str(i)),PRIME)
                p_limbs[i]=getattr(ids, 'P'+str(i))

            mul = a*10
            q, r = divmod(mul, p)
            rs = split(r)
            for i in range(ids.N_LIMBS):
                setattr(ids.r, 'd'+str(i), rs[i])
            ids.q=q

            val_limbs = [a_limbs[i] * 10 for i in range(ids.N_LIMBS)]
            q_P_plus_r_limbs = [q * p_limbs[i] + rs[i] for i in range(ids.N_LIMBS)]

            diff_limbs = poly_sub(q_P_plus_r_limbs, val_limbs, ids.N_LIMBS)
            _, carries = reduce_zero_poly(diff_limbs)
            carries = abs_poly(carries)
            for i in range(ids.N_LIMBS-1):
                setattr(ids, 'flag'+str(i), 1 if diff_limbs[i] >= 0 else 0)
                setattr(ids, 'q'+str(i), carries[i])
        %}

        assert [range_check_ptr + 0] = q0;
        assert [range_check_ptr + 1] = q1;
        assert [range_check_ptr + 2] = q2;
        assert [range_check_ptr + 3] = q3;
        assert [range_check_ptr + 4] = q;

        tempvar diff_d0 = q * P0 + r.d0 - a.d0 * 10;
        tempvar diff_d1 = q * P1 + r.d1 - a.d1 * 10;
        tempvar diff_d2 = q * P2 + r.d2 - a.d2 * 10;
        tempvar diff_d3 = q * P3 + r.d3 - a.d3 * 10;
        tempvar diff_d4 = q * P4 + r.d4 - a.d4 * 10;

        local carry0: felt;
        local carry1: felt;
        local carry2: felt;
        local carry3: felt;

        if (flag0 != 0) {
            assert diff_d0 = q0 * BASE;
            assert carry0 = q0;
        } else {
            assert carry0 = (-1) * q0;
            assert diff_d0 = carry0 * BASE;
        }

        if (flag1 != 0) {
            assert diff_d1 + carry0 = q1 * BASE;
            assert carry1 = q1;
        } else {
            assert carry1 = (-1) * q1;
            assert diff_d1 + carry0 = carry1 * BASE;
        }

        if (flag2 != 0) {
            assert diff_d2 + carry1 = q2 * BASE;
            assert carry2 = q2;
        } else {
            assert carry2 = (-1) * q2;
            assert diff_d2 + carry1 = carry2 * BASE;
        }

        if (flag3 != 0) {
            assert diff_d3 + carry2 = q3 * BASE;
            assert carry3 = q3;
        } else {
            assert carry3 = (-1) * q3;
            assert diff_d3 + carry2 = carry3 * BASE;
        }

        assert diff_d4 + carry3 = 0;
        tempvar range_check_ptr = range_check_ptr + 5;
        return &r;
    }

    func neg{range_check_ptr}(a: BigInt5*) -> BigInt5* {
        alloc_locals;
        tempvar zero: BigInt5* = new BigInt5(0, 0, 0, 0, 0);
        return sub(zero, a);
    }

    func inv{range_check_ptr}(a: BigInt5*) -> BigInt5* {
        alloc_locals;
        let (__fp__, _) = get_fp_and_pc();
        local inv: BigInt5;

        %{
            from starkware.cairo.common.math_utils import as_int    
            assert 1 < ids.N_LIMBS <= 12
            assert ids.DEGREE == ids.N_LIMBS-1
            a,p=0,0

            def split(x, degree=ids.DEGREE, base=ids.BASE):
                coeffs = []
                for n in range(degree, 0, -1):
                    q, r = divmod(x, base ** n)
                    coeffs.append(q)
                    x = r
                coeffs.append(x)
                return coeffs[::-1]

            for i in range(ids.N_LIMBS):
                a+=as_int(getattr(ids.a, 'd'+str(i)), PRIME) * ids.BASE**i
                p+=getattr(ids, 'P'+str(i)) * ids.BASE**i

            inv = pow(a, -1, p)
            invs = split(inv)
            for i in range(ids.N_LIMBS):
                setattr(ids.inv, 'd'+str(i), invs[i])
        %}

        assert [range_check_ptr] = inv.d0 + (SHIFT_MIN_BASE);
        assert [range_check_ptr + 1] = inv.d1 + (SHIFT_MIN_BASE);
        assert [range_check_ptr + 2] = inv.d2 + (SHIFT_MIN_BASE);
        assert [range_check_ptr + 3] = inv.d3 + (SHIFT_MIN_BASE);
        assert [range_check_ptr + 4] = inv.d4 + (SHIFT_MIN_P4);

        tempvar range_check_ptr = range_check_ptr + 5;

        let res_inv = mul(a, &inv);

        assert res_inv.d0 = 1;
        assert res_inv.d1 = 0;
        assert res_inv.d2 = 0;
        assert res_inv.d3 = 0;
        assert res_inv.d4 = 0;

        return &inv;
    }

    func add_unsafe{range_check_ptr}(a: BigInt5*, b: BigInt5*) -> BigInt5* {
        alloc_locals;
        local add_mod_p: BigInt5*;

        %{
            
            def split(x, degree=ids.DEGREE, base=ids.BASE):
                coeffs = []
                for n in range(degree, 0, -1):
                    q, r = divmod(x, base ** n)
                    coeffs.append(q)
                    x = r
                coeffs.append(x)
                return coeffs[::-1]

            def pack(z, prime):
                limbs = z.d0, z.d1, z.d2, z.d3, z.d4
                return sum(as_int(limb, prime) * (BASE**i) for i, limb in enumerate(limbs))

            p = 570227033427643938477351787526785557771164366858588273239167105706995178753794255646220989581954976296644199541099698255998850583874501725806067165976078609861
            a = pack(ids.a, p)
            b = pack(ids.b, p)
            add_mod_p = value = (a+b)%p
            
            ids.add_mod_p = segments.gen_arg(split(add_mod_p, degree = 4, base = 2**106))
        %}

        return add_mod_p;
    }

    func sub_unsafe{range_check_ptr}(a: BigInt5*, b:BigInt5*) -> BigInt5* {
        alloc_locals;
        local sub_mod_p: BigInt5*;

        %{
            def split(x, degree=ids.DEGREE, base=ids.BASE):
                coeffs = []
                for n in range(degree, 0, -1):
                    q, r = divmod(x, base ** n)
                    coeffs.append(q)
                    x = r
                coeffs.append(x)
                return coeffs[::-1]

            def pack(z, prime):
                limbs = z.d0, z.d1, z.d2, z.d3, z.d4
                return sum(as_int(limb, prime) * (BASE**i) for i, limb in enumerate(limbs))

            p = 570227033427643938477351787526785557771164366858588273239167105706995178753794255646220989581954976296644199541099698255998850583874501725806067165976078609861
            a = pack(ids.a, p)
            b = pack(ids.b, p)
            sub_mod_p = value = (a-b)%p

            ids.sub_mod_p = segments.gen_arg(split(sub_mod_p, degree = 4, base = 2**106))
        %}
        return sub_mod_p;
    }

    func mul_unsafe{range_check_ptr}(a: BigInt5*, b: BigInt5*) -> BigInt5* {
        alloc_locals;
        local result: BigInt5*;
        %{
            def split(x, degree=ids.DEGREE, base=ids.BASE):
                coeffs = []
                for n in range(degree, 0, -1):
                    q, r = divmod(x, base ** n)
                    coeffs.append(q)
                    x = r
                coeffs.append(x)
                return coeffs[::-1]

            def pack(z, prime):
                limbs = z.d0, z.d1, z.d2, z.d3, z.d4
                return sum(as_int(limb, prime) * (BASE**i) for i, limb in enumerate(limbs))

            p = 570227033427643938477351787526785557771164366858588273239167105706995178753794255646220989581954976296644199541099698255998850583874501725806067165976078609861
            mul = (ids.a.d0 + ids.a.d1*2**106 + ids.a.d2*2**(106*2) + ids.a.d3*2**(106*3) + ids.a.d4*2**(106*4)) * (ids.b.d0 + ids.b.d1*2**106 + ids.b.d2*2**(106*2) + ids.b.d3*2**(106*3) + ids.b.d4*2**(106*4))
            value = mul%p

            ids.result = segments.gen_arg(split(value, degree = 4, base = 2**106))
        %}

        return result;
    }
}

func verify_zero5{range_check_ptr}(val: BigInt5) {
    alloc_locals;
    local q: felt;
    local flag0: felt;
    local flag1: felt;
    local flag2: felt;
    local flag3: felt;
    local q0: felt;
    local q1: felt;
    local q2: felt;
    local q3: felt;

    %{
        from starkware.cairo.common.math_utils import as_int
        assert 1 < ids.N_LIMBS <= 12
        assert ids.DEGREE == ids.N_LIMBS-1
        val, p=0,0
        val_limbs, p_limbs = ids.N_LIMBS_UNREDUCED*[0], ids.N_LIMBS*[0]
        def split(x, degree=ids.DEGREE, base=ids.BASE):
            coeffs = []
            for n in range(degree, 0, -1):
                q, r = divmod(x, base ** n)
                coeffs.append(q)
                x = r
            coeffs.append(x)
            return coeffs[::-1]

        def poly_sub(a:list, b:list, n=ids.N_LIMBS_UNREDUCED) -> list:
            assert len(a) == len(b) == n
            result = [0] * n
            for i in range(n):
                result[i] = a[i] - b[i]
            return result

        def abs_poly(x:list):
            result = [0] * len(x)
            for i in range(len(x)):
                result[i] = abs(x[i])
            return result

        def reduce_zero_poly(x:list):
            x = x.copy()
            carries = [0] * (len(x)-1)
            for i in range(0, len(x)-1):
                carries[i] = x[i] // ids.BASE
                x[i] = x[i] % ids.BASE
                assert x[i] == 0
                x[i+1] += carries[i]
            assert x[-1] == 0
            return x, carries

        for i in range(ids.N_LIMBS):
            p+=getattr(ids, 'P'+str(i)) * ids.BASE**i
            p_limbs[i]=getattr(ids, 'P'+str(i))
            val_limbs[i]+=as_int(getattr(ids.val, 'd'+str(i)), PRIME)
            val+=as_int(getattr(ids.val, 'd'+str(i)), PRIME) * ids.BASE**i

        mul = val
        q, r = divmod(mul, p)

        assert r == 0, f"verify_zero: Invalid input."
        qs = split(q)
        for i in range(ids.N_LIMBS):
            setattr(ids.q, 'd'+str(i), qs[i])

        q_P_limbs = [q*P for P in p_limbs]
        diff_limbs = poly_sub(q_P_limbs, val_limbs)
        _, carries = reduce_zero_poly(diff_limbs)
        carries = abs_poly(carries)
        for i in range(ids.N_LIMBS-1):
            setattr(ids, 'flag'+str(i), 1 if diff_limbs[i] >= 0 else 0)
            setattr(ids, 'q'+str(i), carries[i])
    %}

    assert [range_check_ptr + 0] = q;
    assert [range_check_ptr + 1] = q0;
    assert [range_check_ptr + 2] = q1;
    assert [range_check_ptr + 3] = q2;
    assert [range_check_ptr + 4] = q3;

    tempvar diff_d0 = q * P0 - val.d0;
    tempvar diff_d1 = q * P1 - val.d1;
    tempvar diff_d2 = q * P2 - val.d2;
    tempvar diff_d3 = q * P3 - val.d3;
    tempvar diff_d4 = q * P4 - val.d4;

    local carry0: felt;
    local carry1: felt;
    local carry2: felt;
    local carry3: felt;

    if (flag0 != 0) {
        assert diff_d0 = q0 * BASE;
        assert carry0 = q0;
    } else {
        assert carry0 = (-1) * q0;
        assert diff_d0 = carry0 * BASE;
    }

    if (flag1 != 0) {
        assert diff_d1 + carry0 = q1 * BASE;
        assert carry1 = q1;
    } else {
        assert carry1 = (-1) * q1;
        assert diff_d1 + carry0 = carry1 * BASE;
    }

    if (flag2 != 0) {
        assert diff_d2 + carry1 = q2 * BASE;
        assert carry2 = 2;
    } else {
        assert carry2 = (-1) * q2;
        assert diff_d2 + carry1 = carry2 * BASE;
    }

    if (flag3 != 0) {
        assert diff_d3 + carry2 = q3 * BASE;
        assert carry3 = 3;
    } else {
        assert carry3 = (-1) * q3;
        assert diff_d3 + carry2 = carry3 * BASE;
    }

    assert diff_d4 + carry3 = 0;
    tempvar range_check_ptr = range_check_ptr + 5;
    return();
}

func verify_zero9{range_check_ptr}(val: UnreducedBigInt9) {
    alloc_locals;
    local q: BigInt5;
    local flag0: felt;
    local flag1: felt;
    local flag2: felt;
    local flag3: felt;
    local flag4: felt;
    local flag5: felt;
    local flag6: felt;
    local flag7: felt;
    local q0: felt;
    local q1: felt;
    local q2: felt;
    local q3: felt;
    local q4: felt;
    local q5: felt;
    local q6: felt;
    local q7: felt;

    %{
        from starkware.cairo.common.math_utils import as_int
        assert 1 < ids.N_LIMBS <= 12
        assert ids.DEGREE == ids.N_LIMBS-1
        val, p=0,0
        val_limbs, p_limbs = ids.N_LIMBS_UNREDUCED*[0], ids.N_LIMBS*[0]
        def split(x, degree=ids.DEGREE, base=ids.BASE):
            coeffs = []
            for n in range(degree, 0, -1):
                q, r = divmod(x, base ** n)
                coeffs.append(q)
                x = r
            coeffs.append(x)
            return coeffs[::-1]

        def poly_mul(a:list, b:list,n=ids.N_LIMBS) -> list:
            assert len(a) == len(b) == n
            result = [0] * ids.N_LIMBS_UNREDUCED
            for i in range(n):
                for j in range(n):
                    result[i+j] += a[i]*b[j]
            return result
        def poly_sub(a:list, b:list, n=ids.N_LIMBS_UNREDUCED) -> list:
            assert len(a) == len(b) == n
            result = [0] * n
            for i in range(n):
                result[i] = a[i] - b[i]
            return result

        def abs_poly(x:list):
            result = [0] * len(x)
            for i in range(len(x)):
                result[i] = abs(x[i])
            return result

        def reduce_zero_poly(x:list):
            x = x.copy()
            carries = [0] * (len(x)-1)
            for i in range(0, len(x)-1):
                carries[i] = x[i] // ids.BASE
                x[i] = x[i] % ids.BASE
                assert x[i] == 0
                x[i+1] += carries[i]
            assert x[-1] == 0
            return x, carries

        for i in range(ids.N_LIMBS_UNREDUCED):
            val_limbs[i]+=as_int(getattr(ids.val, 'd'+str(i)), PRIME)
            val+=as_int(getattr(ids.val, 'd'+str(i)), PRIME) * ids.BASE**i


        for i in range(ids.N_LIMBS):
            p+=getattr(ids, 'P'+str(i)) * ids.BASE**i
            p_limbs[i]=getattr(ids, 'P'+str(i))

        mul = val
        q, r = divmod(mul, p)

        assert r == 0, f"verify_zero: Invalid input."
        qs = split(q)
        for i in range(ids.N_LIMBS):
            setattr(ids.q, 'd'+str(i), qs[i])

        q_P_limbs = poly_mul(qs, p_limbs)
        diff_limbs = poly_sub(q_P_limbs, val_limbs)
        _, carries = reduce_zero_poly(diff_limbs)
        carries = abs_poly(carries)
        for i in range(ids.N_LIMBS_UNREDUCED-1):
            setattr(ids, 'flag'+str(i), 1 if diff_limbs[i] >= 0 else 0)
            setattr(ids, 'q'+str(i), carries[i])
    %}

    assert [range_check_ptr + 0] = q0;
    assert [range_check_ptr + 1] = q1;
    assert [range_check_ptr + 2] = q2;
    assert [range_check_ptr + 3] = q3;
    assert [range_check_ptr + 4] = q4;
    assert [range_check_ptr + 5] = q5;
    assert [range_check_ptr + 6] = q6;
    assert [range_check_ptr + 7] = q7;
    assert [range_check_ptr + 8] = BASE_MIN_1 - q.d0;
    assert [range_check_ptr + 9] = BASE_MIN_1 - q.d1;
    assert [range_check_ptr + 10] = BASE_MIN_1 - q.d2;
    assert [range_check_ptr + 11] = BASE_MIN_1 - q.d3;
    assert [range_check_ptr + 12] = BASE_MIN_1 - q.d4;

    tempvar diff_d0 = q.d0 * P0 - val.d0;
    tempvar diff_d1 = q.d0 * P1 + q.d1 * P0 - val.d1;
    tempvar diff_d2 = q.d0 * P2 + q.d1 * P1 + q.d2 * P0 - val.d2;
    tempvar diff_d3 = q.d0 * P3 + q.d1 * P2 + q.d2 * P1 + q.d3 * P0 - val.d3;
    tempvar diff_d4 = q.d0 * P4 + q.d1 * P3 + q.d2 * P2 + q.d3 * P1 + q.d4 * P0 - val.d4;
    tempvar diff_d5 = q.d1 * P4 + q.d2 * P3 + q.d3 * P2 + q.d4 * P1 - val.d5;
    tempvar diff_d6 = q.d2 * P4 + q.d3 * P3 + q.d4 * P2 - val.d6;
    tempvar diff_d7 = q.d3 * P4 + q.d4 * P3 - val.d7;
    tempvar diff_d8 = q.d4 * P4 - val.d8;

    local carry0: felt;
    local carry1: felt;
    local carry2: felt;
    local carry3: felt;
    local carry4: felt;
    local carry5: felt;
    local carry6: felt;
    local carry7: felt;
    if (flag0 != 0) {
        assert diff_d0 = q0 * BASE;
        assert carry0 = q0;
    } else {
        assert carry0 = (-1) * q0;
        assert diff_d0 = carry0 * BASE;
    }
    if (flag1 != 0) {
        assert diff_d1 + carry0 = q1 * BASE;
        assert carry1 = q1;
    } else {
        assert carry1 = (-1) * q1;
        assert diff_d1 + carry0 = carry1 * BASE;
    }
    if (flag2 != 0) {
        assert diff_d2 + carry1 = q2 * BASE;
        assert carry2 = q2;
    } else {
        assert carry2 = (-1) * q2;
        assert diff_d2 + carry1 = carry2 * BASE;
    }
    if (flag3 != 0) {
        assert diff_d3 + carry2 = q3 * BASE;
        assert carry3 = q3;
    } else {
        assert carry3 = (-1) * q3;
        assert diff_d3 + carry2 = carry3 * BASE;
    }
    if (flag4 != 0) {
        assert diff_d4 + carry3 = q4 * BASE;
        assert carry4 = q4;
    } else {
        assert carry4 = (-1) * q4;
        assert diff_d4 + carry3 = carry4 * BASE;
    }
    if (flag5 != 0) {
        assert diff_d5 + carry4 = q5 * BASE;
        assert carry5 = q5;
    } else {
        assert carry5 = (-1) * q5;
        assert diff_d5 + carry4 = carry5 * BASE;
    }
    if (flag6 != 0) {
        assert diff_d6 + carry5 =q6 * BASE;
        assert carry6 = q6;
    } else {
        assert carry6 = (-1) * q6;
        assert diff_d6 + carry5 = carry6 * BASE;
    }
    if (flag7 != 0) {
        assert diff_d7 + carry6 =q7 * BASE;
        assert carry7 = q7;
    } else {
        assert carry7 = (-1) * q7;
        assert diff_d7 + carry6 = carry7 * BASE;
    }    

    assert diff_d8 + carry7 = 0;
    tempvar range_check_ptr = range_check_ptr + 13;
    return ();
}

func is_zero{range_check_ptr}(x: BigInt5) -> (res: felt) {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();

    local is_zero: felt;

    %{
        from starkware.cairo.common.math_utils import as_int
        assert 1 < ids.N_LIMBS <= 12
        x,p=0,0
        for i in range(ids.N_LIMBS):
            x+=as_int(getattr(ids.x, 'd'+str(i)), PRIME) * ids.BASE**i
            p+=getattr(ids, 'P'+str(i)) * ids.BASE**i
        ids.is_zero = 1 if x%p == 0 else 0
    %}

    if (is_zero != 0) {
        verify_zero5(x);
        return (res=1);
    }

    let x_inverse = fq_bigint5.inv(&x);

    return (res=0);
}
