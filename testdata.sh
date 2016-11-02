#!/bin/bash

# TODO
# vyrobit funkce!!!
# funkce pro barvy
# je to docela bordel tedka
# konfiguracni soubor
# prizpusobit format diffu (problem asi)
# pouzit printf misto echo
# zavest log do FS

AUTOR="Jakub Jun"
ROK="2016"
URL="https://github.com/jayjay221/testdata.sh"
VERZE="0.2.0"

TMPDIR="/tmp/testdata"


# Funkce formatovani

tucne () {
    printf "\e[1m%s\e[21m" "$1"
}

podtrzene () {
    printf "\e[4m%s\e[24m" "$1"
}

# Funkce barev

cervena () {
    printf "\e[31m%s\e[39m" "$1"
}

modra () {
    printf "\e[34m%s\e[39m" "$1"
}

zelena () {
    printf "\e[32m%s\e[39m" "$1"
}

tyrkysova () {
    printf "\e[36m%s\e[39m" "$1"
}

zluta () {
    printf "\e[33m%s\e[39m" "$1"
}

chyba () {
    printf "$(cervena "$(tucne ERROR): %s")\n" "$1"
}

# Funkce pro terminaci
term () {
    chyba "$2"
    exit "$1"
}

welcome () {
    local NAZEV="Testovaci skript pro PA1"
    
    printf "$(tyrkysova "$(tucne %s) %s")\n" "$NAZEV" "$VERZE"
    printf "$(modra "%s %s")\n" "$AUTOR" "$ROK"
    printf "$(modra %s)\n" "$URL"
}

parseArg () {
    # Byly vubec zadany argumenty?
    if [ -z "${2+xxx}" ];
    then 
        ARCHIV="sample.tgz"
    fi

    if [ -z "${1+xxx}" ];
    then
        PROGRAM="./a.out"
    fi
    
    # Jsou cesty absolutni nebo relativni?
    local initialarch="$(printf "%s" "$ARCHIV" | head -c 1)"
    local initialprog="$(printf "%s" "$PROGRAM" | head -c 1)"

    if [  "$initialarch" != "/" ];
    then
        ARCHIV="$(pwd)/$ARCHIV"
    fi

    if [  "$initialprog" != "/" ];
    then
        PROGRAM="$(pwd)/$PROGRAM"
    fi
}

doFilesExist () {
    # Existuji soubory?
    if [ ! -e "$PROGRAM" ]
    then
        term "5" "\"$PROGRAM\" neexistuje"
    fi

    if [ ! -e "$ARCHIV" ]
    then
        term "5" "\"$ARCHIV\" neexistuje"
    fi
}

makeTempDir () {
    # Vytvorime si tmp adresare pro praci se soubory
    if  ! mkdir "$TMPDIR" > "/dev/null" 2>&1 ;
    then
        term "1" "Nelze vytvorit \"$TMPDIR\""
    fi
    if  ! mkdir -p "$TMPDIR/referencni_archiv" > "/dev/null" 2>&1 ;
    then
        term "1" "Nelze vytvorit \"$TMPDIR/referencni_archiv\""
    fi
    if  ! mkdir -p "$TMPDIR/vysledky" > "/dev/null" 2>&1 ;
    then
        term "1" "Nelze vytvorit \"$TMPDIR/vysledky\""
    fi
}

unPack () {
    # Rozbalime archiv
    if  ! tar -C "$TMPDIR/referencni_archiv" -xvf "$ARCHIV" > "/dev/null" 2>&1 ;
    then
        term "2" "Nelze rozbalit \"$ARCHIV\" do \"$TMPDIR/referencni_archiv\""
    fi
}

saveRefOut () {
    # Pripravime pole s referencnimi vystupy
    # Iterator nastavime na 0
    local i=0

    # Postupne si ulozime referencni vystupy do pole
    for SOUBOR in $(ls -v $TMPDIR/referencni_archiv/CZE/*_out.txt);
    do
        REFERVYS[$i]="$SOUBOR"
        ((i++))
    done
}

saveRefIn () {
    # To same nyni s vstupy
    local i=0

    for SOUBOR in $(ls -v $TMPDIR/referencni_archiv/CZE/*_in.txt);
    do
        REFERVSTUP[$i]="$SOUBOR"
        ((i++))
    done
}

saveOurOut () {
    # A jeste s vystupy naseho programu
    local i=0

    for SOUBOR in ${REFERVSTUP[*]};
    do
        ITER=$(printf "%04d" $i)
        # Nasledujici prikaz potreba osetrit.
        $PROGRAM < $SOUBOR > "$TMPDIR/vysledky/${ITER}_myout.txt" ;
        MYVYSTUP[$i]="$TMPDIR/vysledky/${ITER}_myout.txt"
        ((i++))
    done
}

testAgRef () {
    # Spocitame chyby
    chyby=0
    local POCET=${#REFERVYS[@]}
    POCET=${#POCET}
    local i=0
    for SOUBOR in ${REFERVYS[*]};
    do
        printf "$(tucne "Vystup %*d:")" "$POCET" "$i"
        # Porovnavame, pri rozdilu inkrementujeme $chyby
        ROZDILY[$i]="$(diff --old-group-format "" --new-group-format "" --unchanged-group-format "" --changed-group-format "$(tucne "[$(tyrkysova "%-1.1dL")]$(cervena ty)"): %>$(tucne "[$(tyrkysova "%-1.1dL")]$(zelena ref)"): %<" "$SOUBOR" "${MYVYSTUP[$i]}" 2>&1)"
        if [ $? == 1 ];
        then
            printf " $(tucne "$(cervena %6s)")\n" "CHYBA"
            ((chyby++))
        else
            ROZDILY[$i]=""
            printf " $(tucne "$(zelena %3s)")\n" "OK"
        fi
        ((i++))
    done

    printf "$(tucne $(tyrkysova %s))\n" "--------------"
    
    local i=0
    for ROZDIL in "${ROZDILY[@]}";
    do
        if [ "$ROZDIL" != "" ];
        then
            #echo -e "${colorred}${formatbold}Vystup $((i)) [${coloryellow}$(basename ${REFERVYS[i]})${colorred}]${formatboldreset}${colorreset}"
            printf "$(tucne "$(cervena "Vystup %d") [$(zluta %s)]")\n" "$i" "$(basename ${REFERVYS[i]})"
            printf "%s\n" "$ROZDIL"
            printf "$(zluta %s)\n" "-----------------------------"
        fi
        ((i++))
    done
}

printRes () {
    # Oznamime vysledek
    if [ $chyby == 0 ];
    then
        # Uspech
        printf "$(tucne $(zelena %s))\n" "vse je v poradku"
    else
        # Neuspech
        printf "$(tucne $(tyrkysova %s))\n" "--------------"
        printf "$(cervena "$(tucne "%d vystupu nesedi")")\n" "$chyby"
    fi
}

removeTempDir () {
# Uklidime po sobe
    if  ! rm -rf "$TMPDIR" > "/dev/null" 2>&1 ;
    then
        term "4" "Nelze smazat \"$TMPDIR\""
    fi

    exit 0
}


# Uvodni zprava
welcome

# Argumenty
ARCHIV=$2
PROGRAM=$1

declare -a REFERVYS
declare -a REFERVSTUP
declare -a MYVYSTUP
declare -a ROZDILY

parseArg
doFilesExist
makeTempDir
unPack
saveRefOut
saveRefIn
saveOurOut
testAgRef
printRes
removeTempDir
























 
