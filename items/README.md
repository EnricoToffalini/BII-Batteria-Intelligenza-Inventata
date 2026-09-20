# Item bank BII

Gli item sono semplici file CSV: si possono leggere e modificare con Excel,
LibreOffice Calc o un editor di testo. Ogni riga è un item; le colonne sono
descritte in [ITEM_SCHEMA.md](ITEM_SCHEMA.md).
La provenienza e le regole per sostituire i materiali sono in
[PROVENANCE.md](PROVENANCE.md).

Otto subtest hanno una prima forma completa in stato `draft`: `SP.csv` (18
item), `RS.csv` (24), `RR.csv` (20), `CS.csv` (10), `QS.csv` (12), `CR.csv` (14),
`PG.csv` (16) e `SM.csv` (36). Sono pronte per revisione umana e prove
didattiche, non sono forme calibrate. I sette subtest rimanenti non hanno ancora
un item bank.

`PG.csv` e `SM.csv` sono stati generati con seed fisso da
`R/build/build_pg_items.R` e `R/build/build_sm_items.R`: i generatori
documentano quali vincoli rispettano le sequenze. I CSV restano comunque la
fonte modificabile a mano, e i vincoli sono verificati sul CSV, non sull'output
dei generatori.

Per ogni subtest, il piano in [`design/`](design/) dice che cosa quel subtest
deve e **non** deve diventare, e quali vincoli rispettano gli item attuali.
Leggerlo prima di sostituire un item: è lì che è scritto, per esempio, perché in
CS una risposta gentile senza meccanismo vale 1 e non 2, o perché in QS ogni item
deve avere un passaggio intermedio identificabile.

`RR.csv` usa sei simboli geometrici e **nessun altro**: il set è dichiarato in
`spec/subtests/RR.yml` e un test fallisce se ne compare un settimo.

Se apri questi CSV con Excel e vedi caratteri strani al posto di lettere
accentate o simboli, importa il file scegliendo la codifica **UTF-8** invece di
aprirlo con un doppio clic.

Non cambiare mai un `item_id` già usato. Se un item non va più bene, marcarlo
come ritirato o sostituirlo con un nuovo ID. La colonna `order` invece può
cambiare: è la posizione nella forma, non l'identità dell'item.

## Dopo aver modificato un item bank

Il modulo di registrazione in `materials/record_forms/` è un artefatto
derivato: va rigenerato, non modificato a mano.

```powershell
Rscript R/build/build_record_forms.R
Rscript tests/run_all.R
```

Se cambiano numero di item, difficoltà o regole adattive, rigenerare anche il
report di QA del routing:

```powershell
Rscript R/build/routing_qa.R
```
