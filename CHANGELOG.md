# Changelog

Il progetto usa versionamento semantico pre-1.0. I cambiamenti a item,
scoring, routing, range grezzi, composizione di indici o simulazione sono
psicometricamente rilevanti e devono indicare gli artefatti rigenerati.

## Unreleased

### Added

- Fondazione del repository per `v0.0.0-dev`: README, convenzioni, decision
  record iniziale, comando unico di test e comando unico di rebuild.
- `spec/` come fonte di verità per 15 subtest, ruoli, range grezzi, routing,
  indici, quozienti, filler e ritenzione differita; loader e validator R.
- Prima forma completa `draft` di SP: 18 item originali, rubriche, modulo di
  registrazione, istruzioni, routing/scoring e simulazione item-level con seed.
- Registro di provenienza e istruzioni semplici per sostituire item e compilare
  i moduli senza modificare il codice.
- Motore generico di somministrazione e scoring (`R/scoring/administer.R`):
  interpreta start point, inversione, basale e interruzione leggendoli dalla
  spec, per qualunque subtest con `route_type: adaptive_items`. Copre i trigger
  `total_score_lt`/`correct_lt`, i basali `total_score`/`correct` e l'inversione
  sia item per item sia a blocchi. I `route_type` non coperti danno errore
  esplicito invece di un risultato sbagliato.
- Avvisi procedurali nello scoring dei record (`warnings`): segnalano per
  esempio una regola di interruzione non applicata senza rifiutare il calcolo.
- Simulazione item-level generica (`R/simulation/simulate_subtest.R`) con
  modello a soglie ordinate valido sia per subtest dicotomici sia politomici,
  e diagnostiche di routing per fascia d'età.
- `R/build/build_record_forms.R`: i moduli di registrazione diventano artefatti
  derivati dall'item bank. Il generatore riproduce il modulo SP esistente
  senza differenze.
- `R/build/routing_qa.R`: report di QA delle regole adattive in
  `norms_BII/generated/routing_qa.md`, con manifest (seed, hash della spec,
  commit, parametri del modello).
- Forma completa in bozza di RS: 24 item scored, chiave, rationale dei
  distrattori, rubrica per risposte doppie/fuori lista/omesse, modulo di
  registrazione e sezione di manuale.
- Sezione «regole comuni ai subtest adattivi per item» nel manuale.
- `tests/test_consistency.R`: ancore delle rubriche esistenti, moduli di
  registrazione allineati all'item bank, `n_scored_items_current` coerente con
  il CSV, manuale e provenienza presenti per gli item bank completi.
- `tests/test_administration_engine.R` e `tests/test_rs_scoring.R`, inclusi
  confronti fra punteggio calcolato a mano e punteggio software.
- Decision record `0003` sul motore generico e sulle due convenzioni di basale
  che il codice ha dovuto fissare.
- Tre nuovi subtest con forma completa in bozza, tutti sul motore generico senza
  nuovo codice di routing:
  - **RR** (core, Gf, 20 item): sequenze di simboli geometrici a scelta
    multipla, cinque famiglie di regole fra serie, trasformazioni, vincoli
    d'ordine, condizionali e induzione;
  - **CS** (supplementare, Gc, 10 item): risposta aperta 0/1/2 su situazioni
    quotidiane, con rubriche item per item;
  - **QS** (supplementare, Gf, 12 item): risposta breve 0/1/2 su ragionamento
    quantitativo applicato, con passaggio intermedio identificabile in ogni item.
- Campo `stimulus_production` in tutte le 15 spec di subtest, con vocabolario in
  `battery.yml` e validazione: dichiara la capacità necessaria a produrre gli
  stimoli (`text_only`, `symbol_text`, `symbol_grid`, `vector_geometry`,
  `manipulative`) e serve a impedire che un subtest visivo venga popolato con
  stimoli finti.
- `symbol_vocabulary` come set chiuso di simboli dichiarato nella spec di RR,
  verificato dai test: un simbolo non dichiarato fa fallire la suite.
- `tests/test_multiple_choice_banks.R`: i controlli di qualità comuni ai banchi a
  scelta multipla valgono ora per tutti, non solo per RS.
- `tests/test_rr_scoring.R`; `tests/test_consistency.R` richiede anche il piano
  di progettazione con i punti aperti dichiarati.
- Decision record `0004` sull'ordine di sviluppo degli item, sul caso RR e sui
  difetti di spec corretti insieme.
- `route_subtest()` è ora un dispatcher su `BII_ROUTE_HANDLERS`: aggiungere un
  route type significa scrivere un handler e registrarlo. Implementati
  `adaptive_items`, `delayed_retrieval`, `adaptive_levels` e
  `adaptive_levels_by_microblock`; manca `fixed_time` (CL, SS).
- Routing a livelli (`bii_route_levels`): livelli di lunghezza con prove
  multiple, basale, inversione e interruzione per livello, e la stessa procedura
  applicata indipendentemente a ciascun microblocco. Riusa deliberatamente la
  logica di `adaptive_items` perché l'esaminatore impari una procedura sola.
- Punteggio di item derivato da componenti osservate: la spec dichiara
  `scoring.derived_from`, i valori ammessi per componente e la mappa punteggio →
  condizione. Il modulo di registrazione omette `item_score` quando il punteggio
  è derivato, e una componente mancante fa **rifiutare** il calcolo di quell'item
  invece di assegnargli zero.
- Due nuovi subtest con forma completa in bozza:
  - **CR** (core, Glr, 14 coppie): apprendimento associativo con recupero
    differito a 15 minuti e riconoscimento a quattro alternative dopo i richiami
    non riusciti; il ritardo effettivo è registrato e verificato;
  - **PG** (completion, Gwm, 16 prove su 8 livelli): memoria di lavoro
    visuo-spaziale su griglia 4×4, con sequenze filtrate perché non si possano
    ricordare come figura.
- `R/build/build_pg_items.R`: generatore con seed fisso delle sequenze di PG. Il
  CSV resta la fonte modificabile; i vincoli sulle sequenze sono verificati sul
  CSV, non sull'output del generatore.
- `tests/test_cr_scoring.R` e `tests/test_pg_scoring.R`, con casi di routing
  calcolati a mano e i vincoli strutturali delle sequenze.
- Decision record `0005` sul registro dei route type, sul punteggio derivato e
  sulle due modifiche psicometriche decise dai numeri della simulazione.
- Nuovo subtest con forma completa in bozza:
  - **SM** (core, Gwm, 36 item): sequenze numeriche a 3 microblocchi
    indipendenti (ripetizione a ritroso, riordino per regola, span aggiornato),
    ciascuno somministrato per livelli come PG ma con basale/ceiling propri.
    Primo subtest a esercitare `adaptive_levels_by_microblock` con un item bank
    reale.
- `R/build/build_sm_items.R`: generatore con seed fisso delle sequenze
  numeriche di SM, con vincoli anti-scorciatoia (nessuna run consecutiva,
  sequenza non già ordinata/invertita, nessuna cifra ripetuta adiacente).
- `tests/test_sm_scoring.R`: verifica la correttezza logica di ogni sequenza
  ricalcolando il target dalla regola dichiarata, ed esercita il routing
  indipendente dei tre microblocchi con casi a mano.
- `tests/test_rubric_key_tables.R`: le tabelle chiave delle rubriche devono
  coincidere con l'item bank. Se una rubrica tiene una tabella che nomina
  almeno un item scored, deve nominarli tutti e ogni riga deve riportare il
  materiale-chiave come sta nel CSV. Nasce da un difetto ricorrente durante
  lo sviluppo: tabelle scritte a mano divergenti dal CSV in CR, PG e SM, ogni
  volta scoperte per caso. Copre CR, PG, RR, RS, SM; SP, CS e QS hanno rubriche
  in prosa e il test lo dichiara invece di fingere di verificarle.
- `tests/test_legacy_spec_sync.R`: la specifica narrativa legacy non deve
  contraddire `spec/`. Confronta i range grezzi dichiarati nei blocchi
  «Parametri di somministrazione» con `raw_max` (12 subtest coperti; CL, SS e
  DM hanno punteggio derivato da componenti e non dichiarano un range
  numerico).
- Decision record `0006` sulla correzione di copertura dei livelli di SM
  (24→36 item), applicata prima della costruzione e confermata dalla
  simulazione (soffitto 0% in tutte le fasce d'età, contro il rischio
  documentato in 0005).

### Fixed

- **CR aveva un soffitto misurato al 10,9%** nella fascia 17–22 anni (35,5%
  entro due punti dal massimo), su un subtest core che entra nel QI totale.
  Portato da 10 a 14 coppie, `raw_max` 20 → 28: massimo al 2,5%, entro due punti
  al 12,7%, pavimento invariato. La correzione è per lunghezza della forma e non
  per difficoltà degli item, perché con coppie concrete arbitrarie una gamma
  ampia di difficoltà non sarebbe credibile. **Norme simulate rigenerate.**
- **PG non aveva item di prova** (`n_practice_items: 0`): senza dimostrazione la
  prima prova scored misurerebbe la comprensione della consegna invece della
  memoria. Aggiunti due item di prova; `raw_max` invariato.
- **SM aveva la stessa lacuna di copertura già misurata su CR**: con 4 livelli
  per microblocco e punto di partenza al livello 4 per i 13-21 anni, chi aveva
  uno span ≥5 saturava il microblocco al primo salto. Trovata leggendo la spec
  prima di costruire l'item bank (non dalla simulazione, come per CR).
  Corretta a 6 livelli per microblocco (24→36 item, `raw_max` 24→36) e
  confermata dalla simulazione: 0% al punteggio massimo in tutte le fasce.
  **Norme simulate rigenerate.**
- **La specifica narrativa legacy contraddiceva la spec su SM e CR**:
  dichiarava ancora `0–24` per SM e `0–20` per CR dopo che gli item bank
  avevano portato i range a `0–36` e `0–28`. Conteneva inoltre il difetto
  originario di SM («3 errori consecutivi allo stesso livello», irrealizzabile
  con 2 prove per livello). Allineati i blocchi «Parametri di somministrazione»
  di entrambi; la divergenza ora fa fallire la suite.
- **SM non aveva item di prova** (`n_practice_items: 0`), e con tre compiti
  diversi nei tre microblocchi un solo esempio iniziale non basterebbe.
  Aggiunti tre item di prova, uno per microblocco; `raw_max` invariato.
- **`R/build/rebuild_all.R` non citava i percorsi passati a `system2()`**: con
  spazi nel percorso del repository gli argomenti venivano spezzati e il rebuild
  completo non era eseguibile. Difetto preesistente, emerso solo ora.
- **`tests/test_item_bank.R` imponeva difficoltà monotona a ogni item bank**,
  mentre quattro subtest dichiarano `fixed_set`/`fixed_sheet`/`fixed_matrix` e SM
  dichiara `increasing_difficulty_within_microblock`. Il controllo segue ora
  `item_ordering`; `difficulty_target` resta obbligatorio per tutti perché è
  l'input della simulazione.
- **Lacuna nelle regole dei subtest a livelli**: con due prove per livello, il
  caso «una corretta e una sbagliata» non attivava né inversione né basale e
  restava indefinito. Ora ricade nella convenzione v0 già usata da
  `adaptive_items`.
- **SM e PG dichiaravano una regola di interruzione impossibile**:
  `consecutive_errors: 3` «sullo stesso livello» senza dichiarare quante prove
  contenga un livello. Con due prove la condizione non è mai soddisfacibile e la
  somministrazione non si fermerebbe. Aggiunto `trials_per_level: 2` e portato il
  criterio a 2. Il validator rifiuta ora qualunque regola «sullo stesso livello»
  che richieda più prove di quante il livello ne contenga. Nessuna norma
  rigenerata: il simulatore legacy è aggregate-score e non implementa routing.
- La guida di lettura del report di routing copre anche il bias **positivo**: con
  finestre di basale di due item il credito pieno inferito regala qualche punto
  (CS +0.37, QS +0.65 su scala 0–20 e 0–24).

### Changed

- La Shiny e gli script legacy di fit/indici leggono ora dalla spec range e
  composizioni applicabili.
- Il range formalizzato è 6;0–21;11; PG usa una griglia 4×4.
- SP ha ora una progressione progettuale completa e rubriche item-specifiche
  con esempi da 2, 1 e 0 punti; non è una calibrazione empirica.
- Aggiunto un prototipo RS di sei item scored con quattro alternative, chiave
  univoca e razionale dei distrattori.
- RS è passato da sei a ventiquattro item scored. I sei ID esistenti sono
  conservati ma riposizionati nella forma, e i `difficulty_target` sono stati
  ridistribuiti su tutta la scala progettuale (-2.4 … +2.2, passo 0.2): sono
  ipotesi di progetto, non una ricalibrazione. Le famiglie sono state
  normalizzate e non si ripetono in posizioni adiacenti.
- `R/scoring/SP.R` non contiene più regole proprie: è un wrapper sul motore
  generico. Il comportamento di routing e scoring di SP è invariato, verificato
  dai test esistenti.
- `R/build/rebuild_all.R` esegue prima i derivati dalla spec e dall'item bank,
  poi la pipeline legacy su punteggi aggregati.
- **RR** non è più `mixed_verbal_visual` con 4–6 alternative: è `symbol_text`
  con 4 alternative fisse. Il costrutto non cambia — serie, trasformazioni,
  vincoli, condizionali e induzione sono forme classiche di ragionamento fluido —
  mentre la contaminazione lessicale diminuisce e gli stimoli diventano testo
  versionabile. MR resta il subtest Gf figurale e non è stato toccato.
- **QS** non promette più un «simple visual support» mai definito:
  `stimulus_mode` è `verbal_with_scratch_paper`, con
  `scratch_paper_allowed: true` e `calculator_allowed: false` espliciti nella
  spec. Il foglio è ammesso di proposito, per non misurare la memoria di lavoro
  dentro un subtest di ragionamento quantitativo.
- AGENTS.md: nuove sezioni su capacità di produzione degli stimoli, vocabolari
  chiusi di simboli, disciplina delle rubriche aperte e procedura completa per
  aggiungere un subtest senza scrivere codice di routing.

### Known legacy limitations

- **Le norme in `norms_BII/` sono state rigenerate** in questo ciclo, perché il
  cambio di `raw_max` di CR rendeva incoerenti le tabelle di conversione. Il diff
  è però molto più ampio di quanto CR giustifichi: ha inglobato la deriva di
  riproducibilità descritta al punto seguente. Non tutte le differenze in
  `norms_BII/` dipendono da CR.
- **Le norme legacy versionate non sono riproducibili dagli script versionati.**
  `R/0.Data generation.R` usa `set.seed(0)` ed è deterministico — due esecuzioni
  consecutive danno output identico — ma rieseguirlo produce un
  `norms_BII/standardization_sample_raw.csv` diverso da quello committato, in
  tutte le 1600 righe. La differenza **non** dipende dalle modifiche alla spec di
  questo lavoro: si presenta anche ripristinando la spec committata. La causa
  probabile è una versione di R o di pacchetto diversa da quella con cui il file
  fu generato (R 4.5.1 in questo ambiente); il generatore non fissa
  `RNGversion()` né registra un manifest di build. Viola il criterio di
  accettazione della fase 6 della roadmap. Il file committato è stato lasciato
  invariato: la correzione va fatta quando la pipeline passerà a item-level,
  fissando `RNGversion()` e scrivendo un manifest come fa già
  `R/build/routing_qa.R`.

- Il simulatore legacy resta aggregate-score e contiene parametri transitori;
  non implementa ancora item bank o routing.
- Le norme legacy e alcuni path Shiny contengono `OFFICIAL`; saranno sostituiti
  al primo rebuild item-level derivato dalla spec.
