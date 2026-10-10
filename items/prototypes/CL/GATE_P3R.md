# CL — decisione del review gate P3R

**Decisione: approvato per un solo micro-lotto controllato.** Il prototipo A4
revisionato risolve i due blocchi di P3 e non introduce nuovi indizi visivi che
impediscano di provare un piccolo lotto della stessa famiglia. Questa decisione
non approva la forma completa né autorizza il passaggio diretto a 100 stimoli.

## Evidenze esaminate

- sorgente e chiavi dei sei prototipi, rimasti invariati da P2;
- mappa token→primitiva in `R/build/build_cl_prototype.R`;
- controlli automatici in `tests/test_cl_prototype.R`;
- SVG A4 e PNG 3508 × 2480 pixel, con densità registrata 118 px/cm
  (equivalente a circa 300 dpi);
- ispezione dell'intero foglio e di un dettaglio delle sei righe a risoluzione
  originale;
- hash SHA-256 stabili documentati in `REVIEW_P2R.md`.

La review è grafica e concettuale. Non è una prova empirica con partecipanti e
non sostituisce una stampa fisica compilata a matita.

## Esito per criterio

| Criterio | Esito | Evidenza |
|---|---|---|
| portabilità dei glifi | passa | i sei stimoli sono primitive SVG; nessun glifo dipende da Segoe UI Symbol |
| completezza della mappa | passa | tutti e soli i token della spec hanno una definizione distinta |
| distinzione stimolo-risposta | passa | `U`/`D` non hanno contenitori e non replicano `□` o `○` |
| centratura e separazione | passa | glifi centrati nel reticolo, senza contatti o salti di baseline |
| metrica sinistra/destra | passa | coordinate e passo sono identici; la larghezza non rivela la chiave |
| salienza dei simboli | passa per il micro-lotto | dimensioni nominali comparabili; pieno/vuoto deriva dal vocabolario previsto |
| percorso visivo | passa | separatori, righe, colonne e prosecuzione restano inequivocabili |
| densità A4 | passa per il micro-lotto | 6,48 mm per riga e glifi nominali da 4 mm sono leggibili nel rendering a scala dichiarata |
| marcabilità a matita | aperto | la lettera da barrare è isolata, ma manca ancora una prova fisica al 100% |
| comprensione `U`/`D` | aperto | la legenda è esplicita; la stabilità nei partecipanti più giovani richiede esercizi/pilot |

## Valutazione dei due blocchi di P3

### Interferenza fra glifo e risposta

Il blocco è risolto. Le lettere `U` e `D` sono separate dai simboli, hanno una
forma non presente nel vocabolario e non sono racchiuse in quadrati o cerchi.
Nel dettaglio a risoluzione originale non competono con `□` o `○` e non
sembrano parte della seconda stringa.

### Portabilità degli stimoli

Il blocco è risolto per gli stimoli scored: cerchio, triangolo, quadrato,
rombo, più e stella sono tracciati geometricamente e la validazione rifiuta
token mancanti o estranei. Testata, istruzioni e lettere latine restano testo
SVG ordinario; il loro eventuale fallback sans-serif non cambia la forma dei
glifi né la regola dell'item. Prima dell'integrazione finale andrà comunque
verificato almeno un rendering in un secondo ambiente.

## Micro-lotto autorizzato

P4 può aggiungere **otto** stimoli non definitivi, sempre e soltanto della
famiglia `distinct_substitution`:

- quattro coppie `UGUALE` e quattro `DIVERSO`;
- per le coppie diverse, una sola sostituzione rispettivamente nelle posizioni
  1, 2, 3 e 4;
- quattro simboli distinti nella stringa sinistra;
- uso esclusivo del vocabolario chiuso e copertura di tutti i sei token nel
  lotto;
- nessun pattern prevedibile delle chiavi e nessuna modifica a layout, timing,
  scoring o primitive durante lo stesso packet.

Gli otto nuovi stimoli portano il prototipo a 14 righe: abbastanza per
verificare varietà e stabilità del generatore, ma ancora lontano da una forma
completa. Dopo il rendering, P4 torna a review gate. Nessun secondo lotto è
automaticamente autorizzato.

## Vincoli successivi

Prima di un secondo lotto o dell'integrazione della forma servono:

1. QA automatico e ispezione a risoluzione originale delle 14 righe;
2. verifica che le primitive non producano differenze di salienza sistematiche;
3. stampa A4 al 100% con controllo della barra da 50 mm e almeno una prova di
   barratura a matita;
4. mantenimento separato di fonte degli stimoli e chiave.

Il design brief di SS può ora iniziare usando A4, primitive deterministiche e
risposte senza contenitori come lezioni di layout, senza copiare la grammatica
percettiva di CL.
