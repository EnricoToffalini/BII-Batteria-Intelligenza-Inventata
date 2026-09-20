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
`R/build/rebuild_all.R` rigenera gli artefatti derivati: prima i moduli di
registrazione e il report di QA del routing, poi i dati e le tabelle simulate
legacy in `norms_BII/`. Va eseguito solo quando una modifica lo richiede.

Se hai modificato soltanto un item bank, bastano i due passi rapidi:

```powershell
Rscript R/build/build_record_forms.R
Rscript R/build/routing_qa.R
```

## Stato dei subtest

Otto subtest su quindici hanno una forma completa in bozza e sono
somministrabili. Per ognuno esistono item bank, rubrica, piano di progettazione,
modulo di registrazione e sezione di [manuale](manual/ADMINISTRATION.md).

| Subtest | Dominio | Ruolo | Item | Formato |
|---|---|---|---|---|
| SP — Significato delle Parole | Gc | core | 18 | risposta aperta 0/1/2 |
| RS — Relazioni Semantiche | Gc | core | 24 | scelta multipla |
| RR — Ragionamento per Regole | Gf | core | 20 | scelta multipla su simboli |
| CR — Coppie da Ricordare | Glr | core | 14 | recupero differito + riconoscimento |
| SM — Sequenze e Manipolazione | Gwm | core | 36 | sequenze numeriche a 3 microblocchi |
| CS — Conoscenza Sociale | Gc | supplementare | 10 | risposta aperta 0/1/2 |
| QS — Quantità e Strategie | Gf | supplementare | 12 | risposta breve 0/1/2 |
| PG — Posizioni su Griglia | Gwm | completion | 16 | sequenze su griglia 4×4 |

**Il QI totale non è ancora calcolabile**: richiede nove subtest core e ne sono
pronti cinque (SP, RS, RR, CR, SM). Il QI rapido ne richiede quattro e ne manca
uno (MR). Ogni punteggio composito prodotto adesso sarebbe incompleto.

I sette subtest rimanenti sono bloccati da due cose diverse, e la distinzione
conta:

- **route type non implementati** — CL e SS usano `fixed_time` con punteggio
  derivato da componenti (`corrette - errori`), che il motore non interpreta
  ancora;
- **stimoli non producibili** — MR, MO, RP, MP, DM richiedono figure
  geometriche deterministiche o materiale manipolabile.

Il campo `stimulus_production` nella spec dichiara quale capacità serve per
ciascun subtest, e la regola è di **non popolare un item bank che non si è in
grado di produrre fedelmente**: un subtest vuoto è uno stato visibile, un
subtest con stimoli finti non lo è. Vedi
[decision record 0004](docs/decisions/0004-item-development-strategy.md).

Le regole di somministrazione non sono scritte nel codice:
`R/scoring/administer.R` le legge dalla spec e smista sul route type. Sono
implementati `adaptive_items`, `delayed_retrieval`, `adaptive_levels` e
`adaptive_levels_by_microblock`: per un subtest che usa uno di questi non serve
nuovo codice di routing. La procedura completa è in [AGENTS.md](AGENTS.md).

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
