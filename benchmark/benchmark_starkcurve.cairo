%builtins output ec_op

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from src.math_utils import ec_mul
from src.constants import BASE_POINT_X, BASE_POINT_Y
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*, ec_op_ptr: EcOpBuiltin*}() {
    alloc_locals;

    local G: EcPoint = EcPoint(BASE_POINT_X, BASE_POINT_Y);
    assert_on_curve(G);

    let (xk) = ec_mul(G, 452312848583266401712165347886883763197416885958242462530951491185349408851);

    assert_on_curve(xk);

    serialize_word(xk.x);
    serialize_word(xk.y);

    return();
}

