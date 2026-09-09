# BII — Batteria d'Intelligenza Inventata

La BII è una mock battery cognitiva per la didattica universitaria. Serve a
discutere costruzione dei subtest, struttura fattoriale, scoring e
interpretazione di profili nel quadro CHC.

> **Uso esclusivamente didattico.** La BII non è uno strumento clinico o
> diagnostico. I dati, le conversioni e le norme presenti in questo repository
> sono simulati/sintetici e non sono norme empiriche.

## Stato del progetto

Il repository è nella fondazione di `v0.0.0-dev`. La fonte di verità
machine-readable è [`spec/`](spec/); definisce i 15 subtest, i range, ruoli,
routing, indici e quozienti. La specifica narrativa storica è in
[_BII - Batteria Intelligenza Inventata.md](_BII%20-%20Batteria%20Intelligenza%20Inventata.md)
ed è mantenuta come documentazione sincronizzata, non come fonte autonoma.

Gli script e i file in `norms_BII/` sono artefatti simulati legacy. Non devono
essere interpretati come validazione, standardizzazione o norme ufficiali, né
devono guidare le decisioni sugli item. Finché non saranno rigenerati dalla
spec, i nomi legacy contenenti `OFFICIAL` sono mantenuti solo per compatibilità
tecnica.

La direzione di sviluppo e le priorità sono descritte nella
[roadmap verso la v0](ROADMAP_V0.md). Le regole operative del repository sono
in [AGENTS.md](AGENTS.md).

## Quick start

Prerequisiti: R e i pacchetti richiesti dagli script di simulazione
(`ggplot2`, `gamlss`, `gamlss.dist`, `dplyr`, `tidyr`, `readr`, `tibble`,
`stringr`, `yaml`, `lavaan`, `semTools`).

Da root del repository:

```powershell
Rscript tests/run_all.R
Rscript R/build/rebuild_all.R
Rscript -e "shiny::runApp('shiny')"
```

`tests/run_all.R` esegue i controlli disponibili senza modificare artefatti.
`R/build/rebuild_all.R` rigenera i dati e le tabelle simulate legacy in
`norms_BII/`; va quindi eseguito solo quando una modifica lo richiede.

Per una raccolta didattica di dati anonimi, copiare i modelli in
[`data/templates/`](data/templates/) e seguire le istruzioni in
[`data/README.md`](data/README.md). Non inserire dati personali nel repository.

## Ordine di lavoro

1. Creare un item bank con ID stabili, chiavi/rubriche e asset riproducibili.
2. Derivare amministrazione e scoring response-level dalla spec e dall'item bank.
3. Rifattorizzare la simulazione e rigenerare norme e Shiny dalla pipeline.

Le convenzioni per ID e versioni sono in
[docs/development/CONVENTIONS.md](docs/development/CONVENTIONS.md). Le
decisioni architetturali rilevanti sono registrate in `docs/decisions/`.
