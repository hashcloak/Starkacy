# BASE_POINT is the generator point used in the ECDSA scheme
# https://docs.starkware.co/starkex-v4/crypto/stark-curve

# To generate BASE_BLINDING_POINT, a cryptographic random number is generated
# BASE_BLINDING_POINT is the result of elliptic curve scalar multiplication of
# "cryptographic number" and "BASE_POINT", which the operation is done as offline

# Note that the generated number is less than the order of the starkcurve:
# 3618502788666131213697322783095070105526743751716087489154079457884512865583
# The order of the elliptic curve is found thanks to:
# https://crypto.stackexchange.com/questions/95666/how-to-find-out-what-the-order-of-the-base-point-of-the-elliptic-curve-is

# MINUS_1 is calculated by subtracting -1 from the order of STARKCURVE

const BASE_POINT_X = 874739451078007766457464989774322083649278607533249481151382481072868806602
const BASE_POINT_Y = 152666792071518830868575557812948353041420400780739481342941381225525861407
const BASE_BLINDING_POINT_X = 1644404348220522245795652770711644747389835183387584438047505930708711545294
const BASE_BLINDING_POINT_Y = 3418409665108082357574218324957319851728951500117497918120788963183493908527
const MINUS_1 = 3618502788666131213697322783095070105526743751716087489154079457884512865582