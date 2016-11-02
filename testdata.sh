#!/bin/bash

source formatting.sh
source meta.sh
source argparse.sh
source read.sh
source testing.sh
source additional.sh
source standard.sh

# Globalni promenne
TMPDIR="/tmp/testdata"
MODE=""
ARCHIV=""
PROGRAM=""
CUSTOMOUTDIR="testdata_io"
NAZEVIN=$(printf "custom_input_%08d.txt" "0")
NAZEVOUT=$(printf "custom_output_%08d.txt" "0")

declare -a REFERVYS
declare -a REFERVSTUP
declare -a MYVYSTUP

declare -a REFERVSTUPCUST
declare -a REFERVYSCUST
declare -a MYVYSTUPCUST

declare -a ROZDILY
declare -a ROZDILYCUST

# Uvodni zprava
welcome

iterateArgs "$@"

case "$MODE" in
    "add")
        runInAddMode
        ;;
    *)
        runInStandardMode
        ;;
esac
























 
