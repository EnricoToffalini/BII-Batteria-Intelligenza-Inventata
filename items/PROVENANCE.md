# Provenienza degli item

Gli item attualmente presenti in `items/source/` sono stati creati da zero per
la BII con assistenza di IA. Non sono stati trascritti o adattati
intenzionalmente da batterie commerciali, manuali protetti o banche di item
esterne. Sono materiale `mock`, non item validati.

| File | Stato | Provenienza dichiarata |
|---|---|---|
| `SP.csv` | mock, draft | creato per BII; nessuna fonte esterna usata |
| `RS.csv` | mock, draft | creato per BII; nessuna fonte esterna usata |
| `RR.csv` | mock, draft | creato per BII; simboli geometrici Unicode standard |
| `CS.csv` | mock, draft | creato per BII; situazioni quotidiane inventate |
| `QS.csv` | mock, draft | creato per BII; problemi quantitativi inventati |
| `CR.csv` | mock, draft | creato per BII; coppie di parole comuni scelte a caso |
| `PG.csv` | mock, draft | generato da `R/build/build_pg_items.R` con seed fisso |
| `SM.csv` | mock, draft | generato da `R/build/build_sm_items.R` con seed fisso |

Otto subtest hanno una forma completa in bozza: SP (18 item), RS (24), RR (20),
CS (10), QS (12), CR (14), PG (16) e SM (36). Gli altri sette non hanno ancora
un item bank.

Questa dichiarazione documenta il processo seguito, ma non garantisce che non
esistano somiglianze casuali con altri materiali. Prima della diffusione ampia
servono comunque revisione umana e una licenza esplicita scelta dal titolare
del progetto.

## Quando si sostituisce un item

1. Non copiare item da test pubblicati o materiali con licenza incompatibile.
2. Conservare l'`item_id` se si modifica lo stesso item; usare un nuovo ID se
   lo si sostituisce con un item diverso.
3. Aggiornare prompt, chiave, rubrica e difficoltà progettuale nello stesso CSV.
4. Indicare qui la provenienza o la licenza del nuovo materiale.
5. Eseguire `Rscript tests/run_all.R`.

Per dati raccolti, usare i template in `data/templates/` e non inserire dati
direttamente identificativi nella repository.
