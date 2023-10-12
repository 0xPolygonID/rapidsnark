
# Benchmark Tests

This folder contains a series of benchmark tests designed to evaluate the performance of rapidsnark prover with commonly circuits implementations.

## Overview

The benchmark tests cover the most common circuit implementations, aiming to provide insight into the performance and cost of widely-used circuits. By offering a comprehensive set of benchmarking tests, we aim to gain better understanding of the current performance levels of rapidsnark.

## Getting Started

Before running the benchmark tests, ensure that you have followed the instructions in the main `README.md` file to set up the rapidsnark environment. Make sure you have the prover executable in the `build`/`build_prover` folder.

A valid environment to run the benchmark tests contains the following:
 - prover executable in the `build`/`build_prover` folder
 - Clone circomlib by running the script [benchmark/common/setup_circomlib.sh](./common/setup_circomlib.sh)


## Running the Benchmark Tests

1. [Poseidon](./poseidon) - Assess Poseidon hash function performance.
2. [SHA256](./sha256) - Evaluate SHA256 hashing efficiency.
3. [Merkle tree inclusion](./merkletree) - Test Merkle tree inclusion proof.

To run a specific benchmark test, run the `run_benchmark.sh` with the following arguments:
- <strong>Benchmark name</strong> - choose the test to run by specify the folder name of the test (e.g for merkle tree inclusion, use `merkletree`)
 - <strong>Input Parameters file</strong> - Choose the input file you wish to use in the benchmark (need to pass the postfix after `input_` of the filename).
 - <strong>Degree of ptau file</strong> - Specify the degree of the needed patu (will be downloaded if not exist).

### Example

Say we want to run a benchmark on merkle tree inclusion proof for a tree with depth of 30, and we want to use `powersOfTau28_hez_final_20.ptau`, we will need to run the following command `./run_benchmark.sh merkletree 30 20`.


## Contributing

We encourage community members to contribute to the benchmark tests by improving existing benchmark tests, proposing new tests, or suggesting performance enhancements. Please feel free to open issues or submit pull requests to share your ideas and improvements.
