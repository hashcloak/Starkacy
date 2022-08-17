cairo-compile tests/test_elgamal_encryption.cairo --output test_elgamal_encryption_compiled.json

cairo-run --program=test_elgamal_encryption_compiled.json --print_output --layout=all