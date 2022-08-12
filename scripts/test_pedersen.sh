# run from the root
#!/bin/sh

cairo-compile tests/test_additive_homomorphism.cairo --output test_compiled.json

cairo-run --program=test_compiled.json \
    --print_output --layout=all

