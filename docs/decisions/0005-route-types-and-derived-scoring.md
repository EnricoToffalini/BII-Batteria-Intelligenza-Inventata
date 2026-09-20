# 0005 — Registro dei route type, punteggio derivato da componenti, subtest a livelli

- Stato: accettata
- Data: 2026-09-12
- Si appoggia a: [0003](0003-generic-administration-engine.md), [0004](0004-item-development-strategy.md)

## Contesto

Dopo la 0004 il collo di bottiglia non erano più gli item ma i **route type**:
cinque subtest con stimoli producibili (SM, CR, CL, SS, PG) erano bloccati perché
il motore interpretava solo `adaptive_items`. Il motore aveva anche
un'assunzione non dichiarata: che ogni subtest fosse una progressione di
difficoltà crescente per item.

## Decisione

### 1. `route_subtest()` diventa un dispatcher

Le regole di somministrazione sono interpretate da **handler registrati** in
`BII_ROUTE_HANDLERS`. Aggiungere un route type significa scrivere un handler e
registrarlo, non modificare `route_subtest()`.

| Route type | Handler | Subtest |
|---|---|---|
| `adaptive_items` | `bii_route_adaptive_items` | SP, RS, RR, CS, QS, MO, RP, MP |
| `delayed_retrieval` | `bii_route_delayed_retrieval` | CR, DM |
| `adaptive_levels` | `bii_route_levels` | PG |
| `adaptive_levels_by_microblock` | `bii_route_levels` | SM |
| `fixed_time` | `bii_route_fixed_time` | CL, SS |

Un route type non registrato produce un errore che elenca quelli disponibili.

Per `fixed_time` non esiste un vettore di risposte item-level: l'handler verifica
l'età e descrive una procedura che termina per tempo. Il punteggio passa da
`score_fixed_time_record()`, che riceve una singola osservazione aggregata con le
componenti dichiarate nella spec. In questo modo CL e SS non richiedono cento
righe fittizie prima che esistano i loro item bank.

### 2. Il routing a livelli riusa la logica di quello per item

Nei subtest a livelli il livello prende il posto della finestra iniziale, ma la
struttura è identica: trigger di inversione separato dal criterio di basale,
convenzione generosa nella zona intermedia, ceiling valutato solo in avanti.

La ragione è didattica prima che implementativa: **l'esaminatore impara una sola
procedura**, non due. Un allievo che ha capito SP capisce PG leggendo solo i
numeri diversi. Con `adaptive_levels_by_microblock` la stessa procedura si
applica a ciascun microblocco in modo indipendente.

Questo ha chiuso una lacuna che la spec lasciava aperta: con due prove per
livello, `initial_consecutive_failures: 2` e `consecutive_correct: 2`, il caso
«una corretta e una sbagliata» non attivava né inversione né basale. Ora ricade
nella convenzione v0 già usata da `adaptive_items` — i livelli più bassi
ricevono credito pieno — invece di restare indefinito.

### 3. Punteggio derivato da componenti

CR non registra un punteggio di item: lo deriva da `recall` e `recognition`. La
spec dichiara `scoring.derived_from`, i valori ammessi per ciascuna componente e
la mappa punteggio → condizione in `scoring.rubric`. Il motore conosce i **nomi**
delle condizioni; i **valori** restano nella spec.

Conseguenza sul modulo di registrazione: quando un subtest ha un punteggio
derivato, il generatore **non crea la colonna `item_score`**. Chiederla
inviterebbe a scrivere a mano un numero che lo scorer ignora.

Conseguenza sullo scoring: se il richiamo è fallito e il riconoscimento non è
stato somministrato, lo scorer **rifiuta** di calcolare l'item e nomina quali
completare, invece di assegnare 0. Una componente mancante non è una risposta
sbagliata — è la stessa regola che vale per `external_missing`, applicata dentro
l'item.

### 4. `item_ordering` è ora rispettato dai test

`tests/test_item_bank.R` imponeva difficoltà monotona a **ogni** item bank,
mentre quattro subtest dichiarano `fixed_set`, `fixed_sheet` o `fixed_matrix` e
SM dichiara `increasing_difficulty_within_microblock`. Il controllo ora segue
l'ordinamento dichiarato: monotonia globale, monotonia entro microblocco, oppure
nessun vincolo d'ordine. `difficulty_target` resta obbligatorio per tutti perché
è l'input della simulazione.

## Modifiche psicometriche decise sulla base della simulazione

### CR da 10 a 14 coppie (`raw_max` 20 → 28)

Il report di routing mostrava, sulla fascia 17–22 anni, il **10,9% al punteggio
massimo** e il **35,5% entro due punti dal massimo**: il vertice della
distribuzione era indistinguibile, su un subtest core che entra nel QI totale.

La correzione è per **lunghezza della forma**, non per difficoltà degli item: con
coppie concrete arbitrarie non è credibile sostenere di poter costruire una gamma
ampia di difficoltà, quindi i `difficulty_target` restano in banda stretta e il
soffitto si abbassa perché azzeccarne quattordici è meno probabile che
azzeccarne dieci. Effetto misurato: massimo dal 10,9% al 2,5%, entro due punti
dal 35,5% al 12,7%, pavimento invariato all'1,8% nella fascia 6–10.

Quattordici coppie è anche la lunghezza dei test di paired associates in uso.

### PG: due item di prova aggiunti (`n_practice_items` 0 → 2)

Senza dimostrazione un bambino di sei anni non capisce che deve riprodurre
**l'ordine** e non solo le caselle: la prima prova scored misurerebbe la
comprensione della consegna. Non cambia `raw_max`.

## Difetti preesistenti corretti

**`R/build/rebuild_all.R` non citava i percorsi.** `system2(rscript, path)` senza
`shQuote()` spezza gli argomenti quando il percorso contiene spazi — come in
questo repository. Il rebuild completo non era mai stato eseguibile da qui.

**Griglia di PG senza etichette.** La notazione `A1`–`D4` serve all'esaminatore.
Stampata sulla griglia mostrata alla persona permetterebbe di verbalizzare la
sequenza, e PG duplicherebbe SM invece di completarlo. Aggiunto `cell_notation`
alla spec con l'avvertenza nel manuale.

## Norme simulate rigenerate

Il cambio di `raw_max` di CR ha fatto fallire `tests/test_spec.R`, che confronta
i range della spec con le tabelle di conversione legacy. Rigenerato tutto con
`R/build/rebuild_all.R`; il fit CFA resta plausibile (RMSEA 0.005, CFI 1.000 sul
modello a sei fattori correlati) e le tabelle coprono ora CR 0–28.

> **Attenzione leggendo il diff.** Il rebuild ha inglobato anche la deriva di
> riproducibilità preesistente documentata nel CHANGELOG: gli script legacy non
> fissano `RNGversion()`, quindi tutte le righe del campione simulato cambiano
> comunque. Non tutte le differenze in `norms_BII/` dipendono da CR.

## Alternative scartate

**Un linguaggio dichiarativo in YAML per le derivazioni di punteggio.** Una
tabella di condizioni `when/score` nella spec sarebbe più generale, ma per una
sola regola a tre casi aggiunge un mini-interprete senza guadagno, contro la
regola di AGENTS.md sull'astrazione. I nomi delle condizioni nel motore con i
valori nella spec bastano.

**Unificare l'inversione dei subtest a livelli su «entrambe le prove
sbagliate», senza zona intermedia.** Più semplice da spiegare, ma avrebbe
lasciato senza credito i livelli più bassi di chi ottiene una prova su due,
penalizzandolo più di chi le sbaglia entrambe. Scartata.

**Tenere PG a 24 item come SM per uniformità.** PG con 16 item è già coerente:
8 livelli × 2 prove su una griglia di 16 celle. Uniformare avrebbe cambiato un
subtest coerente per farlo somigliare a uno che non lo è ancora.

## Estensione: scoring aggregato delle prove timed

Le formule aggregate supportate sono registrate esplicitamente nel motore e non
sono eseguite con `eval(parse())`: per ora `max(0, correct - errors)` e
`max(0, hits - false_alarms)`. Nomi, range delle componenti e vincoli fra
componenti restano nella spec. CL dichiara così che corrette, errori e omissioni
non possono superare insieme il numero di item; SS non riceve un vincolo analogo
finché la ripartizione target/distrattori non sarà dichiarata.

Il tempo effettivo è metadato procedurale e non altera il raw score. CL ha un
limite fisso di due minuti; SS dichiara soltanto una durata pianificata di 2–3
minuti, quindi uno scostamento può essere segnalato ma non trattato come
violazione di un limite inesistente.
