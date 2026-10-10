# SS — report del prototipo ridotto P5P

## Ambito

P5P produce un blocco di pratica da 12 celle e una matrice non definitiva di
6 righe per 10 colonne alla scala prevista per la forma A4. Non crea il foglio
scored da 200 stimoli, non crea `items/source/SS.csv` e non modifica timing,
scoring, vocabolario o composizione dichiarati nella spec.

La sorgente `stimulus_cells.csv` è separata da `stimulus_keys.csv`: la prima
descrive posizione e token, la seconda dichiara soltanto se la cella è un
target. Il generatore ricontrolla la chiave rispetto al `target_token` della
spec prima di produrre il foglio.

## QA del contenuto

`R/build/build_ss_prototype.R` e `tests/test_ss_prototype.R` verificano che:

- pratica e matrice contengano rispettivamente 12 e 60 celle con ID unici;
- le sole sei primitive disponibili coincidano con il vocabolario chiuso;
- la pratica contenga 6 target, 6 distrattori e tutti i cinque distrattori;
- la matrice contenga 30 target e 30 distrattori;
- i target per riga siano `4, 6, 5, 4, 6, 5`;
- ciascun distrattore compaia sei volte;
- nessun distrattore identico sia adiacente e non vi siano più di due target
  consecutivi;
- le 72 celle siano rappresentate una volta nel rendering;
- il PNG abbia le dimensioni di un A4 verticale a 300 dpi.

Il brief conteneva un conflitto: vietava ogni token identico adiacente ma
richiedeva anche righe con 6 target su 10 celle. Poiché esiste un solo token
target, almeno una coppia adiacente è inevitabile. Il vincolo è stato corretto
nel brief come sopra, senza cambiare la composizione.

## Ispezione visiva

Il PNG è stato ispezionato a risoluzione originale. Non sono emersi clipping,
collisioni, sostituzioni di font o differenze di scala fra target e
distrattori. Contorni e linee interne sono distinti; guide e numeri di riga
rendono chiaro il ritorno al margine sinistro. Il blocco di pratica è separato
dalla matrice e il target campione resta visibile.

Restano da verificare nel review gate:

- possibile pop-out del cerchio verticale nel campo completo;
- salienza relativa del triangolo rispetto a cerchio e quadrato;
- leggibilità e marcabilità a matita su stampa A4 al 100%;
- mantenimento della barra fisica da 50 mm dopo la stampa.

## Riproducibilità

Due build consecutive hanno prodotto gli stessi SHA-256:

| File | SHA-256 |
|---|---|
| `SS_search_prototype_A4_portrait.svg` | `8FFA81CD5204795B95227A3BACD61AE7BCC220ABA0E527A0324D683B8436EEAC` |
| `SS_search_prototype_A4_portrait_300dpi.png` | `088ECCF601767AF4E1EAE6766D226C322DC0AD1476AFE75BE4E8E404ED0F5D39` |

`Rscript tests/run_all.R` ha completato 21 file di test.

## Esito

P5P soddisfa il proprio criterio di uscita e passa a `review_gate`. Non è
autorizzata la forma completa né un secondo lotto. Il prossimo pacchetto deve
riesaminare il prototipo senza aggiungere celle e decidere se revisionarlo,
scartarlo o ammetterlo a una successiva espansione controllata.

## Integrazione PDF e controllo digitale (2026-10-01)

Il generatore produce ora anche `SS_search_prototype_A4_portrait.pdf` dalla
stessa sorgente SVG. Il PDF è di una pagina A4 verticale (210 × 297 mm) ed è
stato rasterizzato di nuovo a 150 dpi: pratica, matrice 6 × 10, sei primitive,
guide di riga e barra da 50 mm sono complete, nitide e senza clipping. La
conversione non introduce differenze di scala apparenti. Restano da giudicare
su carta la marcabilità e, con osservazione umana, l'eventuale pop-out del
target e la salienza relativa delle forme.
