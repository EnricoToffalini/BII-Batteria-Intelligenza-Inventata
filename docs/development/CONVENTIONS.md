# Convenzioni di identificazione e versionamento

Queste convenzioni si applicano ai nuovi artefatti v0. Non rinominare gli
artefatti legacy soltanto per conformarli: prima va migrata la loro dipendenza
alla spec e poi vanno rigenerati.

## ID di subtest

- Usare l'ID canonico maiuscolo di due lettere già stabilito dalla batteria
  (`SP`, `RS`, `CS`, `MR`, `RR`, `QS`, `MO`, `RP`, `MP`, `SM`, `PG`, `CL`,
  `SS`, `CR`, `DM`).
- L'ID è stabile: un subtest ritirato non cede il suo ID a un nuovo costrutto.
- Nella spec usare l'ID, non il nome visualizzato, per chiavi e dipendenze.

## ID degli item

- Formato: `<SUBTEST>-<TIPO>-<NN>`, per esempio `MR-SC-01` o `SP-PR-02`.
- `<TIPO>` è `SC` per item scored e `PR` per item di prova.
- `<NN>` è un numero a due cifre nell'ordine di somministrazione iniziale.
  L'ID non cambia se l'item viene spostato: l'ordine corrente è un campo
  separato nella spec/item bank.
- Non riutilizzare un ID ritirato. Marcarne invece lo stato come
  `retired`/`superseded` e indicare l'eventuale sostituto.

## Asset

- Sorgenti versionate: `items/assets_src/<SUBTEST>/<ITEM_ID>/`.
- Asset resi per la somministrazione: `items/assets_rendered/<SUBTEST>/`.
- Nome file base: `<ITEM_ID>--<VARIANTE>.<estensione>`, ad esempio
  `MR-SC-01--stem.svg` o `MR-SC-01--option-b.svg`.
- Gli asset visivi centrali devono essere SVG o prodotti da una sorgente
  deterministica; un raster deve indicare esplicitamente origine e motivo.

## Versioni e stati

- Stato della batteria: `0.0.0-dev` fino al primo incremento dichiarato.
- `spec_version` aumenta per ogni modifica psicometricamente o
  proceduralmente rilevante.
- Gli output rigenerati riportano almeno `spec_version`, hash della spec, seed,
  data di build e, quando disponibile, commit Git.
- Usare `simulated`, `synthetic` o `reference` per output derivati. Non
  introdurre nuovi file, schermate o documenti chiamati `OFFICIAL`.
