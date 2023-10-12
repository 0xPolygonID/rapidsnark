pragma circom 2.0.3;

include "../../common/circomlib/circuits/sha256/sha256.circom";
include "../../common/circomlib/circuits/bitify.circom";

template Main(N) {
    signal input in[N];
    signal input hash[32];
    signal output out[32];

    component sha256 = Sha256Bytes(N);
    sha256.in <== in;
    out <== sha256.out;

    for (var i = 0; i < 32; i++) {
        out[i] === hash[i];
    }

    log("start ================");
    for (var i = 0; i < 32; i++) {
        log(out[i]);
    }
    log("finish ================");
}

template Sha256Bytes(n) {
  signal input in[n];
  signal output out[32];

  component byte_to_bits[n];
  for (var i = 0; i < n; i++) {
    byte_to_bits[i] = Num2Bits(8);
    byte_to_bits[i].in <== in[i];
  }

  component sha256 = Sha256(n*8);
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < 8; j++) {
      sha256.in[i*8+j] <== byte_to_bits[i].out[7-j];
    }
  }

  component bits_to_bytes[32];
  for (var i = 0; i < 32; i++) {
    bits_to_bytes[i] = Bits2Num(8);
    for (var j = 0; j < 8; j++) {
      bits_to_bytes[i].in[7-j] <== sha256.out[i*8+j];
    }
    out[i] <== bits_to_bytes[i].out;
  }
}

// render this file before compilation
component main = Main(256);

