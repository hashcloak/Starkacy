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

struct EcPointProjective{
    x: felt,
    y: felt,
    z: felt,
}

struct EcPointExtendedAffine{
    x: felt,
    y: felt,
    t: felt,
    z: felt,
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

func point_projective_to_affine(p: EcPointProjective) -> (r: EcPoint) {
    alloc_locals;
    tempvar x = p.x / p.z;
    tempvar y = p.y / p.z;
    return (r=EcPoint(x=x, y=y));
}

func point_affine_to_projective(p: EcPoint) -> (r: EcPointProjective) {
    alloc_locals;
    return (r=EcPointProjective(x=p.x, y=p.y, z=1));
}

func point_affine_to_extended_affine(p: EcPoint) -> (r: EcPointExtendedAffine) {
    alloc_locals;
    tempvar t = p.x * p.y;
    return (r=EcPointExtendedAffine(x=p.x, y=p.y, t=t, z=1));
}

func point_extended_affine_to_affine(p: EcPointExtendedAffine) -> (r: EcPoint) {
    alloc_locals;
    tempvar x = p.x / p.z;
    tempvar y = p.y / p.z;
    return (r=EcPoint(x=x, y=y));
}

func ec_add(p: EcPoint, q: EcPoint) -> (r: EcPoint) {
    alloc_locals;

    tempvar s = Starkjub.d * p.x * p.y * q.x * q.y;
    tempvar x = (p.x * q.y + p.y * q.x) * (1 / (1+s)) ;
    tempvar y = (p.y * q.y - Starkjub.a * p.x * q.x) * (1 / (1 - s));
    return (r=EcPoint(x=x, y=y));
}

func ec_add_projective(p: EcPointProjective, q:EcPointProjective) -> (r: EcPointProjective) {
    alloc_locals;

    tempvar A  = p.z * q.z;
    tempvar B = A * A;
    tempvar C = p.x * q.x;
    tempvar D = p.y * q.y;
    tempvar E = Starkjub.d * C * D;
    tempvar F = B - E;
    tempvar G = B + E;
    tempvar x = A * F * ((p.x + p.y) * (q.x + q.y) - C - D);
    tempvar y = A * G * (D - Starkjub.a * C);
    tempvar z = F * G;
    return (r=EcPointProjective(x=x, y=y, z=z));
}

func ec_add_extended_affine(p: EcPointExtendedAffine, q:EcPointExtendedAffine) -> (r: EcPointExtendedAffine) {
    alloc_locals;

    tempvar A = p.x * q.x;
    tempvar B = p.y * q.y;
    tempvar C = Starkjub.d * p.t * q.t;
    tempvar D = p.z * q.z;
    tempvar E = (p.x + p.y) * (q.x + q.y) - A - B;
    tempvar F = D - C;
    tempvar G = D + C;
    tempvar H = B - Starkjub.a * A;
    tempvar x = E * F;
    tempvar y = G * H;
    tempvar t = E * H;
    tempvar z = F * G;
    return (r=EcPointExtendedAffine(x=x, y=y, t=t, z= z));
}

func ec_double(p: EcPoint) -> (r: EcPoint) {
    alloc_locals;

    tempvar s = Starkjub.d * p.x * p.x * p.y * p.y;
    tempvar x = (p.x * p.y + p.y * p.x) * (1 / (1+s)) ;
    tempvar y = (p.y * p.y - Starkjub.a * p.x * p.x) * (1 / (1 - s));
    return (r=EcPoint(x=x, y=y));
}

func ec_double_projective(p: EcPointProjective) -> (r: EcPointProjective) {
    alloc_locals;

    tempvar B = (p.x + p.y) * (p.x + p.y);
    tempvar C = p.x * p.x;
    tempvar D = p.y * p.y;
    tempvar E = Starkjub.a * C;
    tempvar F = E + D;
    tempvar H = p.z * p.z;
    tempvar J = F - 2 * H;
    tempvar x = (B - C - D) * J;
    tempvar y = F * (E - D);
    tempvar z = F * J;
    return (r=EcPointProjective(x=x, y=y, z=z));
}

func ec_double_extended_affine(p: EcPointExtendedAffine) -> (r: EcPointExtendedAffine) {
    alloc_locals;

    tempvar A = p.x * p.x;
    tempvar B = p.y * p.y;
    tempvar C = 2 * p.z * p.z;
    tempvar D = Starkjub.a * A;
    tempvar E = (p.x + p.y) * (p.x + p.y) - A - B;
    tempvar G = D + B;
    tempvar F = G - C;
    tempvar H = D - B;
    tempvar x = E * F;
    tempvar y = G * H;
    tempvar t = E * H;
    tempvar z = F * G;
    return (r=EcPointExtendedAffine(x=x, y=y, t=t, z=z));
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

func ec_mul_projective{range_check_ptr}(point: EcPointProjective, scalar: felt) -> (res: EcPointProjective) {
    if (scalar == 0) {
        with_attr error_message("Too large scalar") {
            scalar = 0;
        }
        let identity_point = EcPointProjective(0, 1, 1);
        return (res=identity_point);
    }

    alloc_locals;
    let (double_point: EcPointProjective) = ec_double_projective(point);
    %{ memory[ap] = (ids.scalar % PRIME) % 2 %}
    jmp odd if [ap] != 0, ap++;
    return ec_mul_projective(point=double_point, scalar=scalar / 2);

    odd:
    let inner_res: EcPointProjective = ec_mul_projective(
        point=double_point, scalar=(scalar - 1) / 2
    );

    let (res: EcPointProjective) = ec_add_projective(p=point, q=inner_res);
    return (res=res);
}

func ec_mul_extended_affine{range_check_ptr}(point: EcPointExtendedAffine, scalar: felt) -> (res: EcPointExtendedAffine) {
    if (scalar == 0) {
        with_attr error_message("Too large scalar") {
            scalar = 0;
        }
        let identity_point = EcPointExtendedAffine(0, 1, 0, 1);
        return (res=identity_point);
    }

    alloc_locals;
    let (double_point: EcPointExtendedAffine) = ec_double_extended_affine(point);
    %{ memory[ap] = (ids.scalar % PRIME) % 2 %}
    jmp odd if [ap] != 0, ap++;
    return ec_mul_extended_affine(point=double_point, scalar=scalar / 2);

    odd:
    let inner_res: EcPointExtendedAffine = ec_mul_extended_affine(
        point=double_point, scalar=(scalar - 1) / 2
    );

    let (res: EcPointExtendedAffine) = ec_add_extended_affine(p=point, q=inner_res);
    return (res=res);
}