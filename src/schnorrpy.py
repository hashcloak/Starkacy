from unicodedata import decimal
from src.starkcurve import _STARKCURVE, G, Q
from fastecdsa.point import Point
from web3 import Web3

# Random number is generated without considering the security, maybe changed later
from Crypto.Random import random
from Crypto.Util import number

class SchnorrSignature:
    def prove(self, secret):
        alpha = number.getRandomRange(1, _STARKCURVE.q - 1)

        alpha_G = alpha * G
        x = alpha_G.x
        y = alpha_G.y
        #c = int(Web3.solidityKeccak(['uint256', 'uint256'], [x, y]).hex(), 16) % Q
        c = int(Web3.soliditySha3(['uint256', 'uint256',], [x, y]).hex(), 16) % Q

        print(c)

        response = (alpha + c * secret) % Q
        public_key = secret * G
        return alpha_G, response, public_key

    # off-chain verification for testing
    def verify(self, alpha_G, response, public_key):
        x = alpha_G.x
        y = alpha_G.y
        _c = int(Web3.solidityKeccak(['uint256', 'uint256'], [x, y]).hex(), 16) % Q
        _R = response * G
        _Rprime = alpha_G  + _c * public_key
        assert _R == _Rprime
