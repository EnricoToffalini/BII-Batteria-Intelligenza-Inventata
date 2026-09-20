# QS — piano del banco item

QS misura il ragionamento quantitativo applicato: impostare un problema, usare
un rapporto, stimare un ordine di grandezza, riconoscere quando una relazione è
inversa. È **supplementare** e approfondisce qIF senza entrare nel QI totale.

## La decisione che definisce il subtest

Il foglio per i calcoli è ammesso. Senza foglio un problema a due passaggi
misura anche la capacità di tenere a mente il risultato intermedio, cioè memoria
di lavoro — che nella BII ha già due subtest propri (SM, PG). Ammettere il
foglio isola meglio ciò che QS deve misurare: come si imposta il problema.

La scelta è dichiarata nella spec (`scratch_paper_allowed: true`,
`calculator_allowed: false`) e non va cambiata senza rivedere la difficoltà
progettuale di tutti gli item.

## Perché QS resta supplementare

Ogni item richiede un'operazione aritmetica elementare, quindi QS dipende dalla
scolarizzazione più di quanto sia desiderabile per un indicatore fluido. Per
questo contribuisce a qIF ma **non** al QI totale, dove la componente Gf è
affidata a MR (figurale) e RR (simbolico).

## Famiglie usate

| Famiglia | Che cosa chiede | Item |
|---|---|---|
| `arithmetic_two_step` | due operazioni elementari in sequenza | 1, 3 |
| `partition_two_step` | dividere e poi modificare il risultato | 2 |
| `equalization` | pareggiare due quantità | 4 |
| `estimation` | ordine di grandezza senza conto esatto | 5, 10 |
| `rate` | ragionare su un rapporto tempo/quantità | 6, 11 |
| `proportional` | applicare un rapporto a una quantità nuova | 7 |
| `fraction_of_quantity` | prendere una frazione e usarla | 8 |
| `inverse_proportion` | riconoscere che più risorse significa meno tempo | 9, 12 |

Otto famiglie per dodici item è una frammentazione voluta: QS campiona più
operazioni quantitative invece di approfondirne una, perché con dodici item
un'unica famiglia misurerebbe la padronanza di quella singola operazione.

## Progressione progettuale

| Posizioni | Contenuto prevalente | Difficoltà attesa |
|---|---|---|
| 1–4 | due operazioni elementari, numeri piccoli | facile |
| 5–8 | rapporti, stime, frazioni di una quantità | media |
| 9–12 | proporzionalità inversa e combinazione di velocità | medio-alta |

`difficulty_target` va da -2.2 a +2.2 con passo costante di 0.4.

## Il punteggio 1 è la parte progettata con più cura

Ogni item ha un **passaggio intermedio identificabile**, e in quasi tutti quel
valore intermedio è di per sé una risposta sbagliata tipica:

| Item | Risposta da 2 | Risposta da 1 | Che errore rappresenta |
|---|---|---|---|
| QS-SC-03 | 10 | 12 | moltiplica e dimentica la perdita |
| QS-SC-04 | 2 | 4 | trova la differenza e non la dimezza |
| QS-SC-08 | 15 | 5 | calcola lo sconto e non lo sottrae |
| QS-SC-09 | 8 | più di 4 giorni, ma sbagliato | vede la relazione inversa, sbaglia il conto |
| QS-SC-12 | 12 | 24 | calcola un tubo solo e si ferma |

Questo è ciò che rende la scala 2/1/0 informativa su un subtest numerico: il 1
distingue chi ha impostato il problema da chi non lo ha impostato. Chi
sostituisce un item deve fornire un passaggio intermedio con la stessa
proprietà, altrimenti l'item diventa di fatto 0/2 e la scala si sbilancia.

## Punti aperti

- Gli item 9, 11 e 12 riguardano la proporzionalità inversa e sono i più
  difficili della forma. Se nel pilot risultassero fuori scala, si abbassa la
  loro difficoltà progettuale o si spostano: non si abbassa il criterio del 2.
- L'item 11 (due pompe) richiede di combinare due velocità e potrebbe essere
  più difficile di quanto la posizione 11 suggerisca.
- La distinzione fra 1 e 0 dipende dal riconoscimento del passaggio intermedio,
  e quindi dalla domanda «Come hai fatto?». Serve un controllo di accordo fra
  due correttori indipendenti, come per CS.
