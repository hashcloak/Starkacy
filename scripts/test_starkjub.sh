cairo-compile src/starkjubx.cairo --output starkjub_compiled.json

cairo-run --print_info --program=starkjub_compiled.json --print_output --layout=all