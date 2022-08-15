%builtins output ec_op

from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import assert_on_curve, ec_add, ec_double, ec_op
from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.serialize import serialize_word
from src.math_utils import ec_mul
from src.pedersen import verify_pedersen

func test_additive_homomorphism{output_ptr : felt*, ec_op_ptr : EcOpBuiltin*}(G : EcPoint, H : EcPoint):
    alloc_locals
    let m1 = 100
    let m2 = 200
    let m1_add_m2 = 300

    let r1 = 10
    let r2 = 20
    let r1_add_r2 = 30

    assert_on_curve(G)
    assert_on_curve(H)

    let (C1) = verify_pedersen(message = m1, r = r1)
    let (C2) = verify_pedersen(message = m2, r = r2)
    let (C3) = verify_pedersen(message = m1_add_m2, r = r1_add_r2)

    assert_on_curve(C1)
    assert_on_curve(C2)
    assert_on_curve(C3)

    let (LHS) = ec_add(C1, C2)

    assert_on_curve(LHS)

    assert LHS.x = C3.x
    assert LHS.y = C3.y
    
    serialize_word(LHS.x)
    serialize_word(LHS.y)
    serialize_word(C3.x)
    serialize_word(C3.y)
    
    return()
end


func main{output_ptr : felt*, ec_op_ptr : EcOpBuiltin*}():
    alloc_locals

    local G : EcPoint = EcPoint(874739451078007766457464989774322083649278607533249481151382481072868806602, 152666792071518830868575557812948353041420400780739481342941381225525861407)
    local H : EcPoint = EcPoint(1644404348220522245795652770711644747389835183387584438047505930708711545294, -200093123558048856123104458137750253894155715214098781852303092952378111954)

    assert_on_curve(G)
    assert_on_curve(H)

    test_additive_homomorphism(G, H)

    return()
end