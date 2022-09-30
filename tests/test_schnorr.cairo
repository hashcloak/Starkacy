%builtins output ec_op

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.serialize import serialize_word
from src.math_utils import ec_mul
from src.pedersen_commitment_verifier import verify_pedersen_commitment

func main{output_ptr: felt*, ec_op_ptr: EcOpBuiltin*}() {
    alloc_locals;

    local message: felt;
    local blinding_factor: felt;
    local commitment: EcPoint;

    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)

        from src.pedersenpy import PedersenCommitment
        from src.schnorr import SchnorrSignature
        p = PedersenCommitment()
        
        zz = SchnorrSignature()
        zzz = zz.prove(13)
        print(zz)

        C, blinding_factor = p.commit(100)

        ids.blinding_factor = blinding_factor
        ids.commitment.x = C.x
        ids.commitment.y = C.y
    %}

    // assert_on_curve(off_chain_committed_value)

    message = 100;

    // verify_pedersen(pedersen_commitment, off_chain_committed_value)
    verify_pedersen_commitment(message, blinding_factor, commitment);

    return ();
}
