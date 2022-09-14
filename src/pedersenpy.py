from src.starkcurve import _STARKCURVE, G, H
from fastecdsa.point import Point

# Random number is generated without considering the security, maybe changed later
from Crypto.Random import random
from Crypto.Util import number

#r = number.getRandomNBitInteger(256) maybe used for later versions

class PedersenCommitment:
    def commit(self, message):
        blinding_factor = number.getRandomRange(1, _STARKCURVE.q - 1)
        C = message * G + blinding_factor * H
        return C, blinding_factor

