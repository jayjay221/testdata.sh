runInWDMode () {
  parsePaths
  
  printf "${BOLD}${MAGENTA}%s${NORMAL}\n" "Skript bezi v rezimu watchdog. Sledovany soubor: $WDFILE"
  
  
  inotifywait -q -m -e moved_to . |
  while read -r directory events filename; do
    [ "$filename" = "$(basename $WDFILE)" ] && fileSaved
  done
  
}

fileSaved () {
  if ! gcc -Wall -pedantic -Wno-long-long -lm "$WDFILE" -o "temp.out" 1>&2 2>/dev/null
  then
    notify-send -i "computer-fail" -t 2000 "Chyba pri kompilaci. ($?)"

  else
    PROGRAM="$(pwd)/temp.out"
    makeTempDir # Vytvoreni docasneho adresare
    unPack # Rozbaleni referencniho archivu
    saveRefOut # Ulozeni referencnich vystupu
    saveRefIn # Ulozeni referencncich vstupu
    saveOurOut # Ulozeni nasich vystupu
    testAgRef
    removeTempDir
    
    if [ $((CHYBY+CHYBYCUST)) == 0 ] # Pokud nejsou zadne chyby
    then
      notify-send -i "info" -t 2000 "Uspech" "Program prosel vsechny testy."
    else
      # Vypiseme nespokojenou hlasku obsahujici kolik chyb bylo nalezeno a kde
      notify-send -i "error" -t 2000 "Neuspech" "$CHYBY chyb z reference, $CHYBYCUST chyb z vlastnich testu."

    fi
  fi
  
  
  
}

