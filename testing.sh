# Funkce vytvarejici pripravujici docasne prostredi
makeTempDir () {
    mkdir "$TMPDIR" > "/dev/null" 2>&1 # Vytvorime si docasny adresar
    if [ "$?" -ne 0 ] # Selhani
    then
        term "1" "Nelze vytvorit \"$TMPDIR\""
    fi
    
    mkdir -p "$TMPDIR/referencni_archiv" > "/dev/null" 2>&1 # Vytvorime adresar pro rozbaleni reference
    if [ "$?" -ne 0 ] # Selhani
    then
        term "1" "Nelze vytvorit \"$TMPDIR/referencni_archiv\""
    fi
    
    mkdir -p "$TMPDIR/vysledky" > "/dev/null" 2>&1 # Adresar pro vysldky
    if [ "$?" -ne 0 ] # Selhani
    then
        term "1" "Nelze vytvorit \"$TMPDIR/vysledky\""
    fi
}

# Funkce pro rozbaleni archivu
unPack () {
    tar -C "$TMPDIR/referencni_archiv" -xvf "$ARCHIV" > "/dev/null" 2>&1 # Rozbalime archiv
    if [ "$?" -ne 0 ] # Selhani
    then
        term "2" "Nelze rozbalit \"$ARCHIV\" do \"$TMPDIR/referencni_archiv\""
    fi
}

# Funkce pro ulozeni referencniho vystupu do pole
saveRefOut () {
    local i=0 # Lokalni promenna citajici iterace

    for soubor in $(ls -v $TMPDIR/referencni_archiv/CZE/*_out.txt) # Projdeme kazdy vystupni ref. soubor
    do
        REFERVYS[$i]="$soubor" # Priradime nazev souboru do pole
        ((i++))
    done
    
    
    if [ "$MODE" = "custom" ] # Pri rezimu vlastnich dat ulozime jeste vlastni vystupy
    then
        i=0
        for soubor in $(ls -v testdata_io/custom_output_* 2>/dev/null) # Projdeme vsechny vlastni vystupy
        do
            REFERVYSCUST[$i]="$soubor" # Priradime nazev souboru do pole
            ((i++))
        done
    fi
}

# Funkce pro ulozeni referencniho vstupu do pole
saveRefIn () {
    local i=0 # Promenna iteraci

    for soubor in $(ls -v $TMPDIR/referencni_archiv/CZE/*_in.txt 2>/dev/null) # Projdeme kazdy referencni vstup
    do
        REFERVSTUP[$i]="$soubor" # Priradime nazev souboru do pole
        ((i++))
    done
    
    if [ "$MODE" = "custom" ] # Rezim vlastnich dat
    then
        i=0
        for soubor in $(ls -v testdata_io/custom_input_* 2>/dev/null) # Projdeme vlastni vstupy
        do
            REFERVSTUPCUST[$i]="$soubor" # Priradime nazev do pole
            ((i++))
        done
    fi   
}

# Funkce pro ulozeni naseho vystupu
saveOurOut () {
    local i=0 # Promenna iteraci
    for soubor in "${REFERVSTUP[@]}" # Projdeme kazdy nazev souboru v poli
    do
        local iter=$(printf "%04d" $i) # Vytvorime formatovanou hodnotu iterace
        $PROGRAM < $soubor > "$TMPDIR/vysledky/${iter}_myout.txt" # Posleme do naseho programu aktualni soubor z pole a vysledek ulozime do docasneho adresare
        MYVYSTUP[$i]="$TMPDIR/vysledky/${iter}_myout.txt" # Jmeno vytvoreneho souboru si ulozime do pole
        ((i++))
    done
    
    if [ "$MODE" = "custom" ] # Rezim vlastnich dat
    then
        # Opakuje se predesla cast kodu, pouze iterujeme pres vlastni vstupy, lisi se format vystupu
        # a prirazujeme do jineho pole
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

# Funkce testujici vysledky proti referenci
testAgRef () {
    CHYBY=0 # Nastavime globalni promennou s poctem chyb
    # Nasleduje pokus o esteticke formatovani finalniho vystupu
    local pocet="${#REFERVYS[@]}" # notace '${#foo}' vypise ?pocet pismen? pro obycejnou promennou a pocet prvku v poli
    pocet=${#pocet} # Pocet cifer v prvcich pole
    local i=0
    printf "$(tucne $(zluta %s))\n" "Testy z archivu" # Vytiskneme nadpis predchazejici vysledky testu proti referenci
    for soubor in "${REFERVYS[@]}" # Iterujeme referencnimi vystupy
    do
        printf "$(tucne "Vystup %*d:")" "$pocet" "$i" # Vytiskneme radky obsahujici vysledky jednotlivych testu
        # Budeme porovnavat, pri rozdilu inkrementujeme $chyby
        # Je pouzit diff s custom formatovanim
        # Vysledny rozdil je zapsan do pole
        ROZDILY[$i]="$(diff  --old-line-format "$(tucne "[$(tyrkysova "%-1dn")]$(zelena ref):") %l%c'\012'" --new-line-format "$(tucne "[$(tyrkysova "%-1dn")]$(cervena " ty"):") %l%c'\012'" --unchanged-line-format "" "$soubor" "${MYVYSTUP[$i]}" 2>/dev/null)"
        if [ $? == 1 ] # Diff konci s kodem 1, kdyz nalezne rozdil
        then
            printf " $(tucne "$(cervena %6s)")\n" "CHYBA"
            ((CHYBY++))
        else
            ROZDILY[$i]="" # Nejsem si jisty, jestli je toto nutne
            printf " $(tucne "$(zelena %3s)")\n" "OK"
        fi
        ((i++))
    done
    
    if [ "$MODE" = "custom" ] # Rezim vlastnich dat
    then
        # Nasledujici cast kodu se shoduje s predchozi, pouze pracuje s vlastnimi vstupy a vystupy
        CHYBYCUST=0
        pocet="${#REFERVYSCUST[@]}"
        pocet=${#pocet}
        i=0
        printf "$(tucne $(zluta %s))\n" "Vlastni testy"
        for soubor in "${REFERVYSCUST[@]}"
        do
            printf "$(tucne "Vystup %*d:")" "$pocet" "$i"
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

    printf "$(tucne $(tyrkysova %s))\n" "--------------" # Oddelovac
    
    i=0
    # Podivame se na jednotlive rozdily
    for rozdil in "${ROZDILY[@]}" # Iterujeme vsemi rozdily
    do
        if [ "$rozdil" != "" ] # Pokud je rozdil prazdny
        then
            # Vypiseme nadpis, obsah a oddelovac
            printf "$(tucne "[$(cervena progtest)]$(cervena "Vystup %d") [$(zluta %s)]")\n" "$i" "$(basename ${REFERVYS[i]})"
            printf "%s\n" "$rozdil"
            printf "$(zluta %s)\n" "-----------------------------"
        fi
        ((i++))
    done
    
    if [ "$MODE" = "custom" ] # Opet lehce odlisny predchozi kod
    then
        i=0
        for rozdil in "${ROZDILYCUST[@]}"
        do
            if [ "$rozdil" != "" ]
            then
                
                printf "$(tucne "[$(zluta vlastni)] $(cervena "Vystup %d") [$(zluta %s)]")\n" "$i" "$(basename ${REFERVYSCUST[i]})"
                printf "%s\n" "$rozdil"
                printf "$(zluta %s)\n" "-----------------------------"
            fi
            ((i++))
        done
    fi
}

# Funkce tisknouci finalni vysledek
printRes () {
    if [ $((CHYBY+CHYBYCUST)) == 0 ] # Pokud nejsou zadne chyby
    then
        printf "$(tucne $(zelena %s))\n" "vse je v poradku"
    else
        printf "$(tucne $(tyrkysova %s))\n" "--------------"
        # Vypiseme nespokojenou hlasku obsahujici kolik chyb bylo nalezeno a kde
        printf "$(tucne "$(cervena "%d vystupu nesedi") ($(zluta %d) archiv, $(zluta %d) vlastni)")\n" "$((CHYBY+CHYBYCUST))" "$CHYBY" "$CHYBYCUST"
    fi
}



# Funkce odstranujici docasny adresar
removeTempDir () {
    if  ! rm -rf "$TMPDIR" > "/dev/null" 2>&1 # Pokud se nepovede smazat adresar
    then
        term "4" "Nelze smazat \"$TMPDIR\"" # Terminace
    fi
    exit 0
}
