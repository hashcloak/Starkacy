// Functions for Starkjub Curve
// ax^2 + y^2 = 1 + dx^2y^2 where
// a = 146640 and d = 146636
// The point at infinity is represented as (0, 1)

// For, ec_add_extended_affine, ec_double_extended_affine,
// See "Twisted Edwards Curves Revisited"
// Huseyin Hisil, Kenneth Koon-Ho Wong, Gary Carter, and Ed Dawson
// 3.1 Unified Addition in E^e
// Source: https://www.hyperelliptic.org/EFD/g1p/data/twisted/extended/addition/madd-2008-hwcd

// For, ec_add_projective, ec_double_projective,
// Source: https://www.hyperelliptic.org/EFD/g1p/auto-twisted-projective.html

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.math import is_quad_residue
from starkware.cairo.common.serialize import serialize_word

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
func assert_on_curve(p: EcPoint) {
    alloc_locals;

    if(p.x == 0) {
        assert p.y = 1;
        return ();
    }

    tempvar equation = Starkjub.a * p.x * p.x + p.y * p.y - 1 - Starkjub.d * p.x * p.x * p.y * p.y;
    assert equation = 0;
    return ();
}

func ec_add(p: EcPoint, q: EcPoint) -> (r: EcPoint) {
    alloc_locals;

    tempvar s = Starkjub.d * p.x * p.y * q.x * q.y;
    tempvar x = (p.x * q.y + p.y * q.x) * (1 / (1+s)) ;
    tempvar y = (p.y * q.y - Starkjub.a * p.x * q.x) * (1 / (1 - s));
    return (r=EcPoint(x=x, y=y));
}

func ec_double(p: EcPoint) -> (r: EcPoint) {
    alloc_locals;

    tempvar s = Starkjub.d * p.x * p.x * p.y * p.y;
    tempvar x = (p.x * p.y + p.y * p.x) * (1 / (1+s)) ;
    tempvar y = (p.y * p.y - Starkjub.a * p.x * p.x) * (1 / (1 - s));
    return (r=EcPoint(x=x, y=y));
}

func ec_sub(p: EcPoint, q: EcPoint) -> (r: EcPoint) {
    alloc_locals;
    return ec_add(p=p, q= EcPoint(x = -p.x, y=q.y));
}

func ec_mul{range_check_ptr}(point: EcPoint, scalar: felt) -> (res: EcPoint) {
    if (scalar == 0) {
        with_attr error_message("Too large scalar") {
            scalar = 0;
        }
        let identity_point = EcPoint(0, 1);
        return (res=identity_point);
    }

    alloc_locals;
    let (double_point: EcPoint) = ec_double(point);
    %{ memory[ap] = (ids.scalar % PRIME) % 2 %}
    jmp odd if [ap] != 0, ap++;
    return ec_mul(point=double_point, scalar=scalar / 2);

    odd:
    let inner_res: EcPoint = ec_mul(
        point=double_point, scalar=(scalar - 1) / 2
    );

    let (res: EcPoint) = ec_add(p=point, q=inner_res);
    return (res=res);
}