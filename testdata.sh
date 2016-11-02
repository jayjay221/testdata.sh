#!/bin/bash

source formatting.sh
source meta.sh
source argparse.sh
source read.sh
source testing.sh
source additional.sh

# Globalni promenne
TMPDIR="/tmp/testdata"
MODE=""
ARCHIV=""
PROGRAM=""

# Uvodni zprava

welcome
parseArg "$@"

case "$mode" in
    "add")
        runInAddMode
        ;;
    *)
        runInStandardMode
        ;;


declare -a REFERVYS
declare -a REFERVSTUP
declare -a MYVYSTUP

declare -a ROZDILY

declare -a REFERVSTUPCUST
declare -a REFERVYSCUST
declare -a MYVYSTUPCUST

parseArg "$@"
doFilesExist
makeTempDir
unPack
saveRefOut
saveRefIn
saveOurOut
testAgRef
printRes
removeTempDir

























 
