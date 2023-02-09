cairo-compile benchmark/benchmark_starkcurve.cairo --output benchmark_starkcurve_compiled.json

cairo-run --print_info --program=benchmark_starkcurve_compiled.json --print_output --layout=all