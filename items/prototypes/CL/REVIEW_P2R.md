# CL — report del prototipo revisionato P2R

## Ambito

P2R modifica soltanto la resa dei sei stimoli non definitivi della famiglia
`distinct_substitution`. I CSV e le chiavi di P2 sono rimasti invariati; non è
stato aggiunto alcun item e non è stato creato `items/source/CL.csv`.

Il comando di build resta:

```text
Rscript R/build/build_cl_prototype.R
```

Produce soltanto SVG e PNG A4 orizzontali. Gli output A3 di P2 sono stati
ritirati come deciso in P3.

## Modifiche verificate

- i sei token della spec sono associati uno a uno a primitive SVG versionate;
- vocabolario e mappa delle primitive devono coincidere esattamente, senza
  token mancanti, estranei o definizioni duplicate;
- i glifi non dipendono più da Segoe UI Symbol o da un altro font installato;
- ogni riga presenta `U` e `D` barrabili direttamente, senza caselle, cerchi o
  altri contenitori che possano competere con `□` o `○`;
- impaginazione, sei stimoli, tre chiavi `UGUALE`, tre chiavi `DIVERSO` e
  posizioni delle sostituzioni sono invariati;
- il foglio dichiara 297 × 210 mm, viene reso a 3508 × 2480 pixel a 300 dpi e
  mantiene la barra fisica da 50 mm.

## Ispezione visiva

Il PNG A4 è stato ispezionato a risoluzione originale. Tutti i glifi sono
nitidi e centrati nel reticolo; coppie sinistra/destra conservano metrica e
spaziatura identiche; non si osservano contatti fra simboli o indizi di
larghezza. Le lettere `U` e `D` sono leggibili, non hanno contenitore e restano
distinte sia dai glifi sia dal separatore fra le stringhe. Numeri, guide di riga
e passaggio fra colonne restano chiari.

L'ispezione digitale non sostituisce la prova su carta al 100%: marcabilità a
matita e stabilità della legenda per i partecipanti più giovani restano quesiti
per il gate P3R, non assunzioni chiuse da P2R.

## Riproducibilità e test

Due build consecutive hanno prodotto gli stessi SHA-256:

| File | SHA-256 |
|---|---|
| `CL_distinct_substitution_A4_landscape.svg` | `0840E56B802DFD29538E6D9D9CB6CC670E78BA529A7D649581FF31E6BCD6B3EA` |
| `CL_distinct_substitution_A4_landscape_300dpi.png` | `3B7AF52FA7E8447703CEC682DC8559CDF09BEBCA30AB855C6A21DF3CECE05C24` |

`Rscript tests/run_all.R` ha completato 18 file di test. Il test CL copre ora
anche corrispondenza completa vocabolario/primitive, unicità delle definizioni,
assenza di Segoe UI Symbol e delle vecchie caselle 3,4 × 3,4 mm, presenza di
tutte le primitive e delle 48 istanze di simbolo attese.

## Esito

P2R soddisfa il proprio criterio di uscita e passa a `review_gate`. Non
autorizza nuovi stimoli: P3R deve decidere se il prototipo A4 revisionato può
procedere a un micro-lotto e, solo in caso affermativo, determinarne la
dimensione.
