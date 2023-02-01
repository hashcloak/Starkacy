cairo-compile tests/test_pedersen_hash.cairo --output test_pedersen_hash_compiled.json

cairo-run --program=test_pedersen_hash_compiled.json --print_output --layout=all