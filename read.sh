runInAddMode () {
    prepareDir
    printf "$(zelena $(tucne %s))\n" "Skript byl spusten v rezimu IO"
    printf "$(zelena $(tucne %s))\n" "Zadej vzorova vstupni data"
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
    
    
    
    local vstup=$(cat)
    printf "%s" "$vstup" > "$CUSTOMOUTDIR/$NAZEVIN"
    
    if [ "$?" -ne 0 ]
    then
        term "7" "Nelze zapisovat do \"$CUSTOMOUTDIR\""
    fi
    
    printf "\n$(zelena $(tucne %s))\n" "Nyni zadej vzorova vystupni data."
    

    vstup=$(cat)
    printf "%s" "$vstup" > "$CUSTOMOUTDIR/$NAZEVOUT"
    
    if [ "$?" -ne 0 ]
    then
        term "7" "Nelze zapisovat do \"$CUSTOMOUTDIR\""
    fi
    
    
    printf "\n$(zelena $(tucne %s))\n" "Data byla ulozena do \"$CUSTOMOUTDIR/$NAZEVIN, $NAZEVOUT\""
}
