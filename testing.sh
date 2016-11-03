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
    for soubor in $(ls -v $TMPDIR/referencni_archiv/CZE/*_out.txt)
    do
        REFERVYS[$i]="$soubor"
        ((i++))
    done
    
    
    if [ "$MODE" = "custom" ]
    then
        i=0
        for soubor in $(ls -v testdata_io/custom_output_* 2>/dev/null)
        do
            REFERVYSCUST[$i]="$soubor"
            ((i++))
        done
    fi
}

saveRefIn () {
    # To same nyni s vstupy
    local i=0

    for soubor in $(ls -v $TMPDIR/referencni_archiv/CZE/*_in.txt 2>/dev/null)
    do
        REFERVSTUP[$i]="$soubor"
        ((i++))
    done
    
    if [ "$MODE" = "custom" ]
    then
        i=0
        for soubor in $(ls -v testdata_io/custom_input_* 2>/dev/null)
        do
            REFERVSTUPCUST[$i]="$soubor"
            ((i++))
        done
    fi   
}

saveOurOut () {
    # A jeste s vystupy naseho programu
    local i=0
    for soubor in "${REFERVSTUP[@]}"
    do
        local iter=$(printf "%04d" $i)
        # Nasledujici prikaz potreba osetrit.
        $PROGRAM < $soubor > "$TMPDIR/vysledky/${iter}_myout.txt"
        MYVYSTUP[$i]="$TMPDIR/vysledky/${iter}_myout.txt"
        ((i++))
    done
    
    if [ "$MODE" = "custom" ]
    then
        i=0
        for soubor in "${REFERVSTUPCUST[@]}"
        do
            iter=$(printf "%08d" $i)
            # Nasledujici prikaz potreba osetrit.
            $PROGRAM < $soubor > "$TMPDIR/vysledky/${iter}_cust_myout.txt"
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
    printf "$(tucne $(zluta %s))\n" "Testy z archivu"
    for soubor in ${REFERVYS[*]};
    do
        printf "$(tucne "Vystup %*d:")" "$pocet" "$i"
        # Porovnavame, pri rozdilu inkrementujeme $chyby
        ROZDILY[$i]="$(diff  --old-line-format "$(tucne "[$(tyrkysova "%-1dn")]$(zelena ref):") %l%c'\012'" --new-line-format "$(tucne "[$(tyrkysova "%-1dn")]$(cervena " ty"):") %l%c'\012'" --unchanged-line-format "" "$soubor" "${MYVYSTUP[$i]}" 2>/dev/null)"
        if [ $? == 1 ];
        then
            printf " $(tucne "$(cervena %6s)")\n" "CHYBA"
            ((CHYBY++))
        else
            ROZDILY[$i]=""
            printf " $(tucne "$(zelena %3s)")\n" "OK"
        fi
        ((i++))
    done
    
    if [ "$MODE" = "custom" ]
    then
        CHYBYCUST=0
        pocet=${#REFERVYSCUST[@]}
        pocet=${#pocet}
        i=0
        printf "$(tucne $(zluta %s))\n" "Vlastni testy"
        for soubor in ${REFERVYSCUST[*]};
        do
            printf "$(tucne "Vystup %*d:")" "$pocet" "$i"
            # Porovnavame, pri rozdilu inkrementujeme $chyby
            ROZDILYCUST[$i]="$(diff  --old-line-format "$(tucne "[$(tyrkysova "%-1dn")]$(zelena ref):") %l%c'\012'" --new-line-format "$(tucne "[$(tyrkysova "%-1dn")]$(cervena " ty"):") %l%c'\012'" --unchanged-line-format "" "$soubor" "${MYVYSTUPCUST[$i]}" 2>/dev/null)"
            if [ $? == 1 ];
            then
                printf " $(tucne "$(cervena %6s)")\n" "CHYBA"
                ((CHYBYCUST++))
            else 
                ROZDILYCUST[$i]=""
                printf " $(tucne "$(zelena %3s)")\n" "OK"
            fi
            ((i++))
        done
    fi

    printf "$(tucne $(tyrkysova %s))\n" "--------------"
    
    i=0
    #  "${MYVYSTUPCUST[0]}"
    for rozdil in "${ROZDILY[@]}";
    do
        if [ "$rozdil" != "" ];
        then
            #echo -e "${colorred}${formatbold}Vystup $((i)) [${coloryellow}$(basename ${REFERVYS[i]})${colorred}]${formatboldreset}${colorreset}"
            printf "$(tucne "[$(cervena progtest)]$(cervena "Vystup %d") [$(zluta %s)]")\n" "$i" "$(basename ${REFERVYS[i]})"
            printf "%s\n" "$rozdil"
            printf "$(zluta %s)\n" "-----------------------------"
        fi
        ((i++))
    done
    
    if [ "$MODE" = "custom" ]
    then
        i=0
        for rozdil in "${ROZDILYCUST[@]}";
        do
            if [ "$rozdil" != "" ];
            then
                
                #echo -e "${colorred}${formatbold}Vystup $((i)) [${coloryellow}$(basename ${REFERVYSCUST[i]})${colorred}]${formatboldreset}${colorreset}"
                printf "$(tucne "[$(zluta vlastni)] $(cervena "Vystup %d") [$(zluta %s)]")\n" "$i" "$(basename ${REFERVYSCUST[i]})"
                printf "%s\n" "$rozdil"
                printf "$(zluta %s)\n" "-----------------------------"
            fi
            ((i++))
        done
    fi
}


printRes () {
    # Oznamime vysledek
    if [ $((CHYBY+CHYBYCUST)) == 0 ];
    then
        # Uspech
        printf "$(tucne $(zelena %s))\n" "vse je v poradku"
    else
        # Neuspech
        printf "$(tucne $(tyrkysova %s))\n" "--------------"
        printf "$(tucne "$(cervena "%d vystupu nesedi") ($(zluta %d) archiv, $(zluta %d) vlastni)")\n" "$((CHYBY+CHYBYCUST))" "$CHYBY" "$CHYBYCUST"
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
