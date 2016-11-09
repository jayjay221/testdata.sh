runInAddMode () {
    prepareDir
    printf "${MAGENTA}%s${NORMAL}\n" "Skript byl spusten v rezimu IO"
    printf "${MAGENTA}%s${NORMAL}\n" "Zadej vzorova vstupni data"
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
    
    
    
    
    > "$CUSTOMOUTDIR/$NAZEVIN"
    
    if [ "$?" -ne 0 ]
    then
        term "7" "Nelze zapisovat do \"$CUSTOMOUTDIR\""
    fi
    
    while read line
    do
    if [ "$line" != "" ]
    then
        printf "%s\n" "$line" >> "$CUSTOMOUTDIR/$NAZEVIN"
    fi
    done

    
    
    #local vstup=$(cat)
    #printf "%s" "$vstup" > "$CUSTOMOUTDIR/$NAZEVIN"
    
    #if [ "$?" -ne 0 ]
    #then
    #    term "7" "Nelze zapisovat do \"$CUSTOMOUTDIR\""
    #fi
    
    printf "\n${GREEN}%s${NORMAL}\n" "Nyni zadej vzorova vystupni data."
    
    
    > "$CUSTOMOUTDIR/$NAZEVOUT"

    if [ "$?" -ne 0 ]
    then
        term "7" "Nelze zapisovat do \"$CUSTOMOUTDIR\""
    fi
    
    while read line
    do
    if [ "$line" != "" ]
    then
        printf "%s\n" "$line" >> "$CUSTOMOUTDIR/$NAZEVOUT"
    fi
    done
    
    
    printf "\n${GREEN}%s${NORMAL}\n" "Data byla ulozena do \"$CUSTOMOUTDIR/$NAZEVIN, $NAZEVOUT\""
}
