

parsePaths () {

    expandArgPaths
    doFilesExist

}

# Funkce testujici existenci a pouzitelnost souboru
doFilesExist () {
    if [ ! -e "$PROGRAM" ]
    then
        term "5" "\"$PROGRAM\" neexistuje"
    else
        if [ ! -x "$PROGRAM" ]
        then
            term "6" "\"$PROGRAM\" nelze spustit"
        fi
    fi

    if [ ! -e "$ARCHIV" ]
    then
        term "5" "\"$ARCHIV\" neexistuje"
    fi
}

# Rozebereme si kazdej parametr a uplatnime jeho vyznam
iterateArgs () {

    while [ -n "$1" ]
    do
        case "$1" in
        "-c")
            MODE="custom"
            ;;
        "add")
            MODE="add"
            ;;
        *".out")
            PROGRAM="$1"
            ;;
        *".tgz")
            ARCHIV="$1"
            ;;
        esac
        
        shift
    done
}

# Funkce doplni neexistujici parametry a expanduje cesty
expandArgPaths () {
    
    # Domyslime si parametry, kdyz je nikdo nezadal
    if [ -z "$ARCHIV" ];
    then 
        ARCHIV="sample.tgz"
    fi

    if [ -z "$PROGRAM" ];
    then
        PROGRAM="./a.out"
    fi
    
    # Expandujeme relativni cestu
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
