BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)
BOLD=$(tput bold)

chyba () {
    printf "${BOLD}${RED}ERROR: %s${NORMAL}\n" "$1"
}

setField () {
  if [ $1 -gt ${FIELDWIDTH[1]} ]
  then
    FIELDWIDTH[1]=$1
  fi
}

printLine () {
  printf "${MAGENTA}${BOLD}%s${NORMAL}\n" "${LINEWIDTH// /-}"
}
