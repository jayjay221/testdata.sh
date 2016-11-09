# Spusteni ve standardnim rezimu
runInStandardMode () {
    parsePaths # Rozebrani scest k souborum
    makeTempDir # Vytvoreni docasneho adresare
    unPack # Rozbaleni referencniho archivu
    saveRefOut # Ulozeni referencnich vystupu
    saveRefIn # Ulozeni referencncich vstupu
    saveOurOut # Ulozeni nasich vystupu
    testAgRef # Test vystupu proti referenci
    printRes # Tisk shrnuti
    removeTempDir # Smazani docasneho adresare
}
