%builtins output range_check bitwise

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_keccak.keccak import keccak_felts, finalize_keccak
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

func main{output_ptr: felt*, range_check_ptr,
        bitwise_ptr: BitwiseBuiltin*}(){
    alloc_locals;
    tempvar x = 1;
    tempvar y = 2;
    
    let (keccak_ptr: felt*) = alloc();
    local keccak_ptr_start: felt* = keccak_ptr;
    
    let (inputs) = alloc();
    assert inputs[0] = 1;
    assert inputs[1] = 2;
    
    with keccak_ptr{
    let (hashed) = keccak_felts(2, inputs);
    }
    
    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);
    
    // keccak_felts returns a Uint256 struct, we need to % starkcurve.Q 
    //serialize_word(hashed);
    return ();
}
