%builtins output range_check

from src.starkjub import assert_on_curve, ec_add, ec_mul, ec_double, ec_sub, Starkjub
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    local G: EcPoint = EcPoint(Starkjub.GEN_X, Starkjub.GEN_Y);    

    // Test for affine Starkjub coordinates

    let (xk) = ec_mul(G, 452312848583266401712165347886883763197416885958242462530951491185349408851);
    assert_on_curve(xk);

    serialize_word(xk.x);
    serialize_word(xk.y);
    
    return();
}

