%builtins output ec_op

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.serialize import serialize_word
from src.math_utils import ec_mul
from src.elgamal import verify_elgamal_encryption, ElGamalEncryption, encode_plaintext
from src.constants import BASE_POINT_X, BASE_POINT_Y, BASE_BLINDING_POINT_X, BASE_BLINDING_POINT_Y

func main{output_ptr : felt*, ec_op_ptr : EcOpBuiltin*}():
    alloc_locals
    
    local elgamal_encryption : ElGamalEncryption
    
    local off_chain_ciphertext_no_1 : EcPoint
    local off_chain_ciphertext_no_2 : EcPoint

    # Generating keys on the setup phase
    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)

        from src.elgamalpy import Setup, Prover

        s = Setup()

        _, bobs_public_key = s.generate_keys()
    %}

    # Generating the proof
    %{    
        p = Prover()
        
        plaintext = p.encode_plaintext(100)

        C_1, C_2, r = p.elgamal_encrypt(plaintext , bobs_public_key)

        ids.off_chain_ciphertext_no_1.x = C_1.x
        ids.off_chain_ciphertext_no_1.y = C_1.y
        ids.off_chain_ciphertext_no_2.x = C_2.x
        ids.off_chain_ciphertext_no_2.y = C_2.y

        ids.elgamal_encryption.random_number = r
        
        ids.elgamal_encryption.public_key.x = bobs_public_key.x
        ids.elgamal_encryption.public_key.y = bobs_public_key.y
    %}

    let(encoded_plaintext) = encode_plaintext(100)

    elgamal_encryption.plaintext.x = encoded_plaintext.x
    elgamal_encryption.plaintext.y = encoded_plaintext.y

    verify_elgamal_encryption(elgamal_encryption, off_chain_ciphertext_no_1, off_chain_ciphertext_no_2)

    return()
end