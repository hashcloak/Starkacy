%builtins output ec_op

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.serialize import serialize_word
from src.math_utils import ec_mul
from src.pedersen import verify_pedersen, PedersenCommitment


func main{output_ptr : felt*, ec_op_ptr : EcOpBuiltin*}():
    alloc_locals
    
    local pedersen_commitment : PedersenCommitment
    local off_chain_committed_value : EcPoint

    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)

        from src.pedersenpy import Prover
        p = Prover()
        
        C, r = p.pedersen_commit(100)

        ids.pedersen_commitment.blinding_factor = r
        ids.off_chain_committed_value.x = C.x
        ids.off_chain_committed_value.y = C.y
    %}

    #assert_on_curve(off_chain_committed_value)

    pedersen_commitment.message = 100

    verify_pedersen(pedersen_commitment, off_chain_committed_value)

    return()
end