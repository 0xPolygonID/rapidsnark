#!/bin/bash

if [ $# -ne 1 ]; then
  echo "tau_rank required"
  exit 1
fi
TAU_FILE=$1
COMMON_DIR=$(dirname $(realpath "$0"))

TAU_DIR="$COMMON_DIR/ptau/"
TAU_FULL="$TAU_DIR$TAU_FILE"
if [ ! -f "$TAU_FULL" ]; then
  echo "download $TAU_FILE" with wget, make sure wget installed
  wget -P $TAU_DIR "https://hermez.s3-eu-west-1.amazonaws.com/$TAU_FILE"
fi