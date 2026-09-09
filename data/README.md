# Passare da mock a dati raccolti

Questa cartella è il punto di passaggio più semplice tra una esercitazione con
dati simulati e una piccola raccolta reale. Non richiede di modificare R o la
Shiny.

1. Copiare i due file in `data/templates/` in `data/collected/`.
2. Assegnare un codice anonimo a ogni partecipante (`P001`, `P002`, …), senza
   nome, email, telefono o altri identificativi diretti.
3. Compilare una riga per item nel file delle risposte.
4. Eseguire:

```powershell
Rscript R/data/check_responses.R data/collected/responses.csv
```

Il comando non calcola un QI e non modifica file: dice solo se i dati usano
gli item, le età e gli stati previsti dalla batteria corrente. È il controllo
da fare prima di qualsiasi analisi.

`data/collected/` è ignorata da Git per evitare pubblicazioni accidentali di
dati raccolti. Per condividere dati, creare prima una versione davvero
anonimizzata e documentare autorizzazioni, consenso e finalità didattica.

I dati reali non trasformano automaticamente le norme simulate in norme
empiriche. Finché non esiste un protocollo di raccolta e analisi appropriato,
i risultati restano descrittivi e didattici.
