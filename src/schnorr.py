from unicodedata import decimal
from src.starkcurve import _STARKCURVE, G, Q
from fastecdsa.point import Point
from web3 import Web3

# Random number is generated without considering the security, maybe changed later
from Crypto.Random import random
from Crypto.Util import number

class SchnorrSignature:
    def prove(self, secret):
        #alpha = number.getRandomRange(1, _STARKCURVE.q - 1)
        alpha = 5
        alpha_G = alpha * G
        x = alpha_G.x
        y = alpha_G.y
        c = int(Web3.solidityKeccak(['uint256', 'uint256'], [x, y]).hex(), 16) % Q
        response = alpha + c * secret
        # the function int(hex ,16) is not looking reasonable. However, it gives the correct output. So, I'll use it for now.
        return alpha_G, response