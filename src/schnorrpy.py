from unicodedata import decimal
from src.starkcurve import _STARKCURVE, G, Q
from fastecdsa.point import Point
from web3 import Web3

# Random number is generated without considering the security, maybe changed later
from Crypto.Random import random
from Crypto.Util import number

class SchnorrSignature:
    def prove(self, secret, c):
        alpha = number.getRandomRange(1, _STARKCURVE.q - 1)

        alpha_G = alpha * G
        #x = alpha_G.x
        #y = alpha_G.y
        
        # challenge needs to be hashed! So don't use this function for the privacy reason for now!
        # In other versions, hash function will be added for hashing the challenge
        #c = 1

        response = (alpha + c * secret) % Q
        public_key = secret * G
        return alpha_G, response, public_key

    # off-chain verification for testing
    def verify(self, alpha_G, response, public_key, challenge):
        # challenge needs to be hashed! So don't use this function for the privacy reason for now!
        # In other versions, hash function will be added for hashing the challenge

        x = alpha_G.x
        y = alpha_G.y
        _R = response * G
        _Rprime = alpha_G  + challenge * public_key
        assert _R == _Rprime