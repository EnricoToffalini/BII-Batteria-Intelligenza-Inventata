# ADR 0001 — Migrazione alla fonte di verità strutturata

- **Stato:** accettata
- **Data:** 2026-09-09

## Contesto

La BII possiede una specifica narrativa completa ma il codice di simulazione e
la Shiny duplicano ID, range dei grezzi e composizione degli indici. Gli output
in `norms_BII/` sono simulati a livello di punteggio totale, non di item e
procedura di somministrazione. Non esistono ancora item bank, asset o una spec
machine-readable.

Il codice di analisi denomina inoltre `CORE12` un insieme che include i 9
subtest core e i 3 subtest di completamento. La specifica narrativa, invece,
definisce correttamente 9 core. Prima della migrazione non attribuiamo a
`CORE12` un nuovo significato: sarà nominato esplicitamente come insieme
analitico o sostituito da una definizione derivata dalla spec.

## Decisione

1. La specifica narrativa legacy resta temporaneamente la fonte descrittiva.
2. La prossima modifica strutturale crea `spec/`; da quel momento `spec/` sarà
   la fonte di verità machine-readable per subtest, routing, scoring e indici.
3. Item, simulazioni, norme, Shiny e manuali sono artefatti dipendenti. Non
   vengono adattati per preservare gli output attuali se entrano in conflitto
   con la spec o con gli item reali.
4. I file legacy con `OFFICIAL` non vengono rinominati nella sola fase di
   fondazione, perché sono letti dalla Shiny. Al primo rebuild basato sulla
   spec saranno sostituiti da nomi che dichiarano esplicitamente la natura
   simulata.

## Conseguenze

- La prima issue di fase 1 deve essere una migrazione/rassegna completa dei 15
  subtest e della composizione di indici/QI, con test di validazione.
- Una modifica successiva a item count, range, timing, routing o composizione
  di indici richiederà di valutare il rebuild delle simulazioni e della Shiny.
- Fino alla migrazione, ogni duplicazione legacy va trattata come debito
  tecnico documentato, non come seconda fonte autonoma.
