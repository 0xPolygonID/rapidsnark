#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Error: This script requires 3 arguments."
  echo "Usage: $0 <benchmark_name> <input_file> <tau_rank>"
  echo ""
  echo "1. benchmark_name: The folder name of the benchmark to test."
  echo "2. input_file: The input file to use in the benchmark (only the postfix after input_)."
  echo "3. tau_rank: the power of tau file rank to use. (will be downloaded if not exist)"
  exit 1
fi

benchmark_name=$1
input_size=$2
tau_rank=$3

echo "Benchmark to test - $benchmark_name"
echo "Input size to use -  $input_size"
echo "Power of tau rank to use - $tau_rank"

set -e
script=$(realpath "$0")
script_dir=$(dirname "$script")

benchmark_dir="${script_dir}/${benchmark_name}"
circuit_dir="${benchmark_dir}/circuit"
compiled_dir="${circuit_dir}/compiled"

rapid_snark_prover=${script_dir}"/../build_prover/src/prover"

if [[ "$(uname)" == "Darwin" ]]; then
  TIME=(gtime -f "mem %M\ntime %e\ncpu %P")
else
  TIME=(/usr/bin/time -f "mem %M\ntime %e\ncpu %P")
fi

export NODE_OPTIONS=--max_old_space_size=327680

function render_circuit() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/Main([0-9]*)/Main($input_size)/" "$circuit_dir/circuit.circom"
  else
    sed -i "s/Main([0-9]*)/Main($input_size)/" "$circuit_dir/circuit.circom"
  fi
}

function compile_circuit() {
  echo circom "$circuit_dir/circuit.circom" --r1cs --sym --wasm -o "$compiled_dir"
  circom "$circuit_dir/circuit.circom" --r1cs --sym --wasm -o "$compiled_dir"
}

function run_setup() {
  echo "${TIME[@]}" ./trusted_setup.sh "$tau_rank"
  "${TIME[@]}" ./trusted_setup.sh "$tau_rank" "$compiled_dir"

  prove_key_size=$(ls -lh "$compiled_dir"/circuit_0001.zkey | awk '{print $5}')
  verify_key_size=$(ls -lh "$compiled_dir"/verification_key.json | awk '{print $5}')

  echo "Prove key size: $prove_key_size"
  echo "Verify key size: $verify_key_size"
}

function generate_witness() {
  echo node "$compiled_dir/circuit_js/generate_witness.js" "$compiled_dir/circuit_js/circuit.wasm" "$benchmark_dir/input/input_${input_size}.json" "$compiled_dir/witness.wtns"
  "${TIME[@]}" node "$compiled_dir/circuit_js/generate_witness.js" "$compiled_dir/circuit_js/circuit.wasm" "$benchmark_dir/input/input_${input_size}.json" "$compiled_dir/witness.wtns"
}

#function snarkjs_prove() {
#  avg_time 10 snarkjs groth16 prove "$compiled_dir/circuit_0001.zkey" "$compiled_dir/witness.wtns" "$compiled_dir/proof.json" "$compiled_dir/public.json"
#  proof_size=$(ls -lh "$compiled_dir/proof.json" | awk '{print $5}')
#  echo "Proof size: $proof_size (snarkjs)"
#}

function rapid_prove() {
  avg_time 10 "$rapid_snark_prover" "$compiled_dir/circuit_0001.zkey" "$compiled_dir/witness.wtns" "$compiled_dir/proof.json" "$compiled_dir/public.json"
  proof_size=$(ls -lh "$compiled_dir/proof.json" | awk '{print $5}')
  echo "Proof size: $proof_size (rapidsnark)"
}

function verify_proof() {
  avg_time 10 snarkjs groth16 verify "$compiled_dir/verification_key.json" "$compiled_dir/public.json" "$compiled_dir/proof.json"
}

function avg_time() {
    n=$1; shift
    (($# > 0)) || return
    echo "$@"
    for ((i = 0; i < n; i++)); do
        "${TIME[@]}" "$@" 2>&1
    done | awk '
        /mem/ { mem = mem + $2; nm++ }
        /time/ { time = time + $2; nt++ }
        /cpu/  { cpu  = cpu  + substr($2,1,length($2)-1); nc++}
        END    {
                 if (nm>0) printf("mem %f\n", mem/nm);
                 if (nt>0) printf("time %f\n", time/nt);
                 if (nc>0) printf("cpu %f\n",  cpu/nc)
               }'
}

function print_step() {
  step_title=$(printf "%-23s" "$1")

  echo ""
  echo "============================================="
  echo "========== $step_title =========="
  echo "============================================="
}

print_step "Step0: Render Circuit"
render_circuit

print_step "Step1: Compile Circuit"
compile_circuit

print_step "Step2: Setup"
run_setup

print_step "Step3: Generate Witness"
generate_witness

print_step "Step4: Prove"
rapid_prove

print_step "Step5: Verify"
verify_proof

echo ""
echo "========================================"
echo "Execution complete!"
echo "========================================"
