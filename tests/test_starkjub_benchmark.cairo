%builtins output ec_op
// Functions for Starkjub Curve
// ax^2 + y^2 = 1 + dx^2y^2 where
// a = 146640 and d = 146636
// The point at infinity is represented as (0, 1)

from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.ec_point import EcPoint
from src.constants import BASE_POINT_X, BASE_POINT_Y
from starkware.cairo.common.math import is_quad_residue
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op

// Add libraries for testing purposes

namespace Starkjub {
    const a = 146640;
    const d = 146636;
    const GEN_X = 2065699795511519733436237708177164622668357918131020778486714673024550645584;
    const GEN_Y = 1666035597895264107928948444893966434436309134596180408598119672656400359905;
    const ORDER = 452312848583266401712165347886883763197416885958242462530951491185349408851;
}

// Asserts that an EC point is on the Starkjub curve

// Arguments:
// p - an EC point

// Fix the check for Identity element
func assert_on_curve_jub(p: EcPoint) {
    alloc_locals;
    if(p.x == 0) {
        assert p.y = 1;
        return ();
    }

    tempvar equation = Starkjub.a * p.x * p.x + p.y * p.y - 1 - Starkjub.d * p.x * p.x * p.y * p.y;
    assert equation = 0;
    return ();
}

// Fix the check for Identity element
func ec_add_jub(p: EcPoint, q: EcPoint) -> (r: EcPoint) {
    alloc_locals;
    tempvar s = Starkjub.d * p.x * p.y * q.x * q.y;
    tempvar x = (p.x * q.y + p.y * q.x) * (1 / (1+s)) ;
    tempvar y = (p.y * q.y - Starkjub.a * p.x * q.x) * (1 / (1 - s));
    return (r=EcPoint(x=x, y=y));
}

// Fix the check for Identity element
func ec_double_jub(p: EcPoint) -> (r: EcPoint) {
    alloc_locals;
    let (res) = ec_add(p, p);
    return(r = res);
}

func ec_sub_jub(p: EcPoint, q: EcPoint) -> (r: EcPoint) {
    alloc_locals;
    return ec_add(p=p, q= EcPoint(x = -p.x, y=q.y));
}

func ec_op_jub{ec_op_ptr: EcOpBuiltin*}(p: EcPoint, m: felt, q: EcPoint) -> (r: EcPoint) {
    alloc_locals;

    // (0, 0), which represents the point at infinity, is the only point with y = 0.
    if (q.y == 0) {
        return (r=p);
    }

    local s: EcPoint;
    %{
        from starkware.crypto.signature.signature import ALPHA, BETA, FIELD_PRIME
        from src.starkcurve import _STARKCURVE
        from starkware.python.math_utils import random_ec_point
        from starkware.python.utils import to_bytes

        # Define a seed for random_ec_point that's dependent on all the input, so that:
        #   (1) The added point s is deterministic.
        #   (2) It's hard to choose inputs for which the builtin will fail.
        seed = b"".join(map(to_bytes, [ids.p.x, ids.p.y, ids.m, ids.q.x, ids.q.y]))
        ids.s.x, ids.s.y = random_ec_point(_STARKCURVE.p, ids.Starkjub.a, ids.Starkjub.d, seed)
    %}
    let p_plus_s: EcPoint = ec_add(p, s);

    assert ec_op_ptr.p = p_plus_s;
    assert ec_op_ptr.m = m;
    assert ec_op_ptr.q = q;
    let r: EcPoint = ec_add(ec_op_ptr.r, EcPoint(x=s.x, y=-s.y));
    let ec_op_ptr = ec_op_ptr + EcOpBuiltin.SIZE;
    return (r=r);
}

func main{output_ptr: felt*, ec_op_ptr: EcOpBuiltin*}() {
    alloc_locals;
    local G: EcPoint = EcPoint(Starkjub.GEN_X, Starkjub.GEN_Y);
    assert_on_curve_jub(G);
    let (D) = ec_add_jub(G, G);
    assert_on_curve_jub(D);

    //local G: EcPoint = EcPoint(BASE_POINT_X, BASE_POINT_Y);
    //assert_on_curve(G);
    //let (D) = ec_add(G, G);
    //assert_on_curve(D);

    return();
}