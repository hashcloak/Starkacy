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
To run a simple test for additive homomorphism of pedersen commitments (with few values), run
```bash
./scripts/test_pedersen.sh
```

## Next steps
- [ ] Get blinding factor r from [VRF-StarkNet] (https://github.com/0xNonCents/VRF-StarkNet) (may not be 256-bit?)
- [ ] 64-bit messages? assert 64-bit
- [ ] Add Prostar when `ec_point` is supported by StarkNet.
- [ ] Add ElGamal Encryption