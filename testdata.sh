#!/bin/bash

# Adresar tohoto souboru
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



# Odchyceni nasilneho ukonceni
trap ctrl_c INT

# Vlozene zdrojove kody obsahujici funkce - prehlednejsi kod
source $SCRIPTDIR/formatting.sh
source $SCRIPTDIR/meta.sh
source $SCRIPTDIR/argparse.sh
source $SCRIPTDIR/read.sh
source $SCRIPTDIR/testing.sh
source $SCRIPTDIR/additional.sh
source $SCRIPTDIR/standard.sh
source $SCRIPTDIR/watchdog.sh


# Globalni promenne
TMPDIR="/tmp/testdata" # Adresar pro docasne soubory
MODE="" # Rezim
ARCHIV="" # Cesta k archivu s referencnimi daty
PROGRAM="" # Cesta ke spustitelnemu souboru
WDFILE=""
CUSTOMOUTDIR="testdata_io" # Nazev adresare pro vlastni data
NAZEVIN=$(printf "custom_input_%08d.txt" "0") # Format nazvu vlastniho vstupu
NAZEVOUT=$(printf "custom_output_%08d.txt" "0") # Format nazvu vlastniho vystupu
CHYBY=0
CHYBYCUST=0
TIMEFORMAT='%4R'
LINEWIDTH=0

declare -a FIELDWIDTH

FIELDWIDTH[0]=6
FIELDWIDTH[1]=3
FIELDWIDTH[2]=7
FIELDWIDTH[3]=16

# Deklarace poli pro praci s vstupy a vystupy
  # Vychozi testy
declare -a REFERVYS # Referencni vystupy
declare -a REFERVSTUP # Referencni vstupy
declare -a MYVYSTUP # Nase vystupy
declare -a ROZDILY # Rozdily mezi ref. a nasimi vystupy
declare -a TIMING
  # Vlastni (custom) testy
declare -a REFERVSTUPCUST
declare -a REFERVYSCUST
declare -a MYVYSTUPCUST
declare -a ROZDILYCUST
declare -a TIMINGCUST

# Uvodni zprava
welcome

# Parsovani argumentu
iterateArgs "$@"

# Spustime skript podle rezimu nastavenem v argumentu
case "$MODE" in
    "add") # Rezim pridavani dat
        runInAddMode
        ;;
    "watchdog")
        runInWDMode
        ;;
    *)  # Standardni rezim
        runInStandardMode
        ;;
esac
























 
