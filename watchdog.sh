runInWDMode () {
  parsePaths
  
  printf "${BOLD}${MAGENTA}%s${NORMAL}\n" "Skript bezi v rezimu watchdog. Sledovany soubor: $WDFILE"
  
  
  inotifywait -q -m -e moved_to . |
  while read -r directory events filename; do
    [ "$filename" = "$(basename $WDFILE)" ] && fileSaved
  done
  
}

fileSaved () {

  notify-send hovno

  if ! gcc -Wall -pedantic -lm "$WDFILE" -o temp.out
  then
    notify-send "Chyba pri kompilaci. ($?)"

  else
  
    makeTempDir # Vytvoreni docasneho adresare
    unPack # Rozbaleni referencniho archivu
    saveRefOut # Ulozeni referencnich vystupu
    saveRefIn # Ulozeni referencncich vstupu
    saveOurOut # Ulozeni nasich vystupu
    testAgRef # Test vystupu proti referenci
    removeTempDir
  
  
  fi
  
  
  
  
}

