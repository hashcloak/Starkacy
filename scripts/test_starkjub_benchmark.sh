cairo-compile tests/test_starkjub_benchmark.cairo --output test_starkjub_benchmark_compiled.json

cairo-run --print_info --program=test_starkjub_benchmark_compiled.json --print_output --layout=all