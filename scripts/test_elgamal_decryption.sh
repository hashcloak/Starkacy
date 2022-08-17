cairo-compile tests/test_elgamal_decryption.cairo --output test_elgamal_decryption_compiled.json

cairo-run --program=test_elgamal_decryption_compiled.json --print_output --layout=all