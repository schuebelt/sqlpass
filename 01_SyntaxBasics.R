# 1. Zentrale Syntax-Charakteristika -------------------------------------------------------------------
# 
# - R ist eine Interpretersprache
# - Case-sensitive
# - Objekt definiert (per Konvention) durch Zuweisungsoperator <-
#      - vector (character, numeric, integer, logical, etc.), muss bei Zuweisung i.d.R. nicht expliziert werden)
#      - data.frame
#      - model, etc.


# 2. Beispiel ------------------------------------------------------------------------------------------

# Objekt erstellen
name <- c("Bredlow", "Valentini","Ishak")
spiele <- c(12,23,22)
tore <- c(0,0,12)

spieler <- data.frame(name,spiele,tore)

# Objekt aufufen
spieler
Spieler # Error (R ist Case-sensitive)

spieler[2,]
spieler[,2]

spieler$spiele

# Funktion auf Objekt anwenden
mean(spieler$tore)




