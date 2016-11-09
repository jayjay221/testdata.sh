runInAddMode () {
    prepareDir
    #printf "${MAGENTA}%s${NORMAL}\n" "Skript byl spusten v rezimu IO"
    #printf "${MAGENTA}%s${NORMAL}\n" "Zadej vzorova vstupni data"
    readData
    
    
    
}


prepareDir () {
    if [ ! -d "$CUSTOMOUTDIR" ]
    then
        mkdir "$CUSTOMOUTDIR"
        if [ "$?" -ne 0 ]
        then
        term "6" "Nelze vytvorit adresar pro custom data"
        fi
    fi
}



readData () {
    local i=0
    for soubor in $(ls -v $CUSTOMOUTDIR)
    do
        if [ "$soubor" = "$NAZEVIN" ]
        then
            ((i++))
            NAZEVIN=$(printf "custom_input_%08d.txt" "$i")
            NAZEVOUT=$(printf "custom_output_%08d.txt" "$i")
        else
            break
        fi
    done
    
    
    if ! hash "$EDITOR"
    then
      term "9" "Pro spusteni add rezimu je potreba mit v promenne \$EDITOR spustitelny editor textovych souboru"
    fi
    
    
    
    > "$CUSTOMOUTDIR/$NAZEVIN"
    
    if [ "$?" -ne 0 ]
    then
        term "7" "Nelze zapisovat do \"$CUSTOMOUTDIR\""
    fi
    
    
    
    
    
    
    $EDITOR "$CUSTOMOUTDIR/$NAZEVIN"

    
    
    #local vstup=$(cat)
    #printf "%s" "$vstup" > "$CUSTOMOUTDIR/$NAZEVIN"
    
    #if [ "$?" -ne 0 ]
    #then
    #    term "7" "Nelze zapisovat do \"$CUSTOMOUTDIR\""
    #fi
    
    #printf "\n${GREEN}%s${NORMAL}\n" "Nyni zadej vzorova vystupni data."
    
    
    
    > "$CUSTOMOUTDIR/$NAZEVOUT"
    
    if [ "$?" -ne 0 ]
    then
        term "7" "Nelze zapisovat do \"$CUSTOMOUTDIR\""
    fi
    
    
    $EDITOR "$CUSTOMOUTDIR/$NAZEVOUT"
    
    
   
    printf "${GREEN}%s${NORMAL}\n" "Data byla ulozena do \"$CUSTOMOUTDIR/$NAZEVIN, $NAZEVOUT\""

  
    
    
    
    
}
