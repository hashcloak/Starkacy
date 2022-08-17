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
./scripts/test_additive_homomorphism
```
<br/>

To test the verifier for the pedersen commitment, run
```bash
./scripts/test_pedersen.sh
```
<br/>

To test the verifier for the ElGamal Encryption, run
```bash
./scripts/test_elgamal_encryption.sh
```
<br/>

To test the verifier for the ElGamal Decryption, run
```bash
./scripts/test_elgamal_decryption.sh
```

## Next steps
- [ ] 64-bit messages for pedersen commitment?
- [ ] Add possible modifications on "encoding" and "decoding"
- [ ] Add Prostar when `ec_point` is supported by StarkNet.