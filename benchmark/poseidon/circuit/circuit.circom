pragma circom 2.0.3;

include "../../common/circomlib/circuits/poseidon.circom";


template Main(N) {
    signal input in[N];
    signal input hash;
    signal output out;

    component pos = Poseidon(N);
    for (var i = 0; i < N; i++) {
        pos.inputs[i] <== in[i];
    }
    out <== pos.out;
    out === hash;
}

// render this file before compilation
component main = Main(15);

