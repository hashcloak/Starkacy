from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from src.math_utils import ec_mul
from src.constants import BASE_POINT_X, BASE_POINT_Y, BASE_BLINDING_POINT_X, BASE_BLINDING_POINT_Y, MINUS_1
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import assert_not_equal
from starkware.cairo.common.serialize import serialize_word

struct ElGamalEncryption:
    member public_key : EcPoint
    member plaintext : EcPoint
    member random_number : felt
end

struct ElGamalDecryption:
    member private_key : felt
    member ciphertext_1 : EcPoint
    member ciphertext_2 : EcPoint
end

func encrypt_elgamal{ec_op_ptr : EcOpBuiltin*}(elgamal_encryption : ElGamalEncryption) -> (ciphertext : EcPoint*):
    alloc_locals
    let (local ciphertext : EcPoint*) = alloc()
    validate_public_key(elgamal_encryption.public_key)
    
    local G : EcPoint = EcPoint(BASE_POINT_X, BASE_POINT_Y)

    let (C_1) = ec_mul(G, elgamal_encryption.random_number)
    let (C_temp) = ec_mul(elgamal_encryption.public_key, elgamal_encryption.random_number)
    let (C_2) = ec_add(elgamal_encryption.plaintext, C_temp)

    assert [ciphertext].x = C_1.x
    assert [ciphertext].y = C_1.y
    
    assert [ciphertext + EcPoint.SIZE].x = C_2.x
    assert [ciphertext + EcPoint.SIZE].y = C_2.y

    return(ciphertext = ciphertext)
end

func verify_elgamal_encryption{ec_op_ptr : EcOpBuiltin*}(elgamal_encryption : ElGamalEncryption, off_chain_ciphertext_no_1 : EcPoint, off_chain_ciphertext_no_2 : EcPoint):
    alloc_locals
    assert_on_curve(off_chain_ciphertext_no_1)
    assert_on_curve(off_chain_ciphertext_no_2)

    let(encrypted_value) = encrypt_elgamal(elgamal_encryption)
    
    assert_on_curve([encrypted_value])
    assert_on_curve([encrypted_value + EcPoint.SIZE])

    assert off_chain_ciphertext_no_1 = [encrypted_value]
    assert off_chain_ciphertext_no_2 = [encrypted_value + EcPoint.SIZE]

    return()
end

func verify_elgamal_decryption{ec_op_ptr : EcOpBuiltin*}(elgamal_decryption : ElGamalDecryption, off_chain_plaintext : EcPoint):
    alloc_locals
    assert_on_curve(elgamal_decryption.ciphertext_1)
    assert_on_curve(elgamal_decryption.ciphertext_2)
    assert_on_curve(off_chain_plaintext)

    let (plaintext) = decrypt_elgamal(elgamal_decryption)
    assert_on_curve(plaintext)
    assert plaintext = off_chain_plaintext
    
    return()
end

func decrypt_elgamal{ec_op_ptr : EcOpBuiltin*}(elgamal_decryption : ElGamalDecryption) -> (plaintext : EcPoint):
    alloc_locals

    let (M) = ec_mul(elgamal_decryption.ciphertext_1, elgamal_decryption.private_key)
    let (minus_M) = ec_mul(M, MINUS_1)
    let (plaintext) = ec_add(elgamal_decryption.ciphertext_2, minus_M)

    return(plaintext = plaintext)
end

func validate_public_key{ec_op_ptr : EcOpBuiltin*}(public_key : EcPoint):
    alloc_locals

    assert_on_curve(public_key)

    local point_at_infinity : EcPoint = EcPoint(0, 0)
    let Q = 3618502788666131213697322783095070105526743751716087489154079457884512865583
    
    assert_not_equal(point_at_infinity.x, public_key.x)
    assert_not_equal(point_at_infinity.y, public_key.y)

    let (order_check) = ec_mul(public_key, Q)
    assert order_check = point_at_infinity

    return()
end

func encode_plaintext{ec_op_ptr : EcOpBuiltin*}(plaintext : felt) -> (encoded_plaintext : EcPoint):
    alloc_locals

    local G : EcPoint = EcPoint(BASE_POINT_X, BASE_POINT_Y)
    let (encoded_plaintext) = ec_mul(G, plaintext)

    return(encoded_plaintext = encoded_plaintext) 
end




