# Pacchetti di lavoro operativi

Questo file traduce la roadmap in blocchi che un agente può scegliere quando la
richiesta è semplicemente «procedi col lavoro». `ROADMAP_V0.md` resta il piano
strategico; questo è il registro operativo da mantenere aggiornato.

## Come scegliere un blocco

1. Leggere `AGENTS.md`, questo file e le spec coinvolte.
2. Controllare il worktree: non sovrascrivere lavoro in corso e preferire un
   pacchetto che non tocchi gli stessi file.
3. Escludere i pacchetti con prerequisiti non soddisfatti.
4. Escludere quelli per cui non si possiede la capacità indicata.
5. Scegliere il primo pacchetto `ready` nell'ordine di priorità sotto.
6. Prima delle modifiche sostanziali marcarlo `in_progress` e annotare in una
   riga `Owner/run` il nome del task o una breve identificazione della sessione.
   Un altro agente non lavora sullo stesso pacchetto o sulla stessa area.
7. Fare **un solo pacchetto per turno**, salvo piccoli derivati meccanici
   indispensabili per chiuderlo.
8. Aggiornare qui stato, esito, artefatti e pacchetto successivo. Se il lavoro
   si interrompe, lasciare `in_progress` con una nota concreta su ciò che resta.

Se nessun pacchetto compatibile è `ready`, non improvvisare un item bank:
scegliere un'attività non grafica dalla coda di riserva oppure spiegare il
blocco.

## Stati

- `ready`: prerequisiti presenti; il pacchetto può iniziare.
- `in_progress`: lavoro iniziato ma non ancora verificato.
- `review_gate`: output presente, espansione vietata finché non è revisionato.
- `blocked`: manca una capacità, decisione o dipendenza nominata.
- `done`: criteri di uscita soddisfatti e test eseguiti.

`done` non significa che il subtest sia completo: significa soltanto che quel
pacchetto lo è.

## Dimensione di un pacchetto

Un blocco dovrebbe essere verificabile in una sessione e avere un solo esito
principale. Esempi corretti: una grammatica di stimoli, un prototipo di 3–6
item, il QA di una famiglia, un generatore per una famiglia già approvata.

Non sono pacchetti accettabili:

- «completa tutti i subtest visivi»;
- «genera 100 item CL/SS»;
- «crea l'intera banca MR con un prompt»;
- «sistema simulazione, norme e Shiny».

Se durante il lavoro emerge una modifica a numero di item, range, scoring,
timing o routing, fermare l'espansione e aprire prima un pacchetto di decisione
cross-cutting.

## Gate obbligatori per la grafica

L'incertezza grafica non va nascosta in una stima iniziale fittizia. Ogni
subtest `vector_geometry` o `manipulative` attraversa questi gate, uno per
pacchetto:

1. **G0 — capability check:** confermare che l'agente può creare la sorgente,
   renderizzarla e ispezionare visivamente il risultato. Un agente che non può
   fare tutte e tre le cose non prende il pacchetto.
2. **G1 — design brief:** costrutto, grammatica visiva, famiglie, invarianti,
   font/linee/spaziatura, rischi e criteri di unicità della risposta. Nessuna
   banca completa.
3. **G2 — tool spike:** dimostrare la pipeline su asset non scored o su un solo
   prototipo sacrificabile. L'obiettivo è misurare fattibilità e costo, non
   costruire astrazioni generali premature.
4. **G3 — prototipo:** 3–6 item di **una sola famiglia**, con sorgenti,
   rendering, chiavi e controlli automatici possibili.
5. **G4 — visual review:** ispezionare i rendering a dimensione di stampa;
   controllare leggibilità, risposta unica, artefatti, indizi involontari e
   separazione fra difficoltà grafica e difficoltà concettuale.
6. **G5 — batch controllato:** espandere una famiglia approvata in un piccolo
   lotto. Ripetere G4. La dimensione del lotto dipende da quanto il generatore
   è stabile; non è fissata a priori.
7. **G6 — integrazione:** solo dopo i gate precedenti completare item bank,
   rubriche, manuale, materiali, scoring e QA end-to-end.

Non si presume che un prompt basti. Se un singolo prompt produce un buon lotto,
il lotto deve comunque passare gli stessi gate. Se ogni item richiede lavoro
individuale, procedere item per item o per micro-lotti: la velocità non è un
criterio di accettazione.

### Capacità minima per tipo di stimolo

| `stimulus_production` | Capacità minima | Regola |
|---|---|---|
| `text_only` | scrittura + QA contenutistico | nessun asset visivo |
| `symbol_text` | controllo del vocabolario chiuso e della resa UTF-8 | usare solo simboli dichiarati |
| `symbol_grid` | generazione/layout regolare + ispezione del foglio reso | non trattarlo come semplice prosa |
| `vector_geometry` | sorgente SVG/scriptata + render + ispezione visiva affidabile | vietati ASCII art e placeholder |
| `manipulative` | progettazione di asset stampabili e verifica fisica/procedurale | non simulare tasselli con descrizioni |

Un agente debole sulla grafica deve evitare tutti i pacchetti grafici, compresi
quelli `symbol_grid`. In particolare deve evitare **anche** design brief e QA
dei subtest `vector_geometry`/`manipulative`, non soltanto la generazione finale.
Può scegliere un pacchetto non grafico dalla coda di riserva.

Per gli stimoli scored, immagini raster generative opache non sostituiscono una
sorgente deterministica. Possono servire come esplorazione non scored soltanto
se il pacchetto lo dichiara esplicitamente.

## Coda prioritaria corrente

La priorità riflette lo stato al 2026-09-20. Verificarla contro `spec/` e il
worktree prima di usarla.

### P1 — CL design brief e piano di prototipo

- **Stato:** `done`.
- **Owner/run:** `/root`, sessione 2026-09-20.
- **Esito:** creato `items/design/CL.md`; dichiarato in
  `spec/subtests/CL.yml` il vocabolario chiuso di sei glifi. Il brief mantiene
  una sola regola uguale/diverso, definisce quattro famiglie percettive, i
  vincoli di bilanciamento, due layout da confrontare e un prototipo baseline
  di sei stimoli. `Rscript tests/run_all.R`: 17 file di test superati.
- **Capacità:** `symbol_grid`, layout stampabile, giudizio visivo.
- **Obiettivo:** creare `items/design/CL.md`; definire grammatica delle stringhe,
  famiglie di confronti, font/simboli consentiti, bilanciamento uguale/diverso,
  ordine sul foglio, difficoltà prevista e piano per 3–6 prototipi.
- **Non-obiettivi:** nessun item bank completo, nessun foglio da 100 item,
  nessun cambio a timing/scoring senza decisione motivata.
- **Uscita:** design con `## Punti aperti`, rischi di resa e criteri osservabili
  per giudicare il prototipo.

### P2 — CL prototipo di una famiglia

- **Stato:** `ready`.
- **Capacità:** `symbol_grid`, generazione riproducibile e ispezione visiva.
- **Obiettivo:** creare 3–6 stimoli non definitivi di una famiglia, più il
  minimo necessario per renderli e revisionarli.
- **Uscita:** sorgente, rendering, chiavi, breve report visivo; poi stato
  `review_gate`, non espansione automatica.

### P3 — CL review gate

- **Stato:** `blocked` da P2.
- **Capacità:** forte QA visivo e comprensione del costrutto Gs.
- **Obiettivo:** decidere se la famiglia è leggibile, non ambigua e adatta a un
  foglio timed; stimare da evidenze se conviene lavorare item per item, per
  micro-lotti o con un generatore.
- **Uscita:** approvare, revisionare o scartare il prototipo; definire **solo il
  lotto successivo**.

### P4 — CL espansione controllata

- **Stato:** `blocked` da P3.
- **Capacità:** la stessa di P2.
- **Obiettivo:** un lotto alla volta secondo la dimensione approvata in P3.
- **Uscita:** QA automatico e visivo del lotto. Il passaggio a 100 stimoli non è
  implicito e richiede ripetuti review gate.

### P5 — SS design brief

- **Stato:** `blocked` finché P3 non chiarisce le convenzioni comuni dei fogli
  timed, salvo motivazione esplicita per lavorare in parallelo.
- **Capacità:** `symbol_grid`, layout stampabile, ricerca visiva.
- **Obiettivo:** definire target, distrattori, densità, layout, conteggi e punti
  aperti, senza inventare una semantica temporale più forte della spec.
- **Uscita:** `items/design/SS.md` pronto per un prototipo separato.

### P6 — Pipeline grafica: capability spike

- **Stato:** `ready` soltanto per un agente graficamente forte.
- **Capacità:** SVG/script, rendering locale, ispezione delle immagini.
- **Obiettivo:** verificare con un asset non scored che la repository possa
  produrre SVG deterministici, renderizzarli e controllarne dimensioni, font,
  stroke e stampa. Documentare strumenti e limiti reali.
- **Non-obiettivi:** nessuna banca MR/RP/MP/DM; nessuna libreria generale vasta.
- **Uscita:** una pipeline minima dimostrata oppure un blocco tecnico preciso.

### P7 — Primo subtest `vector_geometry`

- **Stato:** `blocked` da P6 e da una scelta esplicita del subtest dopo lo spike.
- **Capacità:** forte grafica + progettazione psicometrica.
- **Ordine preferito:** MR, perché blocca QI rapido e QI totale; la priorità non
  autorizza però a iniziarlo senza i gate G0–G2.
- **Uscita:** solo G1 o G3, mai la banca completa nello stesso pacchetto.

### P8 — MO feasibility brief

- **Stato:** `blocked` finché non è disponibile una capacità manipolativa
  credibile o una decisione umana sui tasselli.
- **Capacità:** progettazione stampabile/manipolativa, non sola generazione di
  immagini.
- **Uscita:** materiali fisici plausibili e procedura verificabile; altrimenti
  MO resta vuoto.

## Coda di riserva non grafica

Questi pacchetti sono adatti a un agente che non supera G0. Scegliere il primo
`ready` quando i pacchetti prioritari richiedono capacità grafiche assenti.

### N1 — Validazione dei record timed raccolti

- **Stato:** `ready`.
- **Obiettivo:** progettare e implementare un controllo semplice per file con
  osservazioni aggregate CL/SS, separato dal checker item-level; riusare
  `score_fixed_time_record()` e la spec.
- **Non-obiettivi:** Shiny, norme, item CL/SS.
- **Uscita:** template documentato, checker, test su dati validi e invalidi.

### N2 — End-to-end delle forme già complete

- **Stato:** `ready`.
- **Obiettivo:** aggiungere amministrazioni sintetiche complete per i subtest
  che hanno già item bank, verificando routing, record e scoring senza toccare
  norme o Shiny.
- **Uscita:** test condivisi per le classi di route, non duplicazioni per ID.

### N3 — Audit delle rubriche aperte

- **Stato:** `ready`.
- **Obiettivo:** audit limitato a un solo subtest tra SP, CS e QS per coerenza
  0/1/2, meccanismo richiesto, bias di esperienza e casi limite.
- **Non-obiettivi:** riscrivere contemporaneamente tutte le rubriche.
- **Uscita:** correzioni motivate e regression test dove automatizzabili.

## Aggiornamento obbligatorio della coda

Chi chiude un pacchetto deve:

1. cambiarne lo stato;
2. indicare i file prodotti e l'esito dei test;
3. rendere `ready` soltanto il successore i cui prerequisiti sono davvero
   soddisfatti;
4. aggiungere nuovi pacchetti scoperti, ma senza promuoverli automaticamente;
5. non marcare un subtest `complete_draft` prima che l'intera checklist in
   `AGENTS.md` sia soddisfatta.
