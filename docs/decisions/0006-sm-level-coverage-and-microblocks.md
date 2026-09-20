# 0006 — SM: copertura dei livelli, tre microblocchi indipendenti, vocabolario numerico

- Stato: accettata
- Data: 2026-09-13
- Si appoggia a: [0004](0004-item-development-strategy.md), [0005](0005-route-types-and-derived-scoring.md)

## Contesto

SM era l'unico subtest `text_only` non ancora costruito, non per mancanza del
motore — `adaptive_levels_by_microblock` era già registrato e condivideva il
codice con `adaptive_levels` (0005) — ma perché la sua spec conteneva un
difetto di copertura documentato in 0005 stesso: con 24 item su 3 microblocchi
restavano 4 livelli per microblocco (2 prove ciascuno), e i punti di partenza
arrivavano fino al livello 4. Un diciassettenne partiva quindi dal livello 4 e,
superandolo insieme al 5° — l'ultimo disponibile — saturava il microblocco al
primo salto: chiunque avesse uno span ≥5 avrebbe ottenuto il punteggio pieno.

## Decisione

### 1. Sei livelli per microblocco, non quattro (36 item, non 24)

`n_scored_items` passa da 24 a 36, `raw_max` da 24 a 36. I livelli usati sono
2–7 cifre per ciascuno dei tre microblocchi, con due prove ciascuno. Chi parte
dal livello 4 ha ora tre livelli di margine (5, 6, 7) prima del ceiling, non
zero.

**Confermato per simulazione**, non solo per argomento a priori:
`R/build/routing_qa.R` su 4000 casi simulati per fascia d'età mostra **0% al
punteggio massimo** in tutte le tre fasce (era il rischio esplicito con la
struttura a 4 livelli). Il pavimento resta anch'esso allo 0%.

Questa è la stessa classe di correzione applicata a CR in 0005 — una lunghezza
di forma insufficiente rispetto ai punti di partenza previsti — trovata questa
volta leggendo la spec prima di costruire l'item bank, invece che scoprendola
dopo dalla simulazione.

### 2. Tre item di prova, uno per microblocco

La spec dichiarava `n_practice_items: 0`. Ogni microblocco introduce
un'istruzione diversa (invertire, riordinare, aggiornare): un esempio unico
all'inizio del subtest non basterebbe a spiegare il secondo o il terzo compito
dopo che la persona ha appena imparato il primo. `n_practice_items` passa a 3,
uno per microblocco, somministrato subito prima delle sue prove scored. Non
cambia `raw_max`.

### 3. Vocabolario numerico 1–9, senza lo zero

Il materiale è condiviso dai tre microblocchi (solo cifre, nessuna lettera):
isola la manipolazione richiesta dal contenuto, così un profilo con punteggi
diseguali fra microblocchi è interpretabile come differenza di processo. Lo
zero è escluso per evitare l'ambiguità fonetica con «oh» nella lettura ad alta
voce.

Con solo nove cifre disponibili, `running_span` ai livelli alti (dove la lista
presentata supera le nove unità) ammette la ripetizione — mai adiacente — al
posto dell'unicità totale usata dagli altri due microblocchi.

### 4. Il generatore ha imposto un vincolo che la spec non prevedeva

Costruendo `rule_based_reordering`, il vincolo «la sequenza presentata non deve
essere l'esatto opposto dell'ordinamento richiesto» (per non coincidere con
`backward_repetition`) è risultato **matematicamente irrealizzabile al
livello 2**: con due cifre distinte l'unico ordine diverso da quello crescente
è proprio il suo opposto. Il generatore applica quel vincolo solo dal livello 3
in su, e la rubrica lo dichiara esplicitamente invece di nasconderlo.

### 5. Ogni microblocco punta a una propria sezione di rubrica

I 36 item non condividono un'unica ancora `#chiave-rapida` come gli altri
subtest: ciascuno punta alla sezione del proprio microblocco
(`#1-ripetizione-a-ritroso`, `#2-riordino-per-regola`, `#3-span-aggiornato`).
Un esaminatore che deve applicare l'istruzione di un microblocco specifico non
deve scorrere le istruzioni degli altri due per trovarla.

## Assunzione dichiarata e non verificata

`difficulty_target` usa la stessa scala progettuale (-3.0 a +3.0, sei passi)
per tutti e tre i microblocchi allo stesso livello nominale. Non è garantito
che il livello 5 di riordino sia altrettanto difficile del livello 5 di span
aggiornato — la letteratura sull'updating suggerisce che `running_span` sia
intrinsecamente più oneroso a parità di lunghezza. Registrato come punto aperto
in `items/design/SM.md`, da verificare confrontando le proporzioni di risposta
corretta allo stesso livello nominale nel pilot.

## Conseguenze

- SM è core e completa qML insieme a PG. Il QI totale passa da 4 a 5 componenti
  pronte su 9 (SP, RS, RR, CR, SM); mancano ancora MO, RP (figurali) e CL.
- Il cambio di `raw_max` ha richiesto la rigenerazione delle tabelle legacy
  (`R/build/rebuild_all.R`), con lo stesso avvertimento già registrato per CR:
  il diff in `norms_BII/` include anche la deriva di riproducibilità
  preesistente, non solo l'effetto di SM.
- `adaptive_levels_by_microblock` è ora esercitato da un subtest reale, non
  solo registrato nel dispatcher: il codice condiviso con PG (`adaptive_levels`)
  ha retto senza modifiche.

## Alternative scartate

**Punti di partenza diversi per microblocco.** Avrebbe risolto la sovrapposizione
al livello 2 fra `backward_repetition` e `rule_based_reordering` (spesso la
stessa risposta per motivi combinatori), ma il motore attuale accetta un solo
`sequence_length` di partenza condiviso da tutti i microblocchi di un subtest.
Cambiarlo ora avrebbe touched il motore per un guadagno marginale; registrato
come punto aperto invece di forzare la modifica.

**Scale di difficoltà separate per microblocco.** Più corretta in teoria, ma
senza dati che indichino quanto separarle sarebbe una calibrazione immaginaria
mascherata da precisione. Meglio dichiarare l'assunzione di scala comune come
aperta e verificarla nel pilot.
