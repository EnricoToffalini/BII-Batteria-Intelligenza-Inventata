# SS — decisione del review gate P5R

**Decisione: revisione richiesta prima di qualunque espansione.** Primitive,
scala e layout superano il controllo digitale, ma la disposizione delle 60
celle contiene regolarità spaziali troppo forti. Il prototipo non è approvato
per un lotto più grande.

## Evidenze esaminate

- sorgente e chiave separate delle 12 celle di pratica e delle 60 celle del
  prototipo;
- SVG, PNG a 300 dpi e PDF A4 vettoriale;
- seconda rasterizzazione indipendente del PDF a 150 dpi;
- controlli automatici in `tests/test_ss_prototype.R`;
- conteggi per riga, colonna, token e sequenze target/distrattore.

La verifica fisica di barra e matita è stata differita dal responsabile del
progetto al controllo finale. Questo gate decide quindi soltanto ciò che è
osservabile e riproducibile digitalmente.

## Esito per criterio

| Criterio | Esito | Evidenza |
|---|---|---|
| vocabolario e primitive | passa | tutti e soli i sei token dichiarati hanno primitive SVG distinte |
| scala e completezza A4 | passa digitalmente | SVG/PDF 210 × 297 mm; 72 celle presenti; nessun clipping |
| contorni e linee interne | passa digitalmente | orientamenti distinguibili nel PNG 300 dpi e nella rasterizzazione del PDF |
| target non più grande o scuro | passa digitalmente | stessa bounding box e stesso stroke delle alternative della medesima forma |
| percorso per righe | passa | guide leggere e numeri rendono chiaro il ritorno a sinistra |
| pop-out e salienza | passa solo provvisoriamente | nessun pop-out macroscopico sul rendering; resta controllo finale umano/su carta |
| marcabilità a matita | differito | richiede supporto fisico |
| assenza di pattern spaziali | **non passa** | righe 3 e 6 perfettamente alternate; riga 2 quasi alternata; colonna 7 sottorappresentata |

## Difetto che blocca l'espansione

Indicando con `T` un target e con `D` un distrattore:

- riga 3: `DTDTDTDTDT`;
- riga 6: `TDTDTDTDTD`;
- riga 2: dopo i primi due target, alternanza quasi completa fino alla fine.

Inoltre i target per colonna variano da 1 (colonna 7) a 4. Queste strutture non
rendono errata la chiave, ma offrono una strategia spaziale estranea alla
ricerca della congiunzione forma-orientamento. Il difetto era invisibile ai
test precedenti, che limitavano soltanto le ripetizioni consecutive.

## Revisione autorizzata

Il packet successivo può soltanto rimescolare le 60 celle `prototype`,
mantenendo invariati:

- le 12 celle di pratica;
- 30 target e 30 distrattori;
- sei occorrenze per ciascuno dei cinque distrattori;
- conteggi target per riga `4, 6, 5, 4, 6, 5`;
- primitive, dimensioni, layout, timing, scoring e vocabolario.

La revisione deve aggiungere controlli che impediscano:

- alternanza perfetta `T/D` per più di cinque celle consecutive;
- meno di due o più di quattro target in una colonna;
- due righe con lo stesso insieme di posizioni target;
- sequenze meccaniche equivalenti ottenute per semplice inversione T↔D.

Dopo il nuovo rendering serve un altro review gate digitale. Non è autorizzata
la forma da 200 celle.
