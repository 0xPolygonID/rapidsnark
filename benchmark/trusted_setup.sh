#!/bin/bash

if [ $# -ne 2 ]; then
  echo "tau_rank required and r1cs_location is required"
  exit 1
fi

TAU_RANK=$1
TAU_FILE=p"owersOfTau28_hez_final_${TAU_RANK}.ptau"
TAU_DIR=$(dirname "$SCRIPT")"/common/ptau"
TAU_FILE_WITH_DIR="${TAU_DIR}/${TAU_FILE}"

R1CS_DIR=$2

./common/download_ptau.sh "$TAU_FILE"

echo `pwd`
echo $TAU_FILE_WITH_DIR
echo $R1CS_DIR


snarkjs groth16 setup "$R1CS_DIR/circuit.r1cs" "${TAU_FILE_WITH_DIR}" "$R1CS_DIR/circuit_0000.zkey"
echo 1 | snarkjs zkey contribute "$R1CS_DIR/circuit_0000.zkey" "$R1CS_DIR/circuit_0001.zkey" --name='cont' -v
snarkjs zkey export verificationkey "$R1CS_DIR/circuit_0001.zkey" "$R1CS_DIR/verification_key.json"
