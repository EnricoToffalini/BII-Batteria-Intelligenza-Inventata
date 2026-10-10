# Pipeline `vector_geometry` — capability spike P6

## Scopo e confini

P6 verifica che la repository possa produrre, renderizzare e ispezionare
geometria vettoriale deterministica alla scala di stampa. La tavola è un asset
di calibrazione non scored: non contiene item e non definisce famiglie,
difficoltà o chiavi di MR, RP, MP o DM.

La pipeline usa uno script R trasparente, SVG come sorgente versionabile,
`rsvg` per il rendering e `magick` per registrare la densità del PNG. Non sono
incorporati raster nello SVG.

## Cosa è stato verificato

La tavola A4 contiene quattro pannelli:

1. linee da 0,25, 0,40 e 0,60 mm e primitive da 20 mm;
2. identità, rotazione a 90°, riflessione orizzontale e rotazione a 180° di
   una stessa figura asimmetrica;
3. giunzioni, sovrapposizione e clipping di tratteggi;
4. quattro slot di risposta di uguale ingombro, esplicitamente privi di una
   risposta corretta.

Sono presenti inoltre una barra da 50 mm e un rettangolo da 20×10 mm per il
controllo della stampa. Il test automatico verifica dimensioni A4, marker dei
pannelli e delle trasformazioni, assenza di `<image>`, presenza dei tre
spessori e dimensioni del PNG a 300 dpi.

## Ispezione visiva

Il PNG è stato ispezionato a risoluzione originale. L'esito digitale è
positivo:

- le tre linee sono distinguibili;
- contorni, punti pieni e dettagli interni non sono tagliati;
- rotazioni e riflessione conservano geometria e spessore;
- clipping e sovrapposizione non producono bordi estranei;
- i quattro slot hanno separazione e ingombro comparabili;
- testo e figure non collidono.

## Limiti osservati

- I font servono solo alle etichette della tavola. Gli stimoli scored dovranno
  restare indipendenti dai font di sistema.
- La leggibilità su carta degli spessori, soprattutto 0,25 mm, richiede ancora
  una stampa fisica al 100%.
- La stabilità degli hash è stata verificata nello stesso ambiente; prima del
  freeze servirà un rendering in un secondo ambiente.
- Lo spike dimostra la fattibilità tecnica, non l'unicità delle risposte o la
  validità psicometrica di futuri item.

## Riproducibilità

Due build consecutive hanno prodotto gli stessi SHA-256:

| File | SHA-256 |
|---|---|
| `vector_geometry_spike_A4_portrait.svg` | `5769B987F97D37713D58770AE3C533A08EEB3294710DCEE7CE723ABB711D00C1` |
| `vector_geometry_spike_A4_portrait_300dpi.png` | `7D9C03AB658287CDA43BA362BE35D96B3D52DFA0A8EEB0879C3ED931F7E242B0` |

## Esito

P6 è superato: la pipeline minima `script R → SVG → PNG 300 dpi → ispezione`
è disponibile. Il successore non è una banca completa: è il solo gate G1 di
MR, scelto perché MR è core e blocca sia QI rapido sia QI totale.
