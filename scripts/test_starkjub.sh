cairo-compile tests/test_starkjub.cairo --output starkjub_compiled.json

cairo-run --print_info --program=starkjub_compiled.json --print_output --layout=all