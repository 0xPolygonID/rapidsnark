#!/bin/bash

CIRCOMLIB_REPO_URL="https://github.com/iden3/circomlib"

script=$(realpath "$0")
script_dir=$(dirname "$script")

target_dir="$script_dir/circomlib"

git clone "$CIRCOMLIB_REPO_URL" $target_dir