runInAddMode () {
    ADD="testdata_io"
    prepareDir "$workdir"
    
    
    
}


prepareDir () {
    if [ ! -d "$1" ]
    then
        mkdir "$1"
        if [ "$?" -ne 0 ]
        then
        term "6" "Nelze vytvorit adresar pro custom data"
        fi
    fi
}



readData () {

    
    printf "$(zelena $(tucne %s))\n" "Skript byl spusten v rezimu IO"
    printf "$(zelena $(tucne %s))\n" "Zadej vzorova vstupni data"
    
    NAZEVIN=$(printf "custom_input_%08d.txt" "0")
    NAZEVOUT=$(printf "custom_output_%08d.txt" "0")
    
    i=0
    for SOUBOR in $(ls -v testdata_io)
    do
        if [ "$SOUBOR" = "$NAZEVIN" ]
        then
            ((i++))
            NAZEVIN=$(printf "custom_input_%08d.txt" "$i")
            NAZEVOUT=$(printf "custom_output_%08d.txt" "$i")
        else
            break
        fi
    done
    
    
    
    VSTUP=$(cat)
    printf "%s" "$VSTUP" > "testdata_io/$NAZEVIN"
    
    
    printf "\n$(zelena $(tucne %s))\n" "Nyni zadej vzorova vystupni data."
    
    VSTUP=$(cat)
    printf "%s" "$VSTUP" > "testdata_io/$NAZEVOUT"
    
    printf "\n$(zelena $(tucne %s))\n" "Data byla ulozena do \"testdata_io/$NAZEVIN, $NAZEVOUT\""
}
