# PG — piano del banco item

PG misura la memoria di lavoro visuo-spaziale: mantenere e riprodurre una
sequenza di posizioni su una griglia 4×4. È `completion`, completa qML insieme a
SM e non entra nel QI totale.

## Struttura a livelli, non a item

PG è il primo subtest della BII con `route_type: adaptive_levels`. Non esiste un
«item 7»: esistono **otto livelli di lunghezza** (2–9 posizioni) con **due prove
ciascuno**. Quello che cambia fra le persone è fino a quale lunghezza arrivano.

`n_scored_items: 16` è quindi 8 livelli × 2 prove, e non una progressione di
sedici difficoltà distinte. Il `difficulty_target` dipende solo dalla lunghezza:
le due prove dello stesso livello hanno lo stesso valore.

## Perché la griglia mostrata non ha etichette

La notazione `A1`–`D4` serve all'esaminatore. Se le etichette fossero stampate
sulla griglia mostrata alla persona, diventerebbe possibile **verbalizzare** la
sequenza («D1, A1…») e ricordarla come stringa di nomi. Sarebbe una prova
verbale mascherata da prova spaziale, e PG duplicherebbe SM invece di
completarlo.

## Le sequenze sono estratte a caso ma filtrate

Una sequenza casuale può disegnare una linea, una L o un quadrato, e allora si
ricorda **come figura** e non come serie di posizioni: la lunghezza nominale non
corrisponde più al carico di memoria. I filtri applicati:

| Vincolo | Che cosa esclude |
|---|---|
| nessuna cella ripetuta di seguito | pause che riducono la lunghezza effettiva |
| nessuna cella usata più di due volte | sequenze che si riducono a due o tre posizioni |
| nessuna terna consecutiva allineata | segmenti di retta riconoscibili come forma |
| al più metà dei passaggi fra celle contigue | percorsi continui, ricordabili come tracciato |

I vincoli sono verificati da `tests/test_pg_scoring.R` **sul CSV**, non
sull'output del generatore: una sequenza sostituita a mano resta sotto controllo.
`R/build/build_pg_items.R` con seed fisso documenta come sono nate le prime.

## Due item di prova aggiunti alla spec

La spec prevedeva `n_practice_items: 0`. Senza una dimostrazione un bambino di
sei anni non capisce che deve riprodurre **l'ordine** e non solo le caselle: la
prima prova scored misurerebbe la comprensione della consegna. Aggiunti due item
di prova alla lunghezza 2, con correzione mostrata. Non entrano nel punteggio e
non cambiano `raw_max`.

## Punti aperti

- **Il livello 9 potrebbe essere peso morto.** Nove posizioni su sedici celle è
  al limite superiore di quanto si osserva nei compiti di span spaziale. Se nel
  pilot nessuno supera la lunghezza 7, i due livelli più alti non discriminano e
  la forma va accorciata.
- **Il passo fra i livelli è una posizione**, che è il massimo di risoluzione
  possibile ma rende la scala grezza grossolana: sedici punti per otto livelli.
  Un punteggio alternativo (lunghezza massima raggiunta) andrebbe confrontato
  con il totale delle prove corrette nel pilot.
- **La velocità di presentazione non è strumentata.** «Circa una cella al
  secondo» dipende dall'esaminatore, e la velocità influisce sul carico. È il
  limite procedurale principale di PG.
- Il valore di `difficulty_target` per livello (-2.5 a +2.4, passo 0.7) è una
  scala progettuale scelta per coprire il range, non una stima.
