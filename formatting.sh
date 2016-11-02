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
