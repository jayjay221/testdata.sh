term () {
    chyba "$2"
    removeTempDir
    exit "$1"
}

welcome () {
    local nazev="Testovaci skript pro PA1"
    
    printf "${BLUE}${BOLD}%s %s${NORMAL}\n" "$nazev" "$VERZE"
    printf "${BLUE}%s %s${NORMAL}\n" "$AUTOR" "$ROK"
    printf "${BLUE}%s${NORMAL}\n" "$URL"
}

ctrl_c () {
        term 5 "Skript nasilne ukoncen"
        
}

