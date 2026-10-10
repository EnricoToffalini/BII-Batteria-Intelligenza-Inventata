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

- **Stato:** `done` (revisionato da P3; non approvato per l'espansione).
- **Owner/run:** `/root`, sessione 2026-09-21.
- **Esito:** creati sei stimoli non definitivi `distinct_substitution`, chiave
  separata, generatore SVG/PNG e rendering A4/A3 a 300 dpi in
  `items/prototypes/CL/`, `R/build/build_cl_prototype.R` e
  `materials/stimulus_books/prototypes/CL/`. Ispezionati entrambi i formati a
  risoluzione originale; corrette testata e barra di scala. Il report segnala
  a P3 la somiglianza fra il glifo `□` e le caselle di risposta, la prova di
  marcatura A4 ancora necessaria e il limite di portabilità del font. Gli hash
  SHA-256 degli output restano invariati al rebuild. `Rscript tests/run_all.R`:
  18 file di test superati.
- **Capacità:** `symbol_grid`, generazione riproducibile e ispezione visiva.
- **Obiettivo:** creare 3–6 stimoli non definitivi di una famiglia, più il
  minimo necessario per renderli e revisionarli.
- **Uscita:** sorgente, rendering, chiavi, breve report visivo; poi stato
  `review_gate`, non espansione automatica.

### P3 — CL review gate

- **Stato:** `done` — esito `revisione richiesta`.
- **Owner/run:** `/root`, sessione 2026-09-21.
- **Esito:** `items/prototypes/CL/GATE_P3.md` documenta il gate. Famiglia e
  chiavi passano; non passano la distinzione fra `□` e caselle quadrate e la
  portabilità di Segoe UI Symbol. Selezionato A4 come unico candidato; A3
  ritirato. La revisione deve usare `U`/`D` barrabili senza contenitore e
  primitive SVG determinate dai token. Nessun nuovo item autorizzato.
- **Capacità:** forte QA visivo e comprensione del costrutto Gs.
- **Obiettivo:** decidere se la famiglia è leggibile, non ambigua e adatta a un
  foglio timed; stimare da evidenze se conviene lavorare item per item, per
  micro-lotti o con un generatore.
- **Uscita:** approvare, revisionare o scartare il prototipo; definire **solo il
  lotto successivo**.

### P2R — CL revisione del prototipo esistente

- **Stato:** `done` (approvato da P3R per un micro-lotto, non per la forma completa).
- **Owner/run:** `/root`, sessione 2026-09-22.
- **Esito:** mantenuti i sei stimoli e le chiavi; sostituiti i glifi testuali
  con sei primitive SVG a mappa chiusa e le caselle con `U`/`D` barrabili.
  Ritirati gli output A3; SVG e PNG A4 a 300 dpi ispezionati e riprodotti con
  hash SHA-256 invariati. Report in `items/prototypes/CL/REVIEW_P2R.md`.
  `Rscript tests/run_all.R`: 18 file di test superati. Nessuna espansione
  autorizzata prima di P3R.
- **Capacità:** `symbol_grid`, SVG deterministico, rendering e ispezione.
- **Obiettivo:** mantenere i sei stimoli e le chiavi di P2; sostituire il font
  con primitive SVG e le caselle con lettere `U`/`D` barrabili; generare solo
  A4 a 300 dpi e verificare la corrispondenza completa vocabolario/primitive.
- **Non-obiettivi:** nessun nuovo stimolo, nessun item bank, nessuna modifica a
  timing, scoring o vocabolario.
- **Uscita:** sorgente, test e rendering revisionati, ispezionati e
  riproducibili; poi `review_gate`.

### P3R — CL review gate del prototipo revisionato

- **Stato:** `done` — esito `approvato per micro-lotto`.
- **Owner/run:** `/root`, sessione 2026-09-22.
- **Esito:** `items/prototypes/CL/GATE_P3R.md` documenta il gate. I due
  blocchi di P3 sono risolti: i glifi scored sono primitive SVG indipendenti
  dal font e `U`/`D` senza contenitore non competono con `□`/`○`. Autorizzato
  un solo lotto P4 di otto stimoli `distinct_substitution`; restano obbligatori
  un nuovo review gate e, prima di ulteriori lotti o integrazione, una prova di
  stampa/marcatura al 100%. `Rscript tests/run_all.R`: 18 file superati.
- **Capacità:** forte QA visivo e comprensione del costrutto Gs.
- **Obiettivo:** verificare che primitive e `U`/`D` eliminino i due blocchi di
  P3 senza introdurre nuovi indizi; decidere se A4 può passare a un micro-lotto.
- **Uscita:** approvare o richiedere un'ulteriore revisione; soltanto se
  approvato definire la dimensione del primo lotto P4.

### P4 — CL espansione controllata

- **Stato:** `review_gate` — primo micro-lotto prodotto; nessun secondo lotto autorizzato.
- **Owner/run:** `/root`, sessione 2026-09-22.
- **Esito:** aggiunti otto stimoli `distinct_substitution`, portando il
  prototipo a 14 righe con 7 chiavi `UGUALE` e 7 `DIVERSO`. Il lotto P4 copre
  una volta ciascuna posizione di differenza e tutti i sei token; i sei
  stimoli P2 sono protetti da snapshot nei test. Rendering completo e dettaglio
  delle nuove righe ispezionati; hash invariati al rebuild. Report in
  `items/prototypes/CL/REVIEW_P4.md`. `Rscript tests/run_all.R`: 18 file
  superati.
- **Capacità:** la stessa di P2.
- **Obiettivo:** aggiungere otto stimoli `distinct_substitution`: quattro
  `UGUALE` e quattro `DIVERSO`, con le differenze nelle posizioni 1–4 e tutti i
  sei token coperti; nessun cambio a layout, timing, scoring o primitive.
- **Uscita:** QA automatico e visivo del lotto. Il passaggio a 100 stimoli non è
  implicito e richiede ripetuti review gate. Nessun secondo lotto è già
  autorizzato.

### P4R — CL review del primo micro-lotto

- **Stato:** `blocked` dalla prova fisica richiesta in P3R.
- **Avanzamento digitale 2026-10-01:** aggiunto e ispezionato il PDF A4
  vettoriale; dimensioni, completezza e seconda rasterizzazione passano. Resta
  il solo controllo fisico di scala e marcabilità.
- **Capacità:** QA visivo e disponibilità di stampa A4 al 100%.
- **Obiettivo:** verificare il foglio a scala fisica, la barra da 50 mm e la
  marcabilità a matita; riesaminare le 14 righe senza modificare il lotto.
- **Uscita:** approvare, revisionare o scartare il micro-lotto. Soltanto
  un'approvazione può definire l'eventuale lotto seguente; nessuna espansione è
  implicita.

### P5 — SS design brief

- **Stato:** `done`.
- **Owner/run:** `/root`, sessione 2026-09-22.
- **Esito:** creato `items/design/SS.md`. Definita una ricerca per congiunzione
  con target `circle_vertical`, cinque distrattori, A4 verticale 20×10,
  composizione 100/100 e un prototipo ridotto 6×10. Vocabolario e composizione
  sono ora nella spec e sottoposti a validazione; il brief mantiene 2–3 minuti
  come durata pianificata e non crea item o fogli scored. `Rscript
  tests/run_all.R`: 18 file superati.
- P3R ha chiarito le convenzioni comuni minime, senza
  autorizzare a copiare la grammatica percettiva di CL.
- **Capacità:** `symbol_grid`, layout stampabile, ricerca visiva.
- **Obiettivo:** definire target, distrattori, densità, layout, conteggi e punti
  aperti, senza inventare una semantica temporale più forte della spec.
- **Uscita:** `items/design/SS.md` pronto per un prototipo separato.

### P5P — SS prototipo ridotto

- **Stato:** `review_gate` — prototipo prodotto; nessuna espansione autorizzata.
- **Owner/run:** `/root`, sessione 2026-09-30.
- **Esito:** creati sorgente e chiave separate per 12 celle di pratica e una
  matrice 6×10 non definitiva, sei primitive SVG deterministiche, generatore e
  rendering A4/300 dpi in `items/prototypes/SS/`,
  `R/build/build_ss_prototype.R` e
  `materials/stimulus_books/prototypes/SS/`. L'ispezione digitale non ha
  rilevato collisioni, clipping o differenze di scala; resta obbligatoria la
  verifica di pop-out e marcabilità nel gate successivo. Corretto nel brief un
  vincolo combinatorialmente impossibile sulle adiacenze, senza cambiare
  composizione. Hash invariati al rebuild; `Rscript tests/run_all.R`: 21 file
  superati. Report in `items/prototypes/SS/REVIEW_P5P.md`.
- **Capacità:** `symbol_grid`, SVG deterministico, rendering A4 e ispezione.
- **Obiettivo:** implementare le sei primitive dichiarate, un blocco pratica da
  12 celle e una matrice non definitiva 6×10 con 30 target e 30 distrattori,
  alle dimensioni finali definite nel brief.
- **Non-obiettivi:** nessun foglio da 200 stimoli, nessuna modifica a timing,
  scoring, vocabolario o composizione.
- **Uscita:** sorgenti separate dalla chiave, SVG/PNG A4 a 300 dpi, QA
  automatico e visivo; poi `review_gate`.

### P5R — SS review gate del prototipo ridotto

- **Stato:** `done` — esito `revisione richiesta`.
- **Owner/run:** `/root`, sessione 2026-10-01.
- **Esito:** `items/prototypes/SS/GATE_P5R.md` documenta il gate. Primitive,
  scala A4, leggibilità digitale e percorso per righe passano; stampa e matita
  sono differite al controllo finale per decisione del responsabile. La
  disposizione non passa: le righe 3 e 6 alternano perfettamente target e
  distrattori, la riga 2 è quasi periodica e i target per colonna variano da 1
  a 4. Nessuna espansione autorizzata. `Rscript tests/run_all.R`: 24 file
  superati.
- **Avanzamento digitale 2026-10-01:** aggiunto e ispezionato il PDF A4
  vettoriale; dimensioni, completezza e seconda rasterizzazione passano.
  Restano marcabilità su carta e giudizio umano su pop-out e salienza.
- **Capacità:** QA visivo di `symbol_grid` e disponibilità di stampa A4 al
  100% per chiudere anche la marcabilità.
- **Obiettivo:** riesaminare le 72 celle senza aggiungerne, confrontare la
  salienza delle sei primitive, verificare il percorso e provare la barratura
  a matita con la barra fisica da 50 mm.
- **Uscita:** approvare, revisionare o scartare il prototipo; soltanto
  un'approvazione può definire il primo lotto successivo. Nessuna forma da 200
  stimoli è implicita.

### P5RR — SS revisione della disposizione ridotta

- **Stato:** `review_gate` — disposizione revisionata; nessuna espansione
  ancora autorizzata.
- **Owner/run:** `/root`, sessione 2026-10-01.
- **Esito:** rimescolate soltanto le 60 celle `prototype`. Conteggi per riga,
  composizione, pratica, primitive e layout sono invariati; ogni colonna ha
  ora 2–4 target, nessuna alternanza supera cinque celle e non esistono righe
  duplicate o complementari. Aggiunti controlli anche contro distrattori
  identici adiacenti in verticale. SVG/PNG riproducibili, PDF A4 e PNG
  ispezionati; report in `items/prototypes/SS/REVIEW_P5RR.md`. `Rscript
  tests/run_all.R`: 24 file superati.
- **Capacità:** `symbol_grid`, generazione deterministica e QA di pattern
  spaziali.
- **Obiettivo:** rimescolare soltanto le 60 celle `prototype`, mantenendo
  pratica, composizione, conteggi per riga, primitive e layout invariati;
  aggiungere test contro alternanze lunghe, colonne sbilanciate e righe
  equivalenti.
- **Non-obiettivi:** nessuna nuova cella, forma da 200, modifica a timing,
  scoring, vocabolario o geometria.
- **Uscita:** sorgente e chiave revisionate, SVG/PDF/PNG rigenerati, QA
  automatico e visivo; poi nuovo `review_gate` digitale.

### P5R2 — SS review gate della disposizione revisionata

- **Stato:** `ready`.
- **Capacità:** QA visivo di `symbol_grid` e controllo di pattern spaziali.
- **Obiettivo:** riesaminare il prototipo P5RR senza aggiungere celle; verificare
  che il rimescolamento elimini gli indizi di P5R senza introdurre nuovi
  pattern o problemi di salienza.
- **Uscita:** approvare, revisionare o scartare la disposizione. Soltanto
  un'approvazione può definire la dimensione del primo lotto di espansione; la
  forma completa non è implicita.

### P6 — Pipeline grafica: capability spike

- **Stato:** `done`.
- **Owner/run:** `/root`, sessione 2026-09-30.
- **Esito:** creati `R/build/build_vector_geometry_spike.R`,
  `tests/test_vector_geometry_spike.R`, una tavola SVG non scored e il
  rendering A4/300 dpi. Verificati spessori, primitive, rotazioni,
  riflessione, giunzioni, sovrapposizione, clipping e slot equivalenti; il PNG
  è stato ispezionato a risoluzione originale e gli hash sono rimasti stabili
  al rebuild. Limiti e strumenti sono documentati in
  `items/prototypes/vector_geometry/SPIKE_P6.md`. `Rscript tests/run_all.R`: 22
  file superati. Restano stampa fisica e portabilità su un secondo ambiente.
- **Capacità:** SVG/script, rendering locale, ispezione delle immagini.
- **Obiettivo:** verificare con un asset non scored che la repository possa
  produrre SVG deterministici, renderizzarli e controllarne dimensioni, font,
  stroke e stampa. Documentare strumenti e limiti reali.
- **Non-obiettivi:** nessuna banca MR/RP/MP/DM; nessuna libreria generale vasta.
- **Uscita:** una pipeline minima dimostrata oppure un blocco tecnico preciso.

### P7 — Primo subtest `vector_geometry`

- **Stato:** `done` per il gate G1 di MR.
- **Owner/run:** `/root`, sessione 2026-09-30.
- **Esito:** creato `items/design/MR.md`. Il brief delimita MR rispetto a RR e
  qVS, definisce quattro famiglie, grammatica vettoriale, progressione,
  distrattori diagnostici e controlli contro regole alternative. Il prossimo
  gate è limitato a quattro matrici 3×3 non definitive della sola famiglia
  `set_combination`, con sorgente e chiave separate. Nessun item scored o
  parametro della spec è stato modificato. `Rscript tests/run_all.R`: 22 file
  superati.
- **Capacità:** forte grafica + progettazione psicometrica.
- **Scelta:** MR, perché blocca QI rapido e QI totale. P6 ha chiuso G0/G2 per
  la pipeline e questo packet ha chiuso il design brief G1, senza item scored.
- **Uscita:** solo G1 o G3, mai la banca completa nello stesso pacchetto.

### P7P — MR prototipo di una famiglia

- **Stato:** `review_gate` — quattro prototipi prodotti; nessuna espansione
  autorizzata.
- **Owner/run:** `/root`, sessione 2026-09-30.
- **Esito:** create quattro matrici 3×3 non definitive della famiglia
  `set_combination`, una per unione, intersezione, differenza e XOR, con
  sorgente geometrica e chiave separate, rationale delle venti alternative e
  quattro tavole A4 SVG/PNG a 300 dpi. Il controllo ricostruisce le operazioni,
  prova l'unicità entro la grammatica finita e confronta geometria e chiave.
  I rendering sono stati ispezionati a risoluzione originale e ricostruiti con
  hash invariati. Il vincolo iniziale di un solo A4 è stato corretto: quattro
  matrici con celle da 30 mm richiedono una tavola ciascuna. Report in
  `items/prototypes/MR/REVIEW_P7P.md`. `Rscript tests/run_all.R`: 23 file
  superati.
- **Capacità:** progettazione di matrici, SVG deterministico, rendering e
  verifica della risposta unica.
- **Obiettivo:** produrre quattro matrici 3×3 non definitive della sola
  famiglia `set_combination`, una per unione, intersezione, differenza e XOR,
  con cinque alternative e rationale dei distrattori.
- **Non-obiettivi:** nessun item bank, nessuna posizione scored, nessuna
  seconda famiglia e nessuna modifica a conteggi, start point o routing.
- **Uscita:** sorgente geometrica e chiave separate, foglio A4 SVG/PNG a 300
  dpi, controlli automatici possibili e ispezione visiva; poi `review_gate`.

### P7R — MR review gate del prototipo `set_combination`

- **Stato:** `ready` per il gate G4.
- **Avanzamento digitale 2026-10-01:** aggiunti e ispezionati i quattro PDF A4
  vettoriali; dimensioni, completezza e seconde rasterizzazioni passano.
  Restano controllo su carta e giudizio umano su regole alternative,
  cardinalità e convenzione della cella mancante.
- **Capacità:** forte QA visivo, comprensione del costrutto Gf e disponibilità
  di stampa A4 al 100% per chiudere il controllo di scala.
- **Obiettivo:** riesaminare le quattro matrici senza aggiungere stimoli;
  cercare regole alternative plausibili, valutare gli indizi di cardinalità,
  decidere la convenzione per la cella mancante e verificare barra da 50 mm,
  stroke e leggibilità su carta.
- **Uscita:** approvare, revisionare o scartare il prototipo. Soltanto
  un'approvazione può definire un primo micro-lotto; nessuna seconda famiglia o
  banca da 24 item è implicita.

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

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-09-26.
- **Esito:** creati `R/data/check_timed_records.R` e
  `data/templates/timed_records.csv` (una riga per persona e prova, colonne
  derivate dalla spec e verificate dai test). Il checker riusa
  `score_fixed_time_record()`, controlla codice, età, componenti di un'altra
  prova compilate per errore, tempo non interpretabile e duplicati, e riporta
  tutti i problemi con il numero di riga; il tempo mancante resta un avviso.
  SS dichiara `hits + omissions <= target_count` tramite
  `max_from: stimulus_composition.target_count`; `load_spec.R` valida ora i
  vincoli aggregati. Istruzioni in `data/README.md`. `Rscript
  tests/run_all.R`: 19 file superati (nuovo `tests/test_timed_records.R`).
- **Aperto:** il vincolo SS è una disuguaglianza; se la correzione finale
  conterà come omissioni anche i target non raggiunti, diventerà
  un'uguaglianza. Decisione rinviata al foglio di correzione SS (vedi
  `items/design/SS.md`, Punti aperti).
- **Obiettivo:** progettare e implementare un controllo semplice per file con
  osservazioni aggregate CL/SS, separato dal checker item-level; riusare
  `score_fixed_time_record()` e la spec. Per SS la composizione ora permette
  di controllare anche `hits + omissions <= target_count` senza hard-codare 100.
- **Non-obiettivi:** Shiny, norme, item CL/SS.
- **Uscita:** template documentato, checker, test su dati validi e invalidi.

### N2 — End-to-end delle forme già complete

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-09-26.
- **Esito:** creato `tests/test_end_to_end_administration.R`, senza ID
  hard-coded: per gli 8 subtest `complete_draft` (tutti i route type
  item-level) profili estremi ai bordi delle fasce d'età e 120 amministrazioni
  simulate con seed attraversano routing, modulo versionato compilato, scorer
  e `check_responses.R`. I punteggi coincidevano già tutti; il test ha però
  trovato avvisi procedurali falsi su somministrazioni corrette (interruzione
  con inversione in `adaptive_items`, ordine basale/ceiling in SM), corretti in
  `R/scoring/administer.R` e documentati nel manuale. Il test è stato
  verificato reintroducendo ciascuno dei due difetti. Routing QA rigenerato:
  identico. `Rscript tests/run_all.R`: 20 file superati.
- **Scoperto:** vedi N4.
- **Obiettivo:** aggiungere amministrazioni sintetiche complete per i subtest
  che hanno già item bank, verificando routing, record e scoring senza toccare
  norme o Shiny.
- **Uscita:** test condivisi per le classi di route, non duplicazioni per ID.

### N3 — Audit delle rubriche aperte

- **Stato:** `done` per CS; SP e QS non sono stati modificati.
- **Owner/run:** `/root`, sessione 2026-10-01.
- **Esito:** auditata la coerenza 0/1/2 di CS. Nei cinque item in cui una
  strategia o un'etichetta potevano ricevere 2 punti senza spiegare il
  meccanismo (CS-SC-01, 03, 04, 05 e 09), chiave strutturata ed esempi ora
  distinguono il nesso causale dalla sola azione pertinente. Aggiunti casi
  limite per ricerca dello zaino, richiesta di aiuto e gestione del conflitto;
  esplicitati anche gli item più esposti a esperienza scolastica, sanitaria,
  lavorativa, sportiva e di trasporto. `tests/test_open_response_rubrics.R`
  controlla la struttura di tutte le rubriche aperte 0/1/2 e protegge i cinque
  casi CS dalla regressione. `Rscript tests/run_all.R`: 24 file superati.
- **Obiettivo:** audit limitato a un solo subtest tra SP, CS e QS per coerenza
  0/1/2, meccanismo richiesto, bias di esperienza e casi limite.
- **Non-obiettivi:** riscrivere contemporaneamente tutte le rubriche.
- **Uscita:** correzioni motivate e regression test dove automatizzabili.

### N3-SP — Audit della rubrica SP

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Esito:** `items/rubrics/SP.md` dichiara ora in testa il criterio 2/1/0
  (tratto definitorio in forma generale / passo corretto non generalizzato /
  significato errato, associazione o circolarità) con quattro avvertenze:
  fluenza verbale, accezioni attestate, risposte guastate e adesione
  all'autorità. Corretti i livelli incoerenti con il criterio: «sottinteso» e
  «passeggero» passano da 1 a 2 come sinonimi; «programmare» da 0 a 1;
  accettate le accezioni attestate di *stanco*, *resistere*, *contraddire*, *ambiguo*,
  *prevedere*, *adattare*, *coerente*, *reciproco*, *arbitrario*,
  *plausibile* e *paradossale*. Aggiunti casi limite e la sezione sugli item
  più esposti a scolarità, contesti specifici, linguaggio educativo e
  plurilinguismo. La query è esplicita anche per risposte solo esemplificative
  (manuale aggiornato). Chiavi strutturate del CSV riallineate; parole, ordine,
  routing, range e `difficulty_target` invariati, quindi nessuna simulazione
  da rigenerare. `items/design/SP.md` ha ora `## Punti aperti`.
  `tests/test_open_response_rubrics.R` richiede a ogni rubrica aperta un
  criterio generale prima degli item, vieta lo stesso esempio a due livelli
  dello stesso item e protegge i tre casi SP; verificato reintroducendo i
  difetti. `Rscript tests/run_all.R`: 24 file superati.
- **Obiettivo:** lo stesso audit di N3, limitato a SP: significato costante dei
  livelli 0/1/2, tratto definitorio richiesto per i 2 punti, sinonimi e
  accezioni attestate, esposizione all'esperienza e casi limite.
- **Non-obiettivi:** nessun cambio di parole, ordine, routing o range.

### N3-QS — Audit della rubrica QS

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Esito:** il criterio di `items/rubrics/QS.md` definisce ora che cosa conta
  come passaggio corretto: un risultato intermedio di un percorso valido, anche
  alternativo; non la sola direzione giusta; un numero detto o indicato sul
  foglio basta, senza spiegazione verbale ordinata. Di conseguenza QS-SC-09
  (metodo additivo) e QS-SC-11 (pompe trattate come uguali) non danno più 1
  punto alla sola direzione; QS-SC-04, 06, 07, 10 e 12 riconoscono passaggi di
  percorsi alternativi prima esclusi. QS-SC-05 rende obbligatoria la domanda
  «Come hai fatto?» per 12/«circa 12», risolvendo l'ambiguità fra «12 esatti» e
  una stima arrotondata. Aggiunte la regola dell'ultima risposta data e la
  sezione sugli item più esposti (denaro, problemi scolastici tipici, cucina).
  CSV, manuale e tabella del design riallineati; problemi, ordine, routing,
  range e `difficulty_target` invariati, nessuna simulazione da rigenerare.
  Regressioni in `tests/test_open_response_rubrics.R`, verificate
  reintroducendo il difetto. `Rscript tests/run_all.R`: 24 file superati.
- **Aperto:** con questo pacchetto N3 è chiuso per CS, SP e QS. Resta per tutti
  e tre il controllo di accordo fra correttori indipendenti, che richiede
  protocolli reali; lo strumento è fornito da N5.
- **Obiettivo:** lo stesso audit di N3, limitato a QS: il punto parziale deve
  marcare un passaggio corretto di un percorso valido, non un metodo diverso
  e sbagliato; casi limite delle stime; esposizione all'esperienza.
- **Non-obiettivi:** nessun cambio di problemi, ordine, routing o range.

### N4 — Dati raccolti per subtest con punteggio derivato

- **Stato:** `done`.
- **Owner/run:** `/root`, sessione 2026-10-01.
- **Decisione:** `responses.csv` resta il template comune e include le colonne
  `recall`, `recognition` e `delay_minutes`, vuote per gli altri subtest. La
  raccolta separata dai soli record form avrebbe frammentato il workflow degli
  studenti e lasciato il checker generale incapace di verificare CR.
- **Esito:** il checker valida le componenti contro la spec, vieta componenti
  nei subtest non pertinenti e `item_score` manuale per CR; per ogni protocollo
  derivato completo invoca lo scorer reale, senza salvare il punteggio. I test
  coprono un CR completo correggibile e il rifiuto di un richiamo fallito senza
  riconoscimento, oltre al percorso end-to-end condiviso. `Rscript
  tests/run_all.R`: 24 file superati.
- **Origine:** N2. `data/templates/responses.csv` ha solo `item_score`; per CR
  il punteggio si deriva da `recall` e `recognition`, e il ritardo effettivo
  sta in `delay_minutes`. Un file di dati raccolti CR supera quindi il
  controllo strutturale, ma non contiene ciò che serve per calcolarne il
  punteggio.
- **Decisione richiesta:** aggiungere al template le colonne delle componenti
  (vuote per gli altri subtest, come in `timed_records.csv`) oppure raccogliere
  CR direttamente dai moduli di registrazione.
- **Uscita:** template e checker coerenti con la scelta, test che un record CR
  raccolto sia correggibile senza ricostruire le componenti a mano.

### N5 — Accordo fra correttori per le rubriche aperte

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Esito:** creati `data/templates/scorer_agreement.csv` (una riga per
  risposta, `score_a`/`score_b`) e `R/data/check_scorer_agreement.R`. I subtest
  ammessi sono letti dalla spec (risposta aperta e scala 0/1/2: oggi SP, CS,
  QS); il predicato è condiviso con `tests/test_open_response_rubrics.R`. Il
  checker rifiuta item di prova, item di altri subtest, punteggi non ammessi,
  correzioni mancanti, risposte vuote e duplicati, riportando tutti i problemi
  con il numero di riga; poi riporta per subtest e item accordo esatto, kappa
  pesato quadratico, differenza media A−B e disaccordi 2 contro 0. Nessuna
  soglia; avviso sotto 30 risposte. Istruzioni in `data/README.md`, rinvio
  dalle tre rubriche. `tests/test_scorer_agreement.R` confronta i coefficienti
  con valori calcolati a mano (kappa 2/7). `Rscript tests/run_all.R`: 25 file
  superati.
- **Aperto:** il controllo vero richiede protocolli reali corretti da due
  persone; nessun dato è stato inventato.
- **Origine:** N3, N3-SP e N3-QS. Le tre rubriche aperte dichiarano che prima
  di considerarle stabili serve un controllo di accordo fra due correttori
  indipendenti, ma la repository non offre un modo per farlo.
- **Obiettivo:** template CSV e checker semplice che, per i subtest con
  rubrica aperta 0/1/2 letti dalla spec, validi una doppia correzione e riporti
  accordo esatto, kappa pesato, differenza media fra correttori e disaccordi di
  due livelli per item.
- **Non-obiettivi:** nessuna soglia di accettazione automatica, nessuna
  modifica alle rubriche, nessun protocollo inventato presentato come dato.
- **Uscita:** template, checker, istruzioni in `data/README.md`, test con
  valori calcolati a mano.

### N6 — Manuale di somministrazione contro spec

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Esito:** trovata una divergenza reale: manuale e rubrica CR indicavano il
  filler `F15_A` per l'intervallo CR, mentre spec e specifica legacy assegnano
  a CR il filler visivo `F15_V` (`F15_A`, uditivo-verbale, è per DM). Corretti
  entrambi, con la regola operativa legacy dei 14 minuti. Il manuale ha ora
  la sezione «Ordine di somministrazione» con le tre sequenze della spec, i
  subtest oggi disponibili e le durate previste; dichiara che neanche il QI
  rapido è calcolabile senza MR; QS riporta la clausola di non inversione già
  presente per CS. Aggiunte le regole comuni per sedute interrotte, rifiuto,
  item saltati, regole applicate male e item compromessi, coerenti con gli
  stati della spec, e per SP e CS la convenzione v0 sul silenzio (30 secondi,
  un incoraggiamento che non conta come query), allineata a RS, RR e QS.
  `tests/test_manual_spec.R` confronta con la spec range, punti di partenza,
  filler, sequenze e durate; verificato con cinque mutazioni. `Rscript
  tests/run_all.R`: 26 file superati.
- **Scoperto:** N7. Le soglie di silenzio (20, 30, 60, 90 secondi) restano
  nelle rubriche e non nella spec, come quelle già esistenti.
- **Origine:** audit del manuale rispetto alla checklist 7.1 della roadmap.
- **Obiettivo:** correggere le divergenze fra `manual/ADMINISTRATION.md` e
  `spec/`, documentare l'ordine di somministrazione e le durate previste, e
  aggiungere un test che impedisca la ricomparsa delle divergenze.
- **Non-obiettivi:** nessuna nuova regola di routing, nessun filler costruito,
  nessuna decisione sull'intervallo CR con batteria incompleta.

### N7 — Decisione: intervallo CR con la batteria incompleta

- **Stato:** `done` — decisione del responsabile, 2026-10-01.
- **Origine:** N6. Fra studio e recupero CR la spec prevede RP, CL e il filler
  `F15_V`; nessuno dei tre esiste.
- **Esito:** scelta l'opzione «CR solo in esercitazione finché RP e CL non
  esistono», documentata in
  `docs/decisions/0007-cr-interval-with-incomplete-battery.md` insieme alle
  alternative scartate (un filler `F15_V` da 2–4 minuti non coprirebbe
  l'intervallo; una sequenza provvisoria con RR e PG avrebbe introdotto nella
  spec un ordine diverso da quello finale). Spec invariata; il manuale rinvia
  al decision record.

### N8 — Punteggi grezzi dai dati raccolti

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Origine:** obiettivo 7 della v0 e FASE 8. I checker verificavano i dati
  raccolti ma nessun comando ne salvava i punteggi grezzi.
- **Esito:** creato `R/data/score_collected.R`: riusa `check_responses.R` e
  `check_timed_records.R` (si ferma su file non validi), poi corregge ogni
  protocollo persona × subtest con `score_subtest_record()` o con i punteggi
  timed già calcolati, e restituisce `raw_score`, `raw_max`, `status`
  (`complete`, `external_missing_or_invalidated`, `incomplete_record`) e
  `notes`. Scrive un CSV solo con `--out`. Nessun punteggio ponderato, indice o
  QI. Istruzioni in `data/README.md`. `tests/test_score_collected.R` verifica
  un protocollo SP con basale inferito e ceiling (grezzo 21, calcolato a mano),
  un item esterno mancante, un protocollo incompleto, un record CL e il blocco
  su file non validi. `Rscript tests/run_all.R`: 27 file superati.
- **Non-obiettivi rispettati:** nessuna norma, nessuna Shiny.

### N9 — Colonna `query_used` derivata dalla spec

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Origine:** N6. Solo il modulo SP aveva `query_used`, scritto a mano nel
  generatore per ID; CS e QS, che hanno la stessa query, la annotavano in
  `notes`.
- **Esito:** `open_response_subtests()` è ora in `R/items/load_items.R` ed è
  l'unico criterio per moduli, accordo fra correttori e test delle rubriche.
  Il generatore aggiunge `query_used` a ogni subtest con rubrica aperta 0/1/2;
  rimossa la lista per ID. Moduli rigenerati: cambiano solo CS e QS. Manuale e
  README dei moduli indicano `1` per una query fatta. Routing QA non da
  rigenerare: spec invariata. `Rscript tests/run_all.R`: 27 file superati.
- **Aperto:** `data/templates/responses.csv` non ha `query_used`, quindi
  l'informazione resta nel modulo e non passa ai dati raccolti. Aggiungerla
  cambierebbe le colonne obbligatorie del checker per tutti i file esistenti:
  decisione rinviata.

### N10 — QA concettuale degli item RS

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Esito:** revisionati i 26 item RS secondo la roadmap 10.2. Corretti sette
  item senza cambiare lettere delle chiavi, ordine, routing o
  `difficulty_target`: un omofono in presentazione orale (RS-SC-03), una
  seconda risposta difendibile (RS-SC-12, RS-SC-22), indizi di lunghezza delle
  opzioni (RS-SC-14, RS-SC-21) e due parole condivise con SP (RS-SC-06,
  RS-SC-23). Il nuovo controllo comune sulle opzioni più lunghe ha trovato lo
  stesso indizio in RR-SC-14 (unico gruppo di quattro figure), corretto. Dettagli
  e punti da osservare nel pilot in `items/design/RS.md` e `items/design/RR.md`;
  chiave rapida RS e RR aggiornate. Nuovi controlli in
  `tests/test_multiple_choice_banks.R` e `tests/test_cross_subtest_overlap.R`,
  verificati reintroducendo i difetti. `Rscript tests/run_all.R`: 28 file
  superati.
- **Successore:** N11 (RR), poi CR.

### N11 — QA concettuale degli item RR

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Esito:** verificata a mano la logica dei 22 item. Tutti e quattro gli item
  `rule_induction` ammettevano una regola alternativa semplice, coerente con gli
  esempi, che accettava un distrattore: RR-SC-06 («stessa forma»: D era «○●»),
  RR-SC-11 («ultima figura piena»), RR-SC-16 («comincia con un cerchio»,
  «quadrato al centro») e RR-SC-20 («seconda figura vuota»). Corretti esempi
  negativi o opzioni senza cambiare le chiavi; il rationale di RR-SC-06, che
  descriveva male l'opzione D, è ora vero. RR-SC-03 usa «prima del» al posto di
  «davanti al». Nuovo `tests/test_rr_rule_induction.R`: prova tutte le regole di
  una o due condizioni su forma, riempimento, posizione e conteggio; rileva
  singolarmente ciascuno dei quattro difetti originali. `Rscript
  tests/run_all.R`: 29 file superati.
- **Limite:** gli item `constraint_ordering`, `conditional_rule`,
  `series_completion` e `rule_transformation` sono stati verificati a mano; il
  test copre solo l'induzione, dove il rischio è strutturale.

### N12 — QA concettuale degli item CR

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Esito:** coppie conformi ai vincoli dichiarati (nessuna rima,
  allitterazione o collocazione; cue e bersagli distinti), salvo «violino» di
  quattro sillabe, ora dichiarato. Nel riconoscimento tre item offrivano come
  distrattore un bersaglio di un'altra coppia fortemente associato al cue
  (fiume→barca, albero→mela, gatto→pesce): sostituiti senza cambiare chiavi,
  coppie o ordine, riequilibrando anche l'uso dei bersagli come distrattori
  (prima da 0 a 4 volte, ora da 1 a 3, vincolo testato). Chiave in
  `items/rubrics/CR.md` aggiornata. Le possibili intrusioni nel richiamo
  restano un punto aperto in `items/design/CR.md`. `Rscript tests/run_all.R`:
  29 file superati.

### N13 — Vincoli SM verificati sul CSV

- **Stato:** `done`.
- **Owner/run:** sessione Claude Code 2026-10-01.
- **Esito:** QA di SM e PG. PG verificava già sul CSV tutti i vincoli
  dichiarati. In SM tre vincoli su cinque (nessuna run di tre cifre
  consecutive, sequenza non monotona, sequenza da riordinare non già ordinata)
  erano applicati solo da `R/build/build_sm_items.R`, quindi un item sostituito
  a mano li avrebbe aggirati. Aggiunti in `tests/test_sm_scoring.R`; il banco
  attuale li rispetta tutti e le mutazioni vengono rilevate. Nessun item
  modificato. `Rscript tests/run_all.R`: 29 file superati.

## Aggiornamento obbligatorio della coda

Chi chiude un pacchetto deve:

1. cambiarne lo stato;
2. indicare i file prodotti e l'esito dei test;
3. rendere `ready` soltanto il successore i cui prerequisiti sono davvero
   soddisfatti;
4. aggiungere nuovi pacchetti scoperti, ma senza promuoverli automaticamente;
5. non marcare un subtest `complete_draft` prima che l'intera checklist in
   `AGENTS.md` sia soddisfatta.
