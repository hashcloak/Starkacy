from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin

func ec_mul{ec_op_ptr: EcOpBuiltin*}(p: EcPoint, m: felt) -> (product: EcPoint):
    alloc_locals
    local id_point: EcPoint = EcPoint(0, 0)
    let (r: EcPoint) = ec_op(id_point, m, p)
    return (product = r)
end