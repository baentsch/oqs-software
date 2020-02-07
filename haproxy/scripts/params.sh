#!/bin/bash

# default values:
export SIG_ALG=dilithium4
export KEM_ALG=kyber512

PARAMS=""

while (( "$#" )); do
  case "$1" in
    -k|--kem)
      export KEM_ALG=$2
      shift 2
      ;;
    -s|--sig)
      export SIG_ALG=$2
      shift 2
      ;;
    --) 
      shift
      break
      ;;
    -*|--*=) 
      echo "Usage: $0 [--sig <OQS signature algorithm name>] [--kem <OQS KEM algorithm name>]. Exiting."
      exit 1
      ;;
    *) 
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
eval set -- "$PARAMS"


