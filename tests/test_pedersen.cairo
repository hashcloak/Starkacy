%builtins output range_check ec_op

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.serialize import serialize_word
from src.math_utils import ec_mul
from src.pedersen import verify_pedersen


func main{output_ptr : felt*, range_check_ptr, ec_op_ptr : EcOpBuiltin*}():
    alloc_locals
    local blinding_factor
    local committed_value : EcPoint

    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)

        from src.pedersenpy import Prover
        p = Prover()
        
        C, r = p.pedersen_commit(100)

        ids.blinding_factor = r
        ids.committed_value.x = C.x
        ids.committed_value.y = C.y
    %}

    assert_on_curve(committed_value)

    let (verified_pedersen) = verify_pedersen(message = 100, r = blinding_factor)
    
    assert_on_curve(verified_pedersen)
    
    assert verified_pedersen = committed_value

    return()
end