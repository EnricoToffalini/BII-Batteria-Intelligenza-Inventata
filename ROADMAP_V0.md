# BII — Roadmap verso la Versione 0 didatticamente utilizzabile

> **Stato del documento:** piano operativo per trasformare la BII (Batteria d'Intelligenza Inventata) da specifica psicometrica + simulazioni + scoring dimostrativo in una **mock battery completa, somministrabile, correggibile e utilizzabile dagli studenti come se fosse una vera batteria**, pur restando esplicitamente didattica e non clinica.
>
> **Principio guida:** la BII v0 non deve essere costruita intorno alle simulazioni attuali. Al contrario, le simulazioni, le norme simulate, i parametri di scoring e la Shiny app devono essere **artefatti derivati e rigenerabili** dalla specifica della batteria. Se la costruzione degli stimoli mostra che numero di item, difficoltà, start point, stop rule, scoring o architettura di un subtest vanno modificati, si modifica la specifica e si rigenera ciò che dipende da essa.

---

## 1. Obiettivo della v0

La **BII v0** è raggiunta quando uno studente che non ha contribuito allo sviluppo può:

1. capire che cosa misura la batteria e quali sono i suoi limiti;
2. scegliere tra QI rapido, QI totale e batteria completa;
3. scaricare/aprire tutti i materiali necessari;
4. somministrare la batteria a un'altra persona senza dover inventare istruzioni o procedure;
5. applicare correttamente start point, inversione/basal, stop/ceiling, timing e filler;
6. registrare le risposte item per item o, dove appropriato, le componenti osservate del punteggio;
7. ottenere automaticamente punteggi grezzi, punteggi ponderati, indici e quozienti simulati;
8. capire quali risultati sono descrittivi, quali sono simulati e quali non devono essere interpretati clinicamente;
9. ripetere l'intero workflow in modo riproducibile;
10. proporre miglioramenti tramite issue/PR senza rompere silenziosamente la coerenza della batteria.

La v0 **non** deve ancora essere una batteria psicometricamente validata su dati reali.

---

## 2. Non-obiettivi della v0

Non sono necessari per chiudere la v0:

- norme empiriche reali;
- validazione clinica o diagnostica;
- cut-off clinici;
- certificazione professionale;
- equivalenza con batterie commerciali;
- IRT definitiva o adaptive testing computerizzato reale;
- validazione transculturale completa;
- validazione esterna di costrutto/criterio;
- studio completo di fairness e measurement invariance su campioni reali.

Questi elementi appartengono a una futura fase **v1+ / pilot empirico**.

---

# 3. Principi architetturali non negoziabili

## 3.1 Una sola fonte di verità

Le informazioni fondamentali della batteria non devono essere duplicate manualmente in più file.

La fonte di verità dovrebbe diventare una specifica strutturata e leggibile da codice, per esempio:

```text
spec/
  battery.yml
  subtests/
    SP.yml
    RS.yml
    ...
  schemas/
    subtest.schema.json
    item.schema.json
```

Da questa specifica devono derivare, per quanto possibile:

- manuale;
- tabelle riassuntive;
- controlli di coerenza;
- scoring;
- simulazioni;
- range validi nella Shiny app;
- documentazione tecnica;
- metadati degli item.

## 3.2 Le simulazioni sono build artifacts concettuali

Qualunque modifica a:

- numero di item;
- scoring;
- range grezzo;
- famiglie di item;
- distribuzione di difficoltà;
- start point;
- basal/inversion;
- stop/ceiling;
- limiti temporali;
- composizione di indici/QI;
- struttura dei subtest;

può richiedere la rigenerazione di:

- dataset simulato;
- tabelle grezzo → PP;
- tabelle PP → SS;
- CFA;
- reliability;
- grafici;
- dati di esempio;
- Shiny app;
- documentazione dei punteggi.

**Non è un problema. È il comportamento desiderato.**

## 3.3 Nessuna correzione locale che nasconda un conflitto globale

Se un agente trova, per esempio:

- un subtest dichiarato 4×4 ma con item 5×5;
- un range grezzo incoerente con il numero di item;
- una regola generale incompatibile con una regola specifica;
- norme che presuppongono un massimo diverso da quello del manuale;

non deve “far funzionare” solo il file locale. Deve:

1. identificare la fonte di verità;
2. proporre o applicare la modifica lì;
3. aggiornare/ricalcolare tutti i derivati;
4. aggiungere un test che impedisca la ricomparsa dell'incoerenza.

## 3.4 Riproducibilità prima dell'eleganza

Ogni stimolo generabile deterministicamente dovrebbe esserlo.

Preferire:

- SVG;
- PDF generati da sorgenti versionati;
- CSV/YAML/JSON per item testuali;
- seed espliciti nelle simulazioni;
- script di build;

rispetto a file grafici modificati manualmente senza sorgente riproducibile.

---

# 4. Struttura target della repository

Non è necessario migrare tutto in un solo commit. Questa è la destinazione consigliata.

```text
/
├── README.md
├── AGENTS.md
├── ROADMAP_V0.md
├── CHANGELOG.md
├── LICENSE
│
├── spec/                         # SOURCE OF TRUTH
│   ├── battery.yml
│   ├── subtests/
│   │   ├── SP.yml
│   │   ├── RS.yml
│   │   └── ...
│   └── schemas/
│       ├── battery.schema.json
│       ├── subtest.schema.json
│       └── item.schema.json
│
├── items/
│   ├── source/                   # item bank strutturato
│   │   ├── SP.csv
│   │   ├── MR.csv
│   │   └── ...
│   ├── assets_src/               # sorgenti SVG / script / geometrie
│   └── assets_rendered/          # output visuali per uso didattico
│
├── manual/
│   ├── THEORY.md
│   ├── ADMINISTRATION.md
│   ├── SCORING.md
│   ├── INTERPRETATION.md
│   └── CHANGE_POLICY.md
│
├── materials/
│   ├── stimulus_books/
│   ├── record_forms/
│   ├── response_sheets/
│   ├── filler/
│   └── manipulatives/
│
├── R/
│   ├── scoring/
│   ├── simulation/
│   ├── norming/
│   ├── validation/
│   └── build/
│
├── norms_BII/
│   ├── generated/
│   └── manifests/
│
├── shiny/
│   └── ...
│
├── tests/
│   ├── spec/
│   ├── scoring/
│   ├── simulation/
│   ├── stimuli/
│   └── integration/
│
└── docs/
    ├── decisions/
    ├── development/
    └── contributing/
```

### Nota

Per la v0 è accettabile mantenere temporaneamente `_BII - Batteria Intelligenza Inventata.md` come documento principale, ma il suo contenuto deve progressivamente diventare **derivato o sincronizzato** con `spec/` e `manual/`, non una seconda fonte di verità indipendente.

---

# 5. Roadmap esecutiva

---

## FASE 0 — Preparare il repository per lavoro agentico

### Scopo
Rendere sicuro il lavoro di più agenti e impedire che modifiche indipendenti creino divergenze.

### Task

- [x] Aggiungere `README.md` con:
  - scopo;
  - disclaimer didattico;
  - stato corrente;
  - quick start;
  - link alla roadmap.
- [x] Aggiungere `AGENTS.md` repo-level.
- [x] Aggiungere `CHANGELOG.md`.
- [x] Aggiungere `docs/decisions/` per decisioni architetturali significative.
- [x] Definire convenzioni per ID di subtest, item, asset e versioni.
- [x] Definire un comando unico di test, per esempio `Rscript tests/run_all.R`.
- [x] Definire un comando unico di rebuild, per esempio `Rscript R/build/rebuild_all.R`.
- [ ] Aggiungere controlli automatici minimi su:
  - file mancanti;
  - duplicazioni ID;
  - range incompatibili;
  - riferimenti ad asset inesistenti.

> Stato 2026-09-09: il runner di test effettua già i controlli di presenza,
> ID di subtest duplicati e validità di base dei range nella baseline legacy.
> I controlli completi su item, range e asset saranno implementati quando
> esisteranno `spec/` e l'item bank (fase 1–2).

### Criterio di accettazione
Un agente nuovo deve poter capire il repository e sapere come testare una modifica senza istruzioni aggiuntive.

### Modello consigliato
**GPT-5.6 Terra, reasoning medio.**

Escalare a **Sol/high** solo per definire l'architettura iniziale se emergono conflitti importanti.

---

## FASE 1 — Formalizzare la specifica della batteria

### Scopo
Trasformare il markdown corrente in una specifica strutturata verificabile.

### Per ogni subtest definire almeno

```yaml
id: MR
name: Matrici di Regole
domain: Gf
role: core
contributes_to:
  - qIF
  - QI_rapido
  - QI_totale
response_format: multiple_choice
scoring_type: dichotomous
n_scored_items: 24
n_practice_items: 2
raw_min: 0
raw_max: 24
time_limit: null
start_points:
  age_6_8: 1
  age_9_12: 5
  age_13_plus: 9
basal_rule: ...
ceiling_rule: ...
item_ordering: increasing_difficulty
stimulus_mode: visual
```

### Task

- [ ] Estrarre tutti i 15 subtest dal documento corrente.
- [ ] Formalizzare:
  - ruolo;
  - dominio CHC;
  - formato;
  - timing;
  - scoring;
  - start point;
  - inversione/basal;
  - stop/ceiling;
  - range;
  - relazione con QI/indici.
- [ ] Formalizzare QI rapido, QI totale e indici.
- [ ] Formalizzare la sequenza CR/DM e i filler.
- [ ] Definire esplicitamente cosa è:
  - `core`;
  - `completion`;
  - `supplementary`.
- [ ] Risolvere tutte le incoerenze note e quelle trovate durante l'estrazione.
- [ ] Implementare validation schema.

### Criterio di accettazione
Tutte le proprietà strutturali della batteria devono essere interrogabili dal file di specifica senza leggere prosa libera.

### Modello consigliato
**GPT-5.6 Sol, reasoning high.**

Questo è un task ad alta densità concettuale e con forte rischio di inconsistenza trasversale.

---

## FASE 2 — Definire lo schema item-level

### Scopo
Passare da “esempi di item” a un vero item bank versionato.

### Schema minimo consigliato

Ogni item dovrebbe avere, quando applicabile:

```text
item_id
subtest
version
status
practice_or_scored
order
family
difficulty_target
difficulty_rank
age_floor
prompt
stimulus_asset
options
correct_answer
scoring_key
scoring_rubric
max_points
distractor_rationale
allowed_prompts
notes_for_examiner
content_flags
source_status
review_status
```

### Per item aperti aggiungere

- esempi da 2/1/0 punti;
- risposte borderline;
- sinonimi accettabili;
- casi che richiedono query neutra;
- risposte non accettabili.

### Per item visivi aggiungere

- descrizione formale della regola;
- sorgente dell'asset;
- bounding box / dimensioni;
- risposta corretta;
- rationale dei distrattori;
- controllo mirror/rotation/position.

### Criterio di accettazione
Ogni item deve essere identificabile, modificabile e collegabile allo scoring senza affidarsi alla posizione in un PDF.

### Modello consigliato
**Sol/high** per definire lo schema; **Terra/medium** per implementarlo e popolarlo.

---

## FASE 3 — Costruire gli stimoli completi

### Scopo
Creare gli item effettivamente somministrabili.

### Strategia generale

Non generare subito tutti gli item di tutti i subtest.

Per ogni subtest usare il ciclo:

1. definire 3–6 famiglie di item;
2. costruire pochi prototipi;
3. controllare validità apparente e contaminazioni;
4. definire una scala di difficoltà prevista;
5. generare il set completo;
6. fare QA automatico;
7. fare revisione concettuale indipendente;
8. solo dopo bloccare temporaneamente quel subtest.

### 3A. Stimoli testuali

Subtest principalmente testuali/orali:

- SP;
- RS;
- CS;
- RR, almeno in parte;
- QS;
- CR.

#### Task

- [ ] Generare item completi.
- [ ] Evitare dipendenze eccessive da cultura scolastica non voluta.
- [ ] Costruire distractor rationale quando applicabile.
- [ ] Costruire rubriche per scoring aperto.
- [ ] Controllare ambiguità semantica.
- [ ] Controllare che non esistano più risposte corrette non previste.
- [ ] Controllare la plausibilità per fascia d'età.

#### Modello

**Terra/high** per generazione in batch piccoli.

**Sol/high** per:

- item difficili;
- rubriche aperte;
- audit finale di ambiguità;
- bilanciamento tra costrutto e contaminazioni.

Non usare Luna per la generazione sostanziale di item psicometrici.

### 3B. Stimoli visivi

Subtest con componente grafica forte:

- MR;
- MO;
- RP;
- MP;
- PG;
- CL;
- SS;
- DM;
- filler F15.

#### Preferenza tecnica

Usare **stimoli vettoriali deterministici** e versionabili quando possibile:

- SVG;
- coordinate/primitive geometriche;
- generatori scriptati;
- layout riproducibili.

Evitare di affidare item centrali a immagini generative raster non riproducibili.

#### Task

- [ ] Creare una grammatica visiva per ogni subtest.
- [ ] Definire famiglie di regole.
- [ ] Generare sorgenti SVG.
- [ ] Generare alternative/distrattori con trasformazioni controllate.
- [ ] Verificare che la risposta corretta sia unica.
- [ ] Verificare che difficoltà visiva e difficoltà concettuale non vengano confuse accidentalmente.
- [ ] Uniformare dimensioni, line weight, spacing e contrasto.
- [ ] Rendere gli stimoli stampabili.

#### Modello

**Terra/high** per implementazione SVG e generatori.

**Sol/high** per la progettazione delle famiglie di regole e la revisione psicometrica.

### Regola fondamentale

Se gli stimoli mostrano che la progressione di difficoltà prevista non è credibile, **modificare la specifica**, anche se ciò richiede di cambiare start point, stop rule o simulazioni.

---

## FASE 4 — Stabilire difficoltà, start point, basal e ceiling in modo coerente

### Scopo
Rendere le procedure adattive internamente plausibili rispetto agli item reali.

### Metodo v0

Non fingere una calibrazione empirica che non esiste.

Usare una classificazione di difficoltà **progettuale**, non normativa:

- `difficulty_rank` ordinalmente crescente;
- `difficulty_target` su scala comune, per esempio -3 ... +3;
- famiglie di item distribuite lungo la scala;
- start point scelti in modo da ridurre inversioni inutili nella simulazione;
- ceiling scelto in modo da non troncare eccessivamente la distribuzione simulata.

### Task

- [ ] Definire una metrica di difficoltà progettuale comune.
- [ ] Assegnare difficoltà a ogni item.
- [ ] Simulare performance item-level per età/abilità.
- [ ] Quantificare:
  - numero medio di item somministrati;
  - frequenza di inversione;
  - frequenza di ceiling;
  - floor/ceiling effettivi;
  - perdita di informazione dovuta allo stop.
- [ ] Modificare iterativamente item ordering/start/stop se necessario.

### Criterio di accettazione
Le regole adattive devono produrre un comportamento plausibile nella popolazione simulata e non derivare solo da convenzioni arbitrarie.

### Modello

**GPT-5.6 Sol/high** per progettazione e analisi.

**Terra/medium-high** per implementare simulazioni e report automatici.

---

## FASE 5 — Rifattorizzare la simulazione: da punteggio totale a item-level

### Priorità
**Alta.** È uno dei cambiamenti strutturali più importanti per rendere coerenti stimoli, regole adattive e norme simulate.

### Problema
Una simulazione che genera direttamente un punteggio totale può essere utile per una demo, ma non può rappresentare adeguatamente:

- start point;
- inversioni;
- basal;
- stop/ceiling;
- item difficulty;
- pattern di errori;
- item omitted/non administered;
- differenza tra full latent performance e score osservato dopo routing adattivo.

### Nuova architettura consigliata

#### Dicotomici
Modello logistico item-level semplificato:

```text
P(correct_ij) = logistic(a_i * (theta_j - b_i))
```

Per la v0 è sufficiente anche una forma Rasch-like con `a_i = 1`, salvo ragioni specifiche.

#### Polytomici 0/1/2
Usare un modello semplice a soglie ordinate o una funzione generativa equivalente.

#### Span / livelli
Simulare probabilità di successo dipendente da:

- theta;
- lunghezza;
- micro-blocco;
- eventuale trasformazione richiesta.

#### Timed tasks
Separare almeno:

- quantità tentata;
- accuratezza;
- errori/falsi allarmi;
- omissioni.

#### Memory tasks
Mantenere componenti separate:

- recall;
- recognition;
- hit;
- false alarm;
- retention delay.

### Pipeline

```text
latent traits
  -> item responses complete
  -> administration algorithm
  -> observed administered responses
  -> raw scores
  -> PP
  -> indices/QI
  -> validation summaries
```

### Manifest di simulazione
Ogni rebuild deve salvare:

- seed;
- versione spec;
- hash della spec;
- commit SHA se disponibile;
- parametri di simulazione;
- dimensione campione;
- data build.

### Criterio di accettazione
Da un clean clone deve essere possibile rigenerare tutte le norme simulate e ottenere gli stessi output con lo stesso seed.

### Modello

**GPT-5.6 Sol/high o xhigh** per progettazione/refactor iniziale.

**Terra/high** per implementazioni successive, test e ottimizzazioni locali.

---

## FASE 6 — Rigenerare norme simulate e controlli psicometrici

### Scopo
Fare in modo che le norme siano conseguenza della batteria corrente.

### Task

- [ ] Rigenerare campione simulato.
- [ ] Rigenerare grezzo → PP per fascia d'età.
- [ ] Rigenerare somme PP → SS.
- [ ] Ricontrollare:
  - media/SD;
  - monotonicità;
  - floor/ceiling;
  - distribuzioni;
  - correlazioni tra subtest;
  - CFA;
  - reliability/composite reliability;
  - sviluppo con età;
  - stabilità delle conversioni.
- [ ] Generare automaticamente un report di QA.

### Regola
Non ottimizzare manualmente il modello solo per ottenere fit “belli”.

Definire prima target plausibili e documentare qualunque tuning.

### Nota su N simulato
Se le tabelle normative risultano instabili per puro rumore Monte Carlo, aumentare il campione simulato di riferimento invece di applicare smoothing ad hoc non documentato.

### Naming
Evitare termini che possano far sembrare empiriche le norme.

Preferire nomi tipo:

```text
simulated_norms_v0
reference_simulation
synthetic_standardization_sample
```

piuttosto che `OFFICIAL` se può generare ambiguità.

### Modello

**Terra/high** per rebuild e pipeline.

**Sol/high** per audit psicometrico finale.

---

## FASE 7 — Costruire il kit di somministrazione

### Scopo
Trasformare la BII in uno strumento che una terza persona può davvero usare.

### Deliverable obbligatori

#### 7.1 Manuale esaminatore

Per ogni subtest:

- scopo;
- materiali;
- preparazione;
- istruzione verbatim;
- item di prova;
- feedback consentito durante le prove;
- prompt consentiti;
- prompt vietati;
- start point;
- inversione/basal;
- stop/ceiling;
- timing;
- scoring;
- esempi di scoring;
- gestione di interruzioni/errori procedurali;
- note qualitative facoltative.

#### 7.2 Stimulus Book

- paginazione stabile;
- univocità item ID;
- dimensioni uniformi;
- istruzioni per l'esaminatore separate dagli stimoli;
- nessuna risposta visibile al soggetto.

#### 7.3 Record Form

Deve consentire di registrare:

- item somministrati;
- punteggi;
- item sotto basal inferiti;
- item sopra ceiling non somministrati;
- omissioni reali;
- interruzioni;
- tempi;
- CR/DM delay;
- filler;
- note procedurali.

#### 7.4 Fogli risposta

Per CL, SS e altri subtest carta-matita.

#### 7.5 Materiali manipolativi

Per MO e qualunque altro subtest che ne richieda.

### Criterio di accettazione
Una persona nuova deve poter somministrare la batteria senza consultare il codice R.

### Modello

**Terra/high** per redazione e impaginazione sorgente.

**Sol/high** per audit di standardizzazione delle istruzioni.

---

## FASE 8 — Portare lo scoring a response-level

### Scopo
Fare in modo che il software possa verificare anche la procedura, non solo convertire un totale già calcolato.

### Input target

Per quanto possibile:

```text
subject metadata
age
subtest
item_id
administered
response
item_score
response_time (se previsto)
administration_reason
notes
```

### Stati distinti obbligatori

Non confondere:

- risposta errata;
- omissione;
- non somministrato sotto basal;
- non somministrato sopra ceiling;
- non somministrato per problema esterno;
- item invalidato.

### Funzioni minime

- [ ] scoring item-level;
- [ ] applicazione automatica basal/ceiling;
- [ ] raw score;
- [ ] PP;
- [ ] indici/QI;
- [ ] warning procedurali;
- [ ] validità minima del subtest;
- [ ] export di un report didattico.

### Test critici

- score manuale = score software;
- routing adattivo atteso = routing software;
- missing esterno non viene trattato come errore;
- sotto basal e sopra ceiling sono codificati correttamente;
- range massimi derivano dalla spec.

### Modello

**Terra/high** per implementazione ordinaria.

**Sol/high** per API/scoring architecture e casi limite.

---

## FASE 9 — Evolvere la Shiny app

### Scopo
Passare da calcolatore dimostrativo a frontend didattico coerente con il workflow della batteria.

### Livelli di implementazione

#### v0 minimo

- inserimento età;
- inserimento grezzi;
- PP/SS/QI;
- profilo;
- disclaimer evidente;
- version/hash delle norme simulate usate.

#### v0 preferibile

- import record form CSV;
- scoring automatico item-level;
- warning su dati/procedure;
- visualizzazione di raw → PP → SS;
- modalità “esempio casuale”;
- possibilità di scaricare report didattico.

### Importante
La Shiny app non deve avere hard-coded indipendenti:

- max raw;
- composizione indici;
- range;
- labels;

se tali informazioni esistono nella spec.

### Modello

**Terra/medium-high** come default.

**Sol/high** se è necessaria una rifattorizzazione profonda dell'architettura.

---

## FASE 10 — QA degli stimoli e della batteria completa

### 10.1 QA automatico

Creare controlli per:

- ID duplicati;
- ID mancanti;
- item count;
- range grezzo;
- answer key mancanti;
- asset mancanti;
- alternative duplicate;
- più opzioni identiche;
- ordine di difficoltà non monotono quando previsto;
- start point fuori range;
- ceiling impossibile;
- mismatch tra spec e item bank;
- mismatch spec ↔ Shiny;
- mismatch spec ↔ norme.

### 10.2 QA concettuale per item

Ogni item deve essere revisionato almeno per:

- univocità della risposta;
- chiarezza;
- costrutto target;
- contaminazioni;
- difficoltà prevista;
- adeguatezza per età;
- cue accidentali;
- qualità dei distrattori.

### 10.3 QA visuale

Per ogni PDF/materiale:

- overflow;
- tagli;
- pagine errate;
- dimensioni incoerenti;
- font troppo piccoli;
- contrasto insufficiente;
- risposte accidentalmente visibili;
- griglie distorte;
- scaling di stampa.

### 10.4 End-to-end test

Creare almeno 5 profili sintetici:

1. bambino basso livello;
2. bambino medio;
3. adolescente medio;
4. giovane adulto medio-alto;
5. profilo disomogeneo.

Per ciascuno simulare l'intera somministrazione e verificare:

- routing;
- scoring;
- conversione;
- report.

### Modello

**Luna/medium** per lint e test ripetitivi.

**Terra/high** per bug fixing.

**Sol/high/xhigh** per audit finale cross-cutting.

---

## FASE 11 — Freeze della v0

### Freeze non significa “immutabile”

Significa che per la prima volta esiste una versione internamente coerente che può essere usata in aula.

### Checklist release

- [ ] 15 subtest con item completi;
- [ ] item di prova completi;
- [ ] answer keys/rubriche complete;
- [ ] materiali completi;
- [ ] manuale esaminatore completo;
- [ ] record form completo;
- [ ] scoring automatico verificato;
- [ ] norme simulate rigenerate dalla spec corrente;
- [ ] QA report senza errori bloccanti;
- [ ] disclaimer didattico chiaro;
- [ ] README quick start;
- [ ] versione/tag release;
- [ ] manifest di build.

### Versioning consigliato

Usare semantic versioning pre-1.0:

```text
v0.1.0  prima mock battery completa e somministrabile
v0.2.0  revisione significativa di item/procedure
v0.x.y  fix non strutturali
v1.0.0  solo molto più avanti, dopo una soglia esplicita di maturità empirica
```

---

# 5.5 Requisito trasversale — sostituibilità per studenti

La v0 deve permettere di sostituire gradualmente mock item e dati simulati
senza richiedere competenze da ingegneri.

- Item e chiavi devono essere file leggibili (di norma CSV/Markdown) con una
  breve guida vicino ai file.
- Le raccolte devono partire da modelli CSV anonimi e da un comando di
  controllo che non modifichi dati.
- I dati raccolti, gli output simulati e gli eventuali dataset empirici
  revisionati devono restare separati e dichiarare chiaramente il loro stato.
- Nessun dato direttamente identificativo deve essere versionato.
- Quando un workflow diventa troppo complesso, preferire un template o una
  guida per l'utente prima di introdurre nuova infrastruttura.

### Primo ponte già disponibile

`data/templates/` contiene modelli per partecipanti e risposte; dalla root:

```text
Rscript R/data/check_responses.R data/collected/responses.csv
```

Il controllo verifica struttura, età, ID item/subtest e stati di
somministrazione. Non calcola punteggi né converte dati raccolti in norme.

---

# 6. Workflow di revisione retroattiva

Questa sezione è fondamentale.

## Quando cambiano gli stimoli

Se la creazione degli item mostra che una scelta precedente non funziona:

```text
item problem
  -> revise item family or subtest spec
  -> bump spec version
  -> regenerate item metadata
  -> rerun item-level simulation
  -> reevaluate start/basal/ceiling
  -> regenerate norms
  -> rerun CFA/reliability/QA
  -> update Shiny/tests/manual
```

Non mantenere artificiosamente la simulazione precedente per conservare compatibilità.

## Classi di modifica

### A. Editoriale
Esempio: wording più chiaro senza alterare difficoltà prevista.

Effetto probabile:

- item bank;
- manuale;
- materiali.

### B. Psicometricamente rilevante
Esempio:

- nuovo distrattore;
- item più difficile;
- cambio scoring 0/1 → 0/1/2;
- cambio numero item.

Effetto:

- spec;
- simulazione;
- norme;
- scoring;
- Shiny;
- test.

### C. Strutturale
Esempio:

- cambio composizione QI totale;
- cambio dominio;
- sostituzione di un subtest;
- nuova regola adattiva.

Effetto:

- rebuild completo;
- decision record obbligatorio;
- revisione Sol indipendente prima del merge.

---

# 7. Strategia di uso dei modelli Codex

> **Nota temporale:** strategia basata sulla famiglia GPT-5.6 disponibile in Codex a settembre 2026. Se il selettore cambia, mantenere la stessa logica per classi di capacità: modello economico per lavoro meccanico, modello bilanciato per implementazione ordinaria, modello di punta per architettura e audit.

## GPT-5.6 Luna

### Usare per

- lint;
- rinomina file;
- formatting;
- generazione boilerplate;
- test fixture semplici;
- controlli schema ripetitivi;
- piccole modifiche locali ben specificate;
- documentazione derivata meccanicamente.

### Non usare come default per

- progettazione item;
- psicometria;
- architettura scoring;
- decisioni CHC;
- revisione di ambiguità.

### Reasoning
`low` o `medium`.

---

## GPT-5.6 Terra — DEFAULT

Terra dovrebbe essere il modello usato per la maggior parte delle task.

### Usare per

- implementazione R;
- refactor locale;
- Shiny;
- parser/spec loader;
- generatori SVG;
- build system;
- test;
- materiali;
- documentazione;
- generazione item dopo che la famiglia di item è già ben specificata;
- issue di difficoltà media.

### Reasoning

- `medium`: task ben definite;
- `high`: scoring, simulation, item generation, refactor con più file.

### Regola pratica
Se il task può essere descritto come una issue GitHub con chiari file e criteri di accettazione, partire con Terra.

---

## GPT-5.6 Sol — ESCALATION / DESIGN / REVIEW

### Usare per

- architettura iniziale della spec;
- audit globale di coerenza;
- progettazione delle famiglie di item;
- definizione di difficoltà/start/stop;
- rifattorizzazione item-level simulation;
- decisioni psicometriche;
- scoring di casi limite;
- integrazione complessa tra spec, simulazione, scoring e UI;
- review indipendente prima di freeze/release;
- debug di problemi che Terra non risolve in modo convincente.

### Reasoning

- `high` di default;
- `xhigh` solo per:
  - revisioni cross-repository;
  - freeze v0;
  - bug difficili con più cause plausibili;
  - decisioni strutturali difficili da invertire.

### Evitare
Non usare Sol per modifiche meccaniche o ripetitive solo perché è più capace.

---

# 8. Strategia multi-agent

## Pattern consigliato

### 1 Lead agent
**Sol/high**

Responsabilità:

- definire interfacce;
- decidere ordine dei lavori;
- revisionare conflitti;
- evitare divergenza della source of truth.

### Worker agents
**Terra/medium-high**

Uno per workstream separato:

- spec tooling;
- item bank;
- visual stimuli;
- simulation;
- scoring;
- Shiny;
- documentation/materials.

### QA agent indipendente
**Sol/high**

Non dovrebbe ricevere soltanto il riassunto del worker: deve leggere diff, test e source of truth.

### Cheap verification
**Luna/medium**

Per lint, schema checks, file consistency e task meccaniche.

---

## Cosa parallelizzare

Parallelizzare solo dopo aver congelato le interfacce necessarie.

Buoni candidati:

- stimoli di subtest diversi;
- documentazione e test;
- asset SVG separati;
- record forms e response sheets;
- QA su subtest distinti.

## Cosa NON parallelizzare prematuramente

- nuova spec e codice che dipende dalla spec;
- nuove regole scoring e norme;
- composizione indici e Shiny;
- item difficulty e start/stop prima che l'item bank sia sufficientemente definito.

---

# 9. Regole per assegnare task a Codex

Ogni task dovrebbe essere formulata come una issue GitHub.

## Template

```markdown
## Goal
[una modifica precisa]

## Context
- source of truth: ...
- relevant files: ...
- dependencies: ...

## Requirements
- ...
- ...

## Non-goals
- ...

## Acceptance criteria
- [ ] ...
- [ ] ...

## Required tests
- ...

## Important constraints
- simulations/norms are derived and may be regenerated
- do not hard-code values already present in spec
- if a spec conflict is discovered, fix the source of truth first
```

## Prompt operativo raccomandato

```text
Implement the task described below as a coherent repository change.
Read AGENTS.md and ROADMAP_V0.md first.
Treat spec/ as the source of truth whenever it exists.
Do not preserve existing simulated norms or hard-coded behavior if they conflict with the current battery specification.
If you discover a cross-cutting inconsistency, fix it at the source and update all derived artifacts that are in scope.
Run the relevant tests and report what changed, what was regenerated, and any remaining uncertainties.
Prefer the smallest coherent change that leaves the repository internally consistent.
```

---

# 10. Backlog suggerito: ordine concreto delle prime issue

## Epic A — Repository foundation

### A1
Create README + AGENTS + roadmap references.

**Model:** Terra/medium

### A2
Create structured `spec/` schema.

**Model:** Sol/high

### A3
Migrate 15 subtests into structured spec.

**Model:** Terra/high, then Sol review

### A4
Create spec validation tests.

**Model:** Terra/medium

---

## Epic B — Item system

### B1
Define item schema.

**Model:** Sol/high

### B2
Create item-bank loader/validator.

**Model:** Terra/high

### B3-B17
One issue per subtest: design + complete item bank.

**Generation:** Terra/high

**Review:** Sol/high

Do not assign all 15 to one agent in one task.

---

## Epic C — Visual stimulus generation

### C1
Create shared SVG/layout utilities.

**Model:** Terra/high

### C2+
One generator per visual subtest.

**Model:** Terra/high

### C-review
Cross-subtest visual QA.

**Model:** Sol/high

---

## Epic D — Administration logic

### D1
Implement generic adaptive administration engine.

**Model:** Sol/high design + Terra/high implementation

### D2
Implement subtest-specific overrides.

**Model:** Terra/high

### D3
Create routing test cases.

**Model:** Terra/medium

---

## Epic E — Simulation refactor

### E1
Design item-level simulation architecture.

**Model:** Sol/xhigh

### E2
Implement dichotomous/polytomous generators.

**Model:** Terra/high

### E3
Implement span/timed/memory task generators.

**Model:** Terra/high

### E4
Apply administration routing to simulated responses.

**Model:** Sol/high or Terra/high with Sol review

### E5
Rebuild norms and QA report.

**Model:** Terra/high

---

## Epic F — Materials

### F1
Examiner manual.

**Model:** Terra/high; Sol review

### F2
Stimulus books.

**Model:** Terra/high

### F3
Record forms.

**Model:** Terra/high

### F4
Timed-task response sheets + fillers.

**Model:** Terra/medium-high

---

## Epic G — Scoring + Shiny

### G1
Response-level scoring schema.

**Model:** Sol/high

### G2
Implement scorer.

**Model:** Terra/high

### G3
Import record form in Shiny.

**Model:** Terra/high

### G4
Version-aware reporting and warnings.

**Model:** Terra/high

---

## Epic H — Release QA

### H1
Automated consistency suite.

**Model:** Terra/high

### H2
End-to-end synthetic administrations.

**Model:** Terra/high

### H3
Independent v0 audit.

**Model:** Sol/xhigh

### H4
Fix audit blockers.

**Model:** Terra or Sol according to issue

### H5
Tag `v0.1.0`.

---

# 11. Definition of Done per PR

Una PR è completa solo se:

- modifica la fonte di verità appropriata;
- non introduce duplicazioni non necessarie;
- aggiorna i derivati necessari;
- aggiunge/aggiorna test;
- i test passano;
- documenta le assunzioni;
- non presenta norme simulate come dati empirici;
- non hard-coda valori che dovrebbero provenire dalla spec;
- se altera comportamento psicometrico, indica esplicitamente quali output sono stati rigenerati;
- non lascia il repository in uno stato misto tra vecchia e nuova architettura senza documentarlo.

---

# 12. Criteri di priorità

Se il tempo è limitato, seguire questo ordine:

1. **source of truth strutturata**;
2. **item bank completo**;
3. **stimoli reali**;
4. **manuale + record forms**;
5. **response-level scoring**;
6. **item-level simulation + norme rigenerate**;
7. **Shiny integrata**;
8. **QA e release**.

Non investire molto tempo nel perfezionamento cosmetico della Shiny o nel fit delle simulazioni prima che item e procedure siano sufficientemente stabili.

---

# 13. Percorso oltre la v0

Una volta usata in aula, la BII può diventare un progetto didattico incrementale.

Gli studenti possono contribuire a:

- revisione item;
- analisi degli errori;
- rating di difficoltà;
- item analysis su piccoli pilot;
- confronto difficoltà prevista vs osservata;
- reliability;
- struttura fattoriale;
- measurement invariance;
- fairness;
- alternative scoring rules;
- nuovi subtest;
- forme parallele;
- standardizzazione empirica futura.

La transizione verso una batteria reale dovrebbe avvenire solo quando dati empirici, governance, validazione, aspetti etici e finalità d'uso lo giustificano.

---

# 14. Regola finale per tutti gli agenti

> **La coerenza della batteria viene prima della conservazione degli artefatti già prodotti.**
>
> Gli stimoli reali possono obbligare a rivedere teoria operativa, parametri, start/stop, scoring e simulazioni. Questo è sviluppo iterativo corretto, non regressione.
>
> Prima del freeze v0, nessun parametro simulato deve essere considerato sacro.
