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
