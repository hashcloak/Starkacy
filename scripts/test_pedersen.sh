cairo-compile tests/test_pedersen.cairo --output test_pedersen_compiled.json

cairo-run --program=test_pedersen_compiled.json --print_output --layout=all