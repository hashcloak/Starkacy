// BASE_POINT is the generator point used in the ECDSA scheme
// https://docs.starkware.co/starkex-v4/crypto/stark-curve

// To generate BASE_BLINDING_POINT, a cryptographic random number is generated
// BASE_BLINDING_POINT is the result of elliptic curve scalar multiplication of
// "cryptographic number" and "BASE_POINT", which the operation is done as offline

// Note that the generated number is less than the order of the starkcurve:
// 3618502788666131213697322783095070105526743751716087489154079457884512865583
// The order of the elliptic curve is found thanks to:
// https://crypto.stackexchange.com/questions/95666/how-to-find-out-what-the-order-of-the-base-point-of-the-elliptic-curve-is

%builtins output range_check bitwise

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from src.math_utils import ec_mul
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_keccak.keccak import keccak_felts, finalize_keccak
from starkware.cairo.common.alloc import alloc
from src.constants import BASE_POINT_X, BASE_POINT_Y, BASE_BLINDING_POINT_X, BASE_BLINDING_POINT_Y

struct MyStruct {
    first_member: felt,
    second_member: MyStruct*,
}


struct Part1 {
    cy: EcPoint,
    cts: EcPoint*,
    css: EcPoint*,
    cqs: EcPoint*,
    eInvs: felt*, 
}


struct Part2 {
    vs: felt*,
    u: felt,
    epsilon: felt,
}

// Bu aşağıdaki G ve H noktasını değiştiricez. Bunlar büyük ihtimalle generator evet
// bunlar bn curve generatorları -> biz bunları kendi generatorlarımız ile değiştiricez
// GX, GY, HX, HY Starkcurve üzerinde generator noktalarımız var

// const AA
// const BB
// const PP
// const NN

// There are exactly 16 points from G1X, G1Y to ---> G16X, G16Y

func verifyRangeArgument(part1: Part1, part2: Part2, nbits: felt, k: felt, L: felt) -> (res : felt){

    return(res=1);
}

func generateGS(L : felt, gs_temp: EcPoint*) -> (gs : EcPoint*){
    assert gs_temp[0] = EcPoint(x=1, y=2);
    assert gs_temp[1] = EcPoint(x=5, y=3);
    assert gs_temp[2] = EcPoint(x=1, y=2);
    assert gs_temp[3] = EcPoint(x=5, y=3);
    assert gs_temp[4] = EcPoint(x=1, y=2);
    assert gs_temp[5] = EcPoint(x=5, y=3);
    assert gs_temp[6] = EcPoint(x=1, y=2);
    assert gs_temp[7] = EcPoint(x=5, y=3);
    assert gs_temp[8] = EcPoint(x=1, y=2);
    assert gs_temp[9] = EcPoint(x=5, y=3);
    assert gs_temp[10] = EcPoint(x=1, y=2);
    
    if(L == 16){
        assert gs_temp[11] = EcPoint(x=1, y=2);
        assert gs_temp[12] = EcPoint(x=5, y=3);
        assert gs_temp[13] = EcPoint(x=1, y=2);
        assert gs_temp[14] = EcPoint(x=5, y=3);
        assert gs_temp[15] = EcPoint(x=1, y=2);
    }

    return(gs = gs_temp);
}

// func computeBaseChallenge() -> for_loop var bu kısma sonra geri dönelim
// mod NN'de keccak fonksiyonu kullanıyor. 
// anonymous_zether'da kullanılan group order ile aynı order
// BN_128 curve'ün orderı ve de parametrelerini kullanmışlar.
// Kısacası, group orderdan küçük bir sayıda olan bir tane felt dönecek şekilde implement
// edebiliriz.
// mod fonksiyonu kullanıyor.


//compute_challenges ilçersinde mul_mod isimli bir fonksiyon var

func computeBaseChallenge{output_ptr : felt*, range_check_ptr,
                         bitwise_ptr : BitwiseBuiltin*}(cy: EcPoint, 
                         cts_length: felt, cts: EcPoint*,
                         css_length: felt, css: EcPoint*,
                         cqs_length: felt, cqs: EcPoint*) -> (challenge : felt){

    alloc_locals;

    local size = 2 * (cts_length + css_length + cqs_length);

    let (local cs_temp : felt*) = alloc();

    let (cs) = fill_cs(src = cts, cs = cs_temp, length = cts_length);
    let new_cs : felt* = cs + cts_length*2;

    let (cs) = fill_cs(src = css, cs = new_cs, length = css_length);
    let new_cs : felt* = cs + css_length*2;

    let (cs) = fill_cs(src = cqs, cs = new_cs, length = cqs_length);
    let new_cs : felt* = cs - cts_length*2 - css_length*2;

    // Constructing a felt* that keccak functions will use inside
    // Use new_cs in keccak_felts function.
    //serialize_word(new_cs[0]);
    //serialize_word(new_cs[1]);
    //serialize_word(new_cs[2]);
    //serialize_word(new_cs[3]);
    //serialize_word(new_cs[4]);
    //serialize_word(new_cs[5]);
    //serialize_word(new_cs[6]);
    //serialize_word(new_cs[7]);
    //serialize_word(new_cs[8]);
    //serialize_word(new_cs[9]);
    //serialize_word(new_cs[10]);
    //serialize_word(new_cs[11]);

    let (keccak_ptr : felt*) = alloc();
    local keccak_ptr_start: felt* = keccak_ptr;

    with keccak_ptr{
        let (hashed) = keccak_felts(size, new_cs);
    }

    // hashed is Uint256. So, we need a function which 
    // takes the mod of Uint256 with % starkcurve.Q and returns
    // corresponding felt

    finalize_keccak(keccak_ptr_start = keccak_ptr_start, keccak_ptr_end = keccak_ptr);

    return(challenge = 5);
}

//func computeChallenges(part1 : Part1, k: felt) -> (challenges : felt*){
//    alloc_locals;
//    local challengeNeg1 = part1.eInvs[0];
//    let (challenge) = computeBaseChallenge(part1.cy, part1.cts, part1.css, part1.cqs);
//
//
//    
//}

func fill_arr(src: felt*, dest: felt*, length: felt) -> (dest: felt*){
    if (length == 0){
        return(dest=dest);
    }

    assert dest[0] = src[0];
    fill_arr(src = src + 1, dest = dest + 1, length = length - 1);
    return(dest=dest);
}

func fill_cs(src: EcPoint*, cs: felt*, length: felt) -> (cs: felt*){
    if (length == 0){
        return(cs=cs);
    }

    assert cs[0] = src[0].x;
    assert cs[1] = src[0].y;

    fill_cs(src = src + EcPoint.SIZE, cs = cs + EcPoint.SIZE, length = length - 1);

    return(cs=cs);
}

// Test for constructing gs
//func main{output_ptr : felt*}(){
//    alloc_locals;
//    let (local gs_temp: EcPoint*) = alloc();
//    //assert gs[0] = EcPoint(x=1, y=2);
//    //assert gs[1] = EcPoint(x=5, y=3);
//    //tempvar x = 5;
//    //serialize_word(x);
//    //serialize_word(gs[0].x);
//    //serialize_word(gs[0].y);
//    //serialize_word(gs[1].x);
//    //serialize_word(gs[1].y);
//
//    let (gs) = generateGS(L=11, gs_temp = gs_temp);
//    serialize_word(gs[0].x);
//    serialize_word(gs[10].x);
//    serialize_word(gs[9].x);
//
//    
//    return();
//}

// Test for array concat
//func main{output_ptr: felt*}(){
//    // Concating arrays
//    alloc_locals;
//    let (local dest_temp : felt*) = alloc();
//    let (local src : felt*) = alloc();
//    assert src[0] = 1;
//    assert src[1] = 2;
//    assert src[2] = 3;
//    let (dest) = fill_arr(src = src, dest = dest_temp, length = 3);
//    let new_dest : felt* = dest + 3;
//    let (dest) = fill_arr(src = src, dest = new_dest, length = 3);
//    let new_dest : felt* = dest - 3;
//    serialize_word(new_dest[0]);
//    serialize_word(new_dest[1]);
//    serialize_word(new_dest[2]);
//    serialize_word(new_dest[3]);
//    serialize_word(new_dest[4]);
//    serialize_word(new_dest[5]);
//
//    return();
//
//}


// Test for computeBaseChallenge function
func main{output_ptr : felt*, range_check_ptr,
          bitwise_ptr : BitwiseBuiltin*}(){
    alloc_locals;

    let (local src : EcPoint*) = alloc();
    let (local src1 : EcPoint*) = alloc();
    let (local src2 : EcPoint*) = alloc();
    local cy : EcPoint = EcPoint(7474, 84848);

    assert src[0] = EcPoint(2, 3);
    assert src[1] = EcPoint(5, 7);
    assert src1[0] = EcPoint(1, 1);
    assert src2[0] = EcPoint(4, 8);
    assert src2[1] = EcPoint(1234, 356);
    assert src2[2] = EcPoint(6, 35);

    let (x) = computeBaseChallenge(cy, 2, src, 1, src1, 3, src2);

    return();

}

