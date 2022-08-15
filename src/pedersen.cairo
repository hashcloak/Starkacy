from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from src.math_utils import ec_mul

const MESSAGE_LENGTH = 2 ** 64 - 1

func verify_pedersen{range_check_ptr, ec_op_ptr : EcOpBuiltin*}(message : felt, r : felt) -> (C : EcPoint):
    alloc_locals
    
    local G : EcPoint = EcPoint(874739451078007766457464989774322083649278607533249481151382481072868806602, 152666792071518830868575557812948353041420400780739481342941381225525861407)
    local H : EcPoint = EcPoint(1644404348220522245795652770711644747389835183387584438047505930708711545294, 3418409665108082357574218324957319851728951500117497918120788963183493908527)

    assert_on_curve(G)
    assert_on_curve(H)

    let (mG) = ec_mul(G, message)
    let (rH) = ec_mul(H, r)

    let (C) = ec_add(mG, rH)
    return(C = C)
end