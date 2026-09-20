# SM — piano del banco item

SM misura mantenimento, manipolazione e updating di sequenze in memoria di
lavoro. È **core**, contribuisce al QI totale, e con PG forma qML.

## La correzione che ha preceduto la costruzione

La spec originaria dichiarava 24 item scored su tre microblocchi: 8 item per
microblocco, cioè **4 livelli** (2 prove ciascuno) con punti di partenza fino al
livello 4 per i 13-21 anni. Un diciassettenne partiva quindi dal livello 4 e,
superandolo insieme al 5° (l'ultimo disponibile), *saturava il microblocco al
primo salto*: chiunque avesse uno span ≥5 avrebbe ottenuto il punteggio pieno,
con un effetto di soffitto su tutta la fascia più anziana.

La forma è stata portata a **36 item**: sei livelli (2–7 cifre) per microblocco,
sempre due prove ciascuno. Chi parte dal livello 4 ha ora tre livelli di margine
sopra (5, 6, 7) prima di incontrare il ceiling, non zero. `raw_max` passa da 24
a 36. È l'unica correzione psicometrica applicata prima della costruzione, non
dopo: il difetto era visibile leggendo la spec, senza bisogno di simulare nulla.

**Confermato dopo la costruzione.** Il report di routing
(`R/build/routing_qa.R`, 4000 casi simulati per fascia d'età) mostra **0% al
punteggio massimo** in tutte le tre fasce, contro il rischio esplicito di
saturazione della struttura a 4 livelli. Il pavimento resta anch'esso allo 0%.
Vedi decision record 0006.

## Tre microblocchi, tre operazioni sulla sequenza

| Microblocco | Operazione richiesta | Esempio (livello 2) |
|---|---|---|
| `backward_repetition` | invertire l'ordine | «6 9» → «9 6» |
| `rule_based_reordering` | riordinare per regola esterna (crescente) | «5 1» → «1 5» |
| `running_span` | aggiornare continuamente, scartando le cifre più vecchie | lista di 5, richiamare le ultime 2 |

Il materiale (cifre 1–9) è lo stesso nei tre microblocchi: quello che cambia è
l'operazione da compiere sulla sequenza mantenuta in memoria. È una scelta
deliberata: isola la manipolazione dal contenuto, così un profilo con punteggi
diseguali fra microblocchi è interpretabile come differenza di processo, non di
materiale.

Ogni microblocco si somministra **come un piccolo subtest a sé**: punto di
partenza, basale, ceiling e interruzione sono indipendenti per microblocco.
Questo riusa deliberatamente la stessa procedura di PG (route_type
`adaptive_levels_by_microblock`, che applica l'handler di `adaptive_levels`
a ciascun gruppo separatamente) — vedi decision record 0005.

## Perché tre item di prova e non uno

Ogni microblocco introduce un compito diverso con un'istruzione diversa. Un
solo esempio all'inizio del subtest non basterebbe a spiegare «riordina per
grandezza» dopo che la persona ha appena imparato «ripeti al contrario». Per
questo `n_practice_items` è stato portato da 0 a 3, uno per microblocco,
somministrato subito prima delle sue prove scored.

## Vincoli sulle sequenze generate

Le sequenze sono estratte a caso da `R/build/build_sm_items.R` (seed fisso) ma
**filtrate**, per lo stesso motivo delle sequenze di PG: una sequenza che si
risolve con una scorciatoia non misura più il carico dichiarato.

| Vincolo | Si applica a | Perché |
|---|---|---|
| nessuna run di 3+ interi consecutivi adiacenti (ascendente o discendente) | tutti | un "4 5 6" si ricorda come blocco, non come tre cifre |
| sequenza presentata non monotona | `backward_repetition`, `running_span` (sul target) | altrimenti «conta all'indietro» risolve l'item senza richiamo |
| sequenza presentata non già ordinata crescente | `rule_based_reordering` | altrimenti non c'è manipolazione da fare |
| sequenza presentata non l'esatto opposto dell'ordine richiesto, dal livello 3 | `rule_based_reordering` | altrimenti l'item coincide con `backward_repetition` |
| nessuna cifra ripetuta adiacente | tutti | evita ambiguità di lettura |

Il penultimo vincolo non è realizzabile al livello 2: con due cifre distinte
l'unico ordine diverso da quello crescente è il suo esatto opposto, quindi a
quel livello resta solo il vincolo "non già ordinato". È dichiarato nella
rubrica, non nascosto.

`running_span` ammette la ripetizione di cifre (mai adiacente) ai livelli alti,
perché la lista presentata (livello + 3 cifre di buffer) supera le nove cifre
disponibili dal livello 7 in su (7+3=10 > 9).

## Scala di difficoltà comune ai tre microblocchi

`difficulty_target` va da -3.0 a +3.0 in sei passi (0.6 di verso), **la stessa
scala per tutti e tre i microblocchi allo stesso livello**. È un'assunzione
dichiarata, non una stima: non è garantito che il livello 5 di riordino sia
altrettanto difficile del livello 5 di span aggiornato. La letteratura
suggerisce che il compito di updating (`running_span`) sia intrinsecamente più
oneroso a parità di lunghezza nominale rispetto alla semplice inversione; se il
pilot lo confermasse, andrebbero usate scale separate per microblocco.

## Punti aperti

- ~~Il difetto di copertura dei livelli (soffitto nella fascia 13-21)~~ —
  **risolto e confermato per simulazione**, vedi sopra e decision record 0006.
- **La scala comune fra microblocchi è la semplificazione più rischiosa di
  questo subtest.** Va verificata per prima nel pilot, confrontando la
  proporzione di risposte corrette allo stesso livello nominale fra i tre
  compiti.
- **Il livello 7 potrebbe essere irraggiungibile in `running_span`**, dove la
  lista presentata arriva a 10 cifre con ripetizioni: da controllare se
  introduce un pavimento artificiale ai livelli alti invece di misurare
  updating reale.
- **La sovrapposizione al livello 2** fra `backward_repetition` e
  `rule_based_reordering` (spesso la stessa risposta, per motivi combinatori)
  potrebbe rendere il livello 2 di riordino poco informativo: da controllare se
  conviene iniziare quel microblocco specifico dal livello 3, con un punto di
  partenza diverso dagli altri due — cosa che il motore attuale non permette
  ancora (un solo `sequence_length` di partenza per tutti i microblocchi).
- **Velocità di presentazione non strumentata**, come per PG: dipende
  dall'esaminatore e non c'è modo di controllarla nella v0.
- Nessuna curva di apprendimento: ogni sequenza si presenta una sola volta.
