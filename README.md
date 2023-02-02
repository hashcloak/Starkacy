# Starkacy
Stark Friendly Privacy Primitives in Cairo

## Getting Started
[Install Cairo](https://www.cairo-lang.org/docs/quickstart.html) <br/>
Clone the repo
```
git clone https://github.com/hashcloak/Starkacy.git 
```
<br/>

Source the cairo environment: `source ~/cairo_venv/bin/activate`

<br/>

## Running a test for additive homomorphism of pedersen commitments

To test the verifier for the pedersen commitment, run
```bash
./scripts/test_pedersen.sh
```

To test the verifier for Schnorr Signature, run
```bash
./scripts/test_schnorr.sh
```

To test the pedersen_hash function for, run
```bash
./scripts/test_pedersen_hash.sh
```

## Next steps
- [x] Update it to Cairo v.0.10.0
- [x] Add hash functions for Schnorr prover in Python and the verifier in Cairo
- [ ] Update it to Cairo v.1.0.0 (when Elliptic Curve operations are ready for this specific version)
- [ ] Add Rust version of pedersen_commitment
- [ ] Add Rust version of Schnorr prover
- [ ] Implement Flashproofs prover and verifier in Rust
- [ ] Implement Flashproofs verifier in Cairo 1.0.0