cairo-compile tests/test_starkjub_weierstrass.cairo --output test_starkjub_weierstrass_compiled.json

cairo-run --print_info --program=test_starkjub_weierstrass_compiled.json --print_output --layout=all