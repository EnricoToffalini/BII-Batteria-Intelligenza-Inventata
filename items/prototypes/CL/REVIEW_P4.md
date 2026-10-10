# CL — report del primo micro-lotto P4

## Ambito

P4 aggiunge otto stimoli non definitivi alla sola famiglia
`distinct_substitution`, portando il prototipo da 6 a 14 righe. I sei stimoli
P2 e le loro chiavi sono rimasti invariati. Il lotto non è un item bank e non
crea `items/source/CL.csv`.

## QA del contenuto

Il generatore e `tests/test_cl_prototype.R` verificano ora che:

- gli ID siano ordinati e completi da `CL-P01` a `CL-P14`;
- stringhe e chiavi dei sei stimoli P2 coincidano con lo snapshot atteso;
- le 14 coppie siano uniche e appartengano alla sola famiglia autorizzata;
- ogni stringa contenga quattro token distinti del vocabolario chiuso;
- fonte e chiave concordino su `UGUALE`/`DIVERSO` e posizione della differenza;
- il solo lotto P4 contenga quattro coppie uguali e quattro diverse;
- le quattro coppie diverse P4 esercitino una volta ciascuna le posizioni 1–4;
- il lotto P4 eserciti tutti i sei token;
- la sequenza complessiva non alterni meccanicamente le risposte e non presenti
  più di due chiavi uguali consecutive;
- il rendering contenga le 112 istanze di simbolo attese.

Nel prototipo complessivo risultano sette risposte `UGUALE` e sette `DIVERSO`.
Nessun parametro di timing, scoring, layout, vocabolario o primitive è stato
modificato.

## Ispezione visiva

Il PNG A4 è stato ispezionato per intero e con un dettaglio a risoluzione
originale delle righe 7–14. Gli otto nuovi stimoli mantengono:

- centratura, passo e separazione del prototipo approvato;
- metrica identica fra stringa sinistra e destra;
- una sola discrepanza visibile nelle coppie diverse;
- distanza chiara fra seconda stringa e lettere `U`/`D`;
- contrasto uniforme fra righe e assenza di contatti fra glifi.

Non sono emersi artefatti di rendering, differenze di larghezza che rivelino la
chiave o simboli sistematicamente ingranditi/rimpiccioliti nel nuovo lotto. La
maggiore densità osservata, 14 righe su 25 nella prima colonna, resta leggibile
nel rendering digitale a scala dichiarata.

## Riproducibilità

Due build consecutive hanno prodotto gli stessi SHA-256:

| File | SHA-256 |
|---|---|
| `CL_distinct_substitution_A4_landscape.svg` | `489AC3713618861B4EB8D7EF5CA59CEE77EE87240B9320CD293B5979B1C1BB2E` |
| `CL_distinct_substitution_A4_landscape_300dpi.png` | `A9C4989303D1CFCF2A2EF33E25A146BE22876349394E114366A1BB3622AE03E7` |

`Rscript tests/run_all.R` ha completato 18 file di test.

## Esito e limite del gate

P4 soddisfa il proprio criterio di uscita e passa a `review_gate`. Nessun
secondo lotto è autorizzato. Come stabilito in P3R, prima di decidere
un'ulteriore espansione servono una stampa A4 al 100%, la verifica della barra
da 50 mm e almeno una prova di barratura a matita. Fino a quella verifica il
successivo gate CL resta bloccato; il lavoro può proseguire sul design separato
di SS senza modificare questo prototipo.

## Integrazione PDF e controllo digitale (2026-10-01)

Il generatore produce ora anche
`CL_distinct_substitution_A4_landscape.pdf` dalla stessa sorgente SVG. Il PDF è
di una pagina A4 orizzontale (297 × 210 mm) ed è stato rasterizzato di nuovo a
150 dpi per controllare l'output effettivo: intestazione, 14 righe, quattro
colonne, primitive, lettere `U`/`D` e barra da 50 mm risultano presenti, nitidi
e senza clipping. Resta aperta soltanto la verifica che dipende dal supporto
fisico: scala dopo la stampa e barratura a matita.
