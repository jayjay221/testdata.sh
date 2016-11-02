# Funkce pro terminaci
makeTempDir () {
    # Vytvorime si tmp adresare pro praci se soubory
    mkdir "$TMPDIR" > "/dev/null" 2>&1 ;
    if [ "$?" -ne 0 ]
    then
        term "1" "Nelze vytvorit \"$TMPDIR\""
    fi
    
    mkdir -p "$TMPDIR/referencni_archiv" > "/dev/null" 2>&1
    if [ "$?" -ne 0 ]
    then
        term "1" "Nelze vytvorit \"$TMPDIR/referencni_archiv\""
    fi
    
    mkdir -p "$TMPDIR/vysledky" > "/dev/null" 2>&1
    if [ "$?" -ne 0 ]
    then
        term "1" "Nelze vytvorit \"$TMPDIR/vysledky\""
    fi
}

unPack () {
    # Rozbalime archiv
    tar -C "$TMPDIR/referencni_archiv" -xvf "$ARCHIV" > "/dev/null" 2>&1 
    if [ "$?" -ne 0 ]
    then
        term "2" "Nelze rozbalit \"$ARCHIV\" do \"$TMPDIR/referencni_archiv\""
    fi
}

saveRefOut () {
    # Pripravime pole s referencnimi vystupy
    # Iterator nastavime na 0
    local i=0

    # Postupne si ulozime referencni vystupy do pole
    for SOUBOR in $(ls -v $TMPDIR/referencni_archiv/CZE/*_out.txt)
    do
        REFERVYS[$i]="$SOUBOR"
        ((i++))
    done
    
    
    if [ "$MODE" = "custom" ]
    then
        local i=0
        for SOUBOR in $(ls -v testdata_io/custom_output_*)
        do
            REFERVYSCUST[$i]="$SOUBOR"
            ((i++))
        done
    fi
}

saveRefIn () {
    # To same nyni s vstupy
    local i=0

    for SOUBOR in $(ls -v $TMPDIR/referencni_archiv/CZE/*_in.txt)
    do
        REFERVSTUP[$i]="$SOUBOR"
        ((i++))
    done
    
    if [ "$MODE" = "custom" ]
    then
        local i=0
        for SOUBOR in $(ls -v testdata_io/custom_input_*)
        do
            REFERVSTUPCUST[$i]="$SOUBOR"
            ((i++))
        done
    fi   
}

saveOurOut () {
    # A jeste s vystupy naseho programu
    local i=0
    for SOUBOR in ${REFERVSTUP[*]};
    do
        local iter=$(printf "%04d" $i)
        # Nasledujici prikaz potreba osetrit.
        $PROGRAM < $SOUBOR > "$TMPDIR/vysledky/${iter}_myout.txt"
        MYVYSTUP[$i]="$TMPDIR/vysledky/${iter}_myout.txt"
        ((i++))
    done
    
    if [ "$MODE" = "custom" ]
    then
        local i=0
        for SOUBOR in ${REFERVSTUPCUST[*]};
        do
            local iter=$(printf "%08d" $i)
            # Nasledujici prikaz potreba osetrit.
            $PROGRAM < $SOUBOR > "$TMPDIR/vysledky/${iter}_cust_myout.txt"
            MYVYSTUPCUST[$i]="$TMPDIR/vysledky/${iter}_cust_myout.txt"
            ((i++))
        done
    fi   
}

testAgRef () {
    # Spocitame chyby
    CHYBY=0
    local pocet=${#REFERVYS[@]}
    pocet=${#pocet}
    local i=0
    for SOUBOR in ${REFERVYS[*]};
    do
        printf "$(tucne "Vystup %*d:")" "$POCET" "$i"
        # Porovnavame, pri rozdilu inkrementujeme $chyby
        ROZDILY[$i]="$(diff --old-group-format "" --new-group-format "" --unchanged-group-format "" --changed-group-format "$(tucne "[$(tyrkysova "%-1.1dL")] $(cervena ty)"): %>$(tucne "[$(tyrkysova "%-1.1dL")]$(zelena ref)"): %<" "$SOUBOR" "${MYVYSTUP[$i]}" 2>&1)"
        if [ $? == 1 ];
        then
            printf " $(tucne "$(cervena %6s)")\n" "CHYBA"
            ((chyby++))
        else
            ROZDILY[$i]=""
            printf " $(tucne "$(zelena %3s)")\n" "OK"
        fi
        ((i++))
    done
    
    if [ "$MODE" = "custom" ]
    then
        chybycust=0
        local pocet=${#REFERVYSCUST[@]}
        pocet=${#pocet}
        local i=0
        for SOUBOR in ${REFERVYSCUST[*]};
        do
            printf "$(tucne "Vystup %*d:")" "$POCET" "$i"
            # Porovnavame, pri rozdilu inkrementujeme $chyby
            ROZDILYCUST[$i]="$(diff --old-group-format "" --new-group-format "" --unchanged-group-format "" --changed-group-format "$(tucne "[$(tyrkysova "%-1.1dL")] $(cervena ty)"): %>$(tucne "[$(tyrkysova "%-1.1dL")]$(zelena ref)"): %<" "$SOUBOR" "${MYVYSTUPCUST[$i]}" 2>&1)"
            if [ $? == 1 ];
            then
                printf " $(tucne "$(cervena %6s)")\n" "CHYBA"
                ((chybycust++))
            else
                ROZDILYCUST[$i]=""
                printf " $(tucne "$(zelena %3s)")\n" "OK"
            fi
            ((i++))
        done
    fi

    printf "$(tucne $(tyrkysova %s))\n" "--------------"
    
    local i=0
    for ROZDIL in "${ROZDILY[@]}";
    do
        if [ "$ROZDIL" != "" ];
        then
            #echo -e "${colorred}${formatbold}Vystup $((i)) [${coloryellow}$(basename ${REFERVYS[i]})${colorred}]${formatboldreset}${colorreset}"
            printf "$(tucne "$(cervena "Vystup %d") [$(zluta %s)]")\n" "$i" "$(basename ${REFERVYS[i]})"
            printf "%s\n" "$ROZDIL"
            printf "$(zluta %s)\n" "-----------------------------"
        fi
        ((i++))
    done
    
    if [ "$MODE" = "custom" ]
    then
        for ROZDIL in "${ROZDILYCUST[@]}";
        do
            local k=0
            if [ "$ROZDIL" != "" ];
            then
                
                #echo -e "${colorred}${formatbold}Vystup $((i)) [${coloryellow}$(basename ${REFERVYSCUST[i]})${colorred}]${formatboldreset}${colorreset}"
                printf "$(tucne "$(cervena "Vystup %d") [$(zluta %s)]")\n" "$k" "$(basename ${REFERVYSCUST[k]})"
                printf "%s\n" "$ROZDIL"
                printf "$(zluta %s)\n" "--------------------ddddd---------"
            fi
            ((i++))
        done
    fi
}


printRes () {
    # Oznamime vysledek
    if [ $chyby == 0 ];
    then
        # Uspech
        printf "$(tucne $(zelena %s))\n" "vse je v poradku"
    else
        # Neuspech
        printf "$(tucne $(tyrkysova %s))\n" "--------------"
        printf "$(cervena "$(tucne "%d vystupu nesedi")")\n" "$chyby"
    fi
}

removeTempDir () {
# Uklidime po sobe
    if  ! rm -rf "$TMPDIR" > "/dev/null" 2>&1 ;
    then
        term "4" "Nelze smazat \"$TMPDIR\""
    fi

    exit 0
}
