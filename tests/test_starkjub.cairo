%builtins output range_check

from src.starkjub import assert_on_curve, ec_add, ec_mul, ec_double, ec_sub, Starkjub
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    local G: EcPoint = EcPoint(Starkjub.GEN_X, Starkjub.GEN_Y);
    assert_on_curve(G);
    //let (D) = ec_add(G, G);
    //assert_on_curve(D);
    //let (zero) = ec_sub(G, G);
    //let (doubling) = ec_double(G);
    //assert_on_curve(doubling);
    let (xk) = ec_mul(G, 452312848583266401712165347886883763197416885958242462530951491185349408851);
    //let false_identity: EcPoint = EcPoint(0, -1);
    //let identity: EcPoint = EcPoint(0, 1);
    //let (x) = ec_double(identity);
    //serialize_word(x.x);
    //serialize_word(x.y);
    assert_on_curve(xk);
    serialize_word(xk.x);
    //serialize_word(D.x);
    serialize_word(xk.y);
    //  serialize_word(D.y);

    return();
}

