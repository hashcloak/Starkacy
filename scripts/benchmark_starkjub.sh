cairo-compile benchmark/benchmark_starkjub.cairo --output benchmark_starkjub_compiled.json

cairo-run --print_info --program=benchmark_starkjub_compiled.json --print_output --layout=all