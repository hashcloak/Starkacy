%builtins output range_check

from src.starkjub import assert_on_curve, ec_add, ec_mul, ec_double, ec_sub, Starkjub, point_projective_to_affine, point_affine_to_projective, ec_mul_projective, ec_mul_extended_affine, point_affine_to_extended_affine, point_extended_affine_to_affine, EcPointExtendedAffine, EcPointProjective
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    local G: EcPoint = EcPoint(Starkjub.GEN_X, Starkjub.GEN_Y);    

    // Benchmark for affine Starkjub coordinates

    //let (xk) = ec_mul(G, 452312848583266401712165347886883763197416885958242462530951491185349408851);
    //assert_on_curve(xk);

    //serialize_word(xk.x);
    //serialize_word(xk.y);

    // Benchmark for extended_affine_coordinates

    //let (G_extended_affine) = point_affine_to_extended_affine(G);
    //let (ex_mul) = ec_mul_extended_affine(G_extended_affine, 452312848583266401712165347886883763197416885958242462530951491185349408851);
    //let (ex_mul_affine) = point_extended_affine_to_affine(ex_mul);

    //serialize_word(ex_mul_affine.x);
    //serialize_word(ex_mul_affine.y);
    //assert_on_curve(ex_mul_affine);

    // Benchmark for projective coordinates

    let (G_projective) = point_affine_to_projective(G);
    let (projective_mul) = ec_mul_projective(G_projective, 452312848583266401712165347886883763197416885958242462530951491185349408851);
    let (projective_mul_affine) = point_projective_to_affine(projective_mul);

    serialize_word(projective_mul_affine.x);
    serialize_word(projective_mul_affine.y);
    assert_on_curve(projective_mul_affine);
    
    return();
}

