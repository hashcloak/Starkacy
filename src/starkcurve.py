# a, b, p are parameters of the Weierstrass form of the Stark-friendly elliptic curve
# https://docs.starkware.co/starkex-v4/crypto/stark-curve

# Q is order of the Stark-friendly elliptic curve
#https://crypto.stackexchange.com/questions/95666/how-to-find-out-what-the-order-of-the-base-point-of-the-elliptic-curve-is

# (gx, gy) is the generated point used in ECDSA scheme for the Stark-friendly elliptic curve
# (hx, hy) is generated offline using a cryptographic random number and the (gx, gy)

from fastecdsa.curve import Curve
from fastecdsa.point import Point

Q = 3618502788666131213697322783095070105526743751716087489154079457884512865583
p = 3618502788666131213697322783095070105623107215331596699973092056135872020481
a = 1
b = 3141592653589793238462643383279502884197169399375105820974944592307816406665
gx = 874739451078007766457464989774322083649278607533249481151382481072868806602
gy = 152666792071518830868575557812948353041420400780739481342941381225525861407
hx = 1644404348220522245795652770711644747389835183387584438047505930708711545294
hy = 3418409665108082357574218324957319851728951500117497918120788963183493908527

_STARKCURVE = Curve("StarkNet Curve", p,
                    1,
                    b,
                    Q,
                    gx,
                    gy)

# Generator of the _STARKCURVE
G = Point(gx,gy, _STARKCURVE)
H = Point(hx, hy, _STARKCURVE)