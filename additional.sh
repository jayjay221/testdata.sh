term () {
    chyba "$2"
    removeTempDir
    exit "$1"
}

welcome () {
    local nazev="Testovaci skript pro PA1"
    
    printf "$(tyrkysova "$(tucne %s) %s")\n" "$nazev" "$VERZE"
    printf "$(modra "%s %s")\n" "$AUTOR" "$ROK"
    printf "$(modra %s)\n" "$URL"
}

