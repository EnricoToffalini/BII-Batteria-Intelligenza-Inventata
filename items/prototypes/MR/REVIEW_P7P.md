# MR — report del prototipo `set_combination` P7P

## Ambito

P7P produce quattro matrici 3×3 non definitive della sola famiglia
`set_combination`: unione, intersezione, differenza direzionale e XOR. Ogni
matrice ha cinque alternative, chiave e rationale separati dalla sorgente
geometrica. Non crea item scored, non assegna posizioni 1–24 e non modifica
conteggi, punti di partenza, routing o timing di MR.

Il piano G1 prevedeva un unico foglio A4, ma quattro matrici con celle da
28–32 mm non vi sarebbero entrate alla scala da verificare. Il brief è stato
corretto: ciascun prototipo occupa una tavola A4 con celle da 30 mm e barra da
50 mm. Un contact sheet ridotto non sarebbe stato evidenza valida sulla
leggibilità prevista.

## Sorgente e chiave

`set_components.csv` contiene una riga per componente, con pannello, cella o
alternativa, layer, primitiva e ancora su una griglia 3×3. In P7P l'unica
primitiva è un punto pieno: non sono usati font, rotazioni, raster o riempimenti
decorativi nella geometria del compito.

`set_keys.csv` dichiara l'operazione, l'alternativa corretta e il rationale di
ogni opzione. I codici visibili sui fogli sono ciechi (`MR-P7P-01`–`04`): le
sigle interne `U/I/D/X` non sono stampate sulla tavola di review.

## QA automatico

`R/build/build_mr_set_prototype.R` e `tests/test_mr_set_prototype.R`
verificano che:

- esistano esattamente quattro prototipi e cinque alternative distinte per
  ciascuno;
- la cella mancante sia sempre in riga 3, colonna 3;
- primitive, ancore, layer e stato non definitivo siano validi;
- le prime due righe complete siano spiegate da una sola operazione fra
  unione, intersezione, differenza e XOR;
- una sola alternativa coincida con il risultato calcolato per la terza riga
  e con la chiave dichiarata;
- ogni alternativa abbia un rationale e un solo flag corretto;
- le quattro tavole siano A4 verticali a 300 dpi e riproducibili byte per byte
  in due build consecutive.

Il controllo di unicità è esaustivo entro la grammatica finita delle quattro
operazioni. Non dimostra che una persona non possa inventare una diversa
regola geometrica plausibile: questo resta oggetto del review gate umano.

## Ispezione visiva digitale

I quattro PNG sono stati ispezionati a risoluzione originale. L'esito digitale
è positivo:

- celle della matrice e slot delle alternative mantengono dimensione e stroke;
- i punti condividono diametro e ancore in tutti i pannelli;
- non vi sono clipping, collisioni, raster incorporati o dipendenze da font
  nella geometria del compito;
- il rombo vuoto distingue la cella mancante senza usare un punto interrogativo
  di font;
- matrice, alternative ed etichette A–E sono separate chiaramente;
- in ogni prototipo almeno un distrattore ha la stessa cardinalità della
  risposta corretta, quindi il solo numero di punti non identifica sempre la
  chiave;
- la revisione dei codici visibili ha rimosso l'indizio `U/I/D/X` dal foglio.

## Limiti da portare al gate P7R

- La barra da 50 mm, lo stroke e la leggibilità reale richiedono ancora stampa
  A4 al 100%; l'anteprima digitale non li sostituisce.
- Unione e XOR conservano comunque una relazione fra densità e operazione: va
  verificato empiricamente che i distrattori di pari cardinalità impediscano
  una strategia puramente quantitativa.
- I prototipi 02 e 04 condividono parte della struttura degli operandi per
  isolare l'effetto dell'operazione. Una forma finale non dovrebbe ripetere
  template così vicini senza motivazione.
- Il rombo della cella mancante è leggibile digitalmente, ma il review gate
  deve decidere se adottarlo come convenzione comune oppure sostituirlo.
- Difficoltà e collocazione nella forma non sono inferibili da questi quattro
  prototipi e richiederanno revisione indipendente e pilot.

## Riproducibilità

Due build consecutive hanno prodotto gli stessi file. SHA-256 degli output
versionati:

| File | SHA-256 |
|---|---|
| `MR_set_combination_U_A4_portrait.svg` | `C95BFD9780A094E19E3385D80DD74EC7C8A6587BF9DA909BE1BFC37DF7C351C9` |
| `MR_set_combination_U_A4_portrait_300dpi.png` | `A291D0DAA4664A38B202AA94E7AF123AE38915521BE4BC01C61BC193449254F9` |
| `MR_set_combination_I_A4_portrait.svg` | `015DD4F10609B19EDAFA54A6B7CD9004A8118DA11216125AAE861FBBAA3EDC3E` |
| `MR_set_combination_I_A4_portrait_300dpi.png` | `317AAFB32E3A044D25D8F4E677B3445E90EA6C62EC3E1BD508756A2F11CB036A` |
| `MR_set_combination_D_A4_portrait.svg` | `53E881E5D6D6DAE09D87E23E3A7D70FD26C9D286A091273CEE33B1C97DA073D5` |
| `MR_set_combination_D_A4_portrait_300dpi.png` | `9A3D635D5C37BFA314B4ADE326DBC53564C9246ABFA7CC51AEB6BCB7B893FB25` |
| `MR_set_combination_X_A4_portrait.svg` | `11FAFCDB800F9CC3E7298FAAEB1B7848C03A12230F95021251A79B24845C85D4` |
| `MR_set_combination_X_A4_portrait_300dpi.png` | `3E86AB006DBBA50E8C61600DA9BBE498B0722C02C44C94A521CCF948D4C75F2B` |

`Rscript tests/run_all.R` ha completato 23 file di test.

## Esito

P7P soddisfa il criterio di uscita e passa a `review_gate`. Non è autorizzato
alcun item bank, secondo lotto o seconda famiglia. P7R deve riesaminare le
quattro tavole e decidere se approvare, revisionare o scartare il prototipo.

## Integrazione PDF e controllo digitale (2026-10-01)

Il generatore produce ora quattro PDF A4 verticali, uno per prototipo, dalla
stessa sorgente SVG. Ogni file è di una pagina 210 × 297 mm. Una seconda
rasterizzazione indipendente a 150 dpi conferma per tutte le tavole la presenza
integrale di matrice, cella mancante, alternative A–E, punti, testi e barra da
50 mm, senza clipping o sostituzioni visibili. SVG e PNG restano riproducibili
byte per byte; per i PDF il test confronta il rendering perché Cairo inserisce
un timestamp di creazione nei metadati. Restano il controllo su carta e il
giudizio umano sulle regole alternative e sugli indizi di cardinalità.
