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

namespace Starkjub_Weierstrass {
    const a = 2412335192444087475798215188730046737082071476887731133315394704083413779307;
    const b = 1876260705234290258954167369012258573286055593134901992578640558967738699968;
    const GEN_X = 1626661091161142785174006508072989866433300034815130015476718150213932235181;
    const GEN_Y = 3194136058374515263688326233944704537957884874262274537202445859032392161441;
    const ORDER = 452312848583266401712165347886883763197416885958242462530951491185349408851;
}

// Asserts that an EC point is on the Starkjub curve

// Arguments:
// p - an EC point

// Fix the check for Identity element
//func assert_on_curve(p: EcPoint) {
//    alloc_locals;
//
//    if(p.x == 0) {
//        assert p.y = 1;
//        return ();
//    }
//
//    tempvar equation = p.y * p.y - p.x * p.x * p.x - Starkjub_Weierstrass.a * p.x - Starkjub_Weierstrass.b;
//    assert equation = 0;
//    return ();
//}

func assert_on_curve(p: EcPoint) {
    // Because the curve order is odd, there is no point (except (0, 0), which represents the point
    // at infinity) with y = 0.
    if (p.y == 0) {
        assert p.x = 0;
        return ();
    }
    
    tempvar rhs = (p.x * p.x + Starkjub_Weierstrass.a) * p.x + Starkjub_Weierstrass.b;
    assert p.y * p.y = rhs;
    return ();
}

func ec_add(p: EcPoint, q: EcPoint) -> (r: EcPoint) {
    // (0, 0), which represents the point at infinity, is the only point with y = 0.
    if (p.y == 0) {
        return (r=q);
    }
    if (q.y == 0) {
        return (r=p);
    }
    if (p.x == q.x) {
        if (p.y == q.y) {
            return ec_double(p);
        }
        // In this case, because p and q are on the curve, p.y = -q.y.
        return (r=EcPoint(x=0, y=0));
    }
    tempvar slope = (p.y - q.y) / (p.x - q.x);
    tempvar r_x = slope * slope - p.x - q.x;
    return (r=EcPoint(x=r_x, y=slope * (p.x - r_x) - p.y));
}

func ec_double(p: EcPoint) -> (r: EcPoint) {
    // (0, 0), which represents the point at infinity, is the only point with y = 0.
    if (p.y == 0) {
        return (r=p);
    }
    tempvar slope = (3 * p.x * p.x + Starkjub_Weierstrass.a) / (2 * p.y);
    tempvar r_x = slope * slope - p.x - p.x;
    return (r=EcPoint(x=r_x, y=slope * (p.x - r_x) - p.y));
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
        let identity_point = EcPoint(0, 0);
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