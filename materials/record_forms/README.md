# Moduli di registrazione

I CSV in questa cartella possono essere aperti con Excel o LibreOffice Calc.
Fanne una copia per ogni somministrazione e compila senza riordinare le righe.
Non inserire nomi, email o altri dati direttamente identificativi.

Per SP:

1. compila `subject_id` con un codice anonimo e `age_months`;
2. usa gli stati elencati in `manual/ADMINISTRATION.md`;
3. inserisci `item_score` soltanto per gli item `administered`;
4. salva come CSV.

Per controllare il punteggio da R:

```r
source("R/scoring/SP.R")
record <- read.csv("percorso/del/record_SP.csv", stringsAsFactors = FALSE)
risultato <- score_sp_record(record)
risultato$raw_score
```

Se `risultato$valid` è `FALSE`, controlla gli item segnati
`external_missing` o `invalidated`: non vengono trasformati automaticamente in
risposte errate.
