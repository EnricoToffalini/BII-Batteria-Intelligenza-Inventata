# PG — istruzioni e chiavi

Sedici item scored organizzati in **otto livelli di lunghezza** (da 2 a 9
posizioni), **due prove per livello**, più due item di prova.

PG non si somministra per item come SP o RS: si somministra **per livelli**. Si
sale di livello finché non si sbagliano entrambe le prove di uno stesso livello.

## Materiale: la griglia

Serve una griglia 4×4 stampata, con le celle **vuote e tutte identiche**. La
notazione colonna-riga serve solo all'esaminatore e **non va stampata sulla
griglia mostrata alla persona**: vedere le etichette permetterebbe di
verbalizzare la sequenza («D1, A1…») e trasformerebbe una prova visuo-spaziale
in una prova verbale.

Riferimento per l'esaminatore:

```
      A     B     C     D
   +-----+-----+-----+-----+
 1 |  A1 |  B1 |  C1 |  D1 |
   +-----+-----+-----+-----+
 2 |  A2 |  B2 |  C2 |  D2 |
   +-----+-----+-----+-----+
 3 |  A3 |  B3 |  C3 |  D3 |
   +-----+-----+-----+-----+
 4 |  A4 |  B4 |  C4 |  D4 |
   +-----+-----+-----+-----+
```

## Istruzione

> Guarda questa griglia. Io tocco alcune caselle, una dopo l'altra. Quando ho
> finito, tocca tu le stesse caselle nello stesso ordine.

Toccare una cella circa **ogni secondo**, con il dito ben visibile e senza
indugiare su nessuna cella. Non nominare le celle ad alta voce, non contare, non
seguire con il dito il percorso fra una cella e l'altra.

Dopo l'ultima cella, fare un cenno o dire «Adesso tu». Non ripetere una
sequenza: se la persona chiede di rivederla, si risponde «Prova come ti
ricordi».

## Item di prova

Due prove alla lunghezza 2. Se la persona sbaglia, **si mostra la risposta
corretta** e si rifà la prova una volta. Gli item di prova non entrano nel
punteggio e si somministrano a tutti, anche a chi parte da un livello più alto.

| Item | Sequenza |
|---|---|
| PG-PR-01 | D1 → A1 |
| PG-PR-02 | D3 → B2 |

## Punteggio

Ogni prova vale **1 punto se la sequenza è riprodotta esattamente**, nello
stesso ordine e senza aggiunte. Vale 0 per qualunque omissione, aggiunta,
sostituzione o inversione, anche di una sola posizione.

Non esistono punteggi parziali: una sequenza «quasi giusta» vale 0. Range grezzo
0–16.

Le autocorrezioni si accettano se la persona completa la sequenza corretta prima
di dichiararsi soddisfatta.

## Livelli, punto di partenza e regole

| Età | Livello di partenza |
|---|---|
| 6;0–8;11 | 2 posizioni |
| 9;0–12;11 | 3 posizioni |
| 13;0–21;11 | 4 posizioni |

- si somministrano **entrambe le prove** del livello di partenza;
- **entrambe corrette** → i livelli più bassi ricevono 1 punto ciascuno senza
  essere somministrati, e si sale di livello;
- **entrambe sbagliate** → si scende di un livello alla volta fino a trovare un
  livello con entrambe le prove corrette (il basale); i livelli sotto il basale
  ricevono 1 punto ciascuno;
- **una corretta e una sbagliata** → non si scende: si sale, e i livelli più
  bassi ricevono comunque 1 punto ciascuno. È la stessa convenzione v0 usata
  negli altri subtest quando la finestra iniziale non attiva l'inversione;
- si **interrompe** quando entrambe le prove di un livello sono sbagliate; i
  livelli successivi ricevono 0.

Mentre si scende non si applica la regola di interruzione.

## Chiave rapida

Le sequenze si leggono da sinistra a destra e si toccano in quest'ordine.

| Livello | Item | Sequenza |
|---|---|---|
| 2 | PG-SC-01 | D1 B2 |
| 2 | PG-SC-02 | D2 B4 |
| 3 | PG-SC-03 | A4 B4 C3 |
| 3 | PG-SC-04 | B3 A3 A1 |
| 4 | PG-SC-05 | B1 D2 A1 B2 |
| 4 | PG-SC-06 | B1 A1 B3 D2 |
| 5 | PG-SC-07 | A3 B4 D3 C2 B2 |
| 5 | PG-SC-08 | B4 B1 A2 C1 C3 |
| 6 | PG-SC-09 | D2 A3 D3 C2 D4 A1 |
| 6 | PG-SC-10 | B3 D2 A3 B2 A2 D1 |
| 7 | PG-SC-11 | D1 A2 B3 B4 D2 C4 A3 |
| 7 | PG-SC-12 | C3 B2 C4 A3 A1 D1 A3 |
| 8 | PG-SC-13 | B4 C3 B2 C1 D4 A4 A2 B4 |
| 8 | PG-SC-14 | B3 C4 D1 D4 A3 B2 A4 C1 |
| 9 | PG-SC-15 | A2 C1 C3 D2 A1 A4 C4 D3 B3 |
| 9 | PG-SC-16 | C2 B3 C3 A4 D4 A1 C4 D1 C1 |

> La tabella qui sopra è la versione leggibile. La fonte è
> `items/source/PG.csv`: se le due divergono, vale il CSV.

## Vincoli rispettati dalle sequenze

Le sequenze non sono casuali in senso pieno: sono estratte a caso ma **filtrate**
perché non si possano ricordare come figura invece che come serie di posizioni.

- nessuna cella ripetuta di seguito;
- nessuna cella usata più di due volte nella stessa sequenza;
- **nessuna terna consecutiva allineata**, così non si formano segmenti di
  retta riconoscibili;
- **non più della metà dei passaggi fra celle contigue**, così la sequenza non
  diventa un percorso continuo.

`tests/test_pg_scoring.R` verifica questi vincoli **sul CSV**, non sull'output
del generatore: una sequenza sostituita a mano resta quindi sotto controllo.
`R/build/build_pg_items.R` documenta come sono state prodotte le prime.

## Limiti dichiarati

La difficoltà è la lunghezza della sequenza, e questo è l'unico aspetto della
progressione che si può difendere senza dati. Non è detto che la lunghezza 9 sia
raggiungibile: se nel pilot nessuno supera la lunghezza 7, i due livelli più
alti sono peso morto e la forma va accorciata o il punteggio ridistribuito.

PG è `completion`: completa qML insieme a SM ma non entra nel QI totale.
