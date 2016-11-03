#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $SCRIPTDIR/formatting.sh
source $SCRIPTDIR/meta.sh
source $SCRIPTDIR/argparse.sh
source $SCRIPTDIR/read.sh
source $SCRIPTDIR/testing.sh
source $SCRIPTDIR/additional.sh
source $SCRIPTDIR/standard.sh

# Globalni promenne
TMPDIR="/tmp/testdata"
MODE=""
ARCHIV=""
PROGRAM=""
CUSTOMOUTDIR="testdata_io"
NAZEVIN=$(printf "custom_input_%08d.txt" "0")
NAZEVOUT=$(printf "custom_output_%08d.txt" "0")
CHYBY=0
CHYBYCUST=0

declare -a REFERVYS
declare -a REFERVSTUP
declare -a MYVYSTUP
declare -a ROZDILY

declare -a REFERVSTUPCUST
declare -a REFERVYSCUST
declare -a MYVYSTUPCUST
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
























 
