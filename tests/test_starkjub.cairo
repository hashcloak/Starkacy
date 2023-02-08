%builtins output ec_op
// Functions for Starkjub Curve
// ax^2 + y^2 = 1 + dx^2y^2 where
// a = 146640 and d = 146636
// The point at infinity is represented as (0, 1)

from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.math import is_quad_residue
from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*, ec_op_ptr: EcOpBuiltin*}() {
    alloc_locals;
    local G: EcPoint = EcPoint(Starkjub.GEN_X, Starkjub.GEN_Y);
    assert_on_curve(G);
    let (D) = ec_add(G, G);
    assert_on_curve(D);
    let (zero) = ec_sub(G, G);
    assert_on_curve(zero);
    assert_on_curve(EcPoint(0, 1));
    let (add_1) = ec_add(G, EcPoint(0, 1));
    //let (add_2) = ec_add(G, EcPoint(0, -1));
    assert G = G;
    assert G = add_1;
    //assert G = add_2;
    serialize_word(G.x);
    serialize_word(G.y);
    serialize_word(add_1.x);
    serialize_word(add_1.y);
    return();
}