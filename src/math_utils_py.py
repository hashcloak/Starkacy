from src.starkjub.src.starkjub import StarkJub, Point
from unicodedata import decimal
from Crypto.Random import random
from Crypto.Util import number

def random_starkjub_point():
        ECC = StarkJub()
        P = Point(2065699795511519733436237708177164622668357918131020778486714673024550645584, 1666035597895264107928948444893966434436309134596180408598119672656400359905, ECC)    
        print(P)
        P.print_validation()
        alpha = number.getRandomRange(1, ECC.O - 1)
        result = alpha * P
        result.print_validation()
        return result