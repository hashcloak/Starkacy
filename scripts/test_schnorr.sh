cairo-compile tests/test_schnorr.cairo --output test_schnorr_compiled.json

cairo-run --program=test_schnorr_compiled.json --print_output --layout=all

