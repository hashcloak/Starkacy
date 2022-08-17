from pydoc import plain
from src.starkcurve import _STARKCURVE, G, H
from fastecdsa.point import Point
from fastecdsa import keys

# Random number is generated without considering the security, maybe changed later
from Crypto.Random import random
from Crypto.Util import number

#r = number.getRandomNBitInteger(256) maybe used for later versions
class Setup:
    def generate_keys(self):
        # generate a keypair (i.e. both keys) for _STARKCURVE
        priv_key, pub_key = keys.gen_keypair(_STARKCURVE)
        
        # get the public key corresponding to the private key we just generated
        pub_key = keys.get_public_key(priv_key, _STARKCURVE)
        
        return priv_key, pub_key

class Prover:
    def elgamal_encrypt(self, m, pk):
        r = number.getRandomRange(1, _STARKCURVE.q - 1)
        C_1 = G * r
        C_2 = r * pk + m
        return C_1, C_2, r
    
    def elgamal_decrypt(self, C_1, C_2, sk):
        M = sk * C_1
        plaintext = C_2 - M
        return plaintext

    # a temporary method for encoding plaintext as a point on _STARKCURVE
    def encode_plaintext(self, plaintext):
        encoded_plaintext = G * plaintext
        return encoded_plaintext
    

    

