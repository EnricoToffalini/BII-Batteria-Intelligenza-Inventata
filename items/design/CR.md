# CR — piano del banco item

CR misura apprendimento associativo verbale e recupero differito. È **core** e
contribuisce al QI totale; con DM forma qAR.

## Struttura, e perché è diversa da tutto il resto

CR non ha item facili e item difficili: ha un **insieme fisso** di quattordici coppie
somministrate a tutti (`item_ordering: fixed_set`, `route_type:
delayed_retrieval`). Non c'è punto di partenza per età, non c'è inversione, non
c'è interruzione. Quello che varia fra le persone non è quali item vedono, ma
quanto ne ricordano.

Il `difficulty_target` dell'item bank serve quindi **solo alla simulazione** e
rappresenta la facilità di associazione della coppia, non una posizione in una
progressione.

## Le due componenti

Il punteggio di item non viene registrato: si deriva da `recall` e
`recognition`.

| `recall` | `recognition` | Punteggio | Che cosa significa |
|---|---|---|---|
| `correct` | `not_administered` | 2 | l'associazione è recuperabile con il solo cue |
| non corretto | `correct` | 1 | la traccia c'è ma serve il supporto del riconoscimento |
| non corretto | `incorrect` | 0 | nessuna traccia utilizzabile |

Questa gradazione è il punto del subtest: distingue **disponibilità** della
traccia da **accessibilità**. Un profilo con molti 1 e pochi 2 dice qualcosa di
diverso da un profilo con molti 0, e i due sarebbero indistinguibili con uno
scoring dicotomico.

Lo scorer **rifiuta** di calcolare un item in cui il richiamo è fallito e il
riconoscimento non è stato somministrato, invece di assegnargli 0: una
componente mancante non è una risposta sbagliata.

## Scelta delle coppie

Vincoli rispettati nella costruzione:

- **associazioni arbitrarie**, non collocazioni («pane … burro» sarebbe gratis);
- **nessuna rima e nessuna allitterazione** fra cue e bersaglio, che darebbero
  un appiglio fonologico;
- parole **concrete, bisillabe o trisillabe, ad alta frequenza**, note a sei
  anni;
- **cue tutti diversi, bersagli tutti diversi**, e nessuna parola usata sia come
  cue sia come bersaglio;
- interferenza semantica fra bersagli tenuta bassa, ma non azzerata: con
  quattordici bersagli concreti qualche vicinanza di categoria è inevitabile.
  Tre coppie di bersagli sono anzi vicine di proposito (lampada/candela,
  cucchiaio/forchetta, violino/tamburo), perché rendono il riconoscimento meno
  risolvibile per esclusione.

Due coppie su quattordici (`scarpa … mela`, `mano … barca`) sono più facili da legare
con un'immagine mentale. Servono a evitare il pavimento nella fascia 6–8 anni,
dove un set interamente arbitrario rischia punteggi vicini allo zero.

## Struttura dei distrattori del riconoscimento

Ogni item di riconoscimento contiene:

1. il bersaglio;
2. **una parola dello stesso ambito** del bersaglio, non presente nella lista;
3. **due bersagli di altre coppie** della lista.

Il punto 3 è quello che rende il riconoscimento informativo: senza di esso
basterebbe scegliere l'unica parola che suona «già sentita» per prendere 1 punto
senza ricordare l'associazione. Con due parole già sentite fra le opzioni, il
riconoscimento richiede la coppia e non la familiarità.

## Punti aperti

- **Rischio procedurale, non psicometrico.** CR è il subtest più facile da
  sbagliare a somministrare: richiamo immediato accidentale, una presentazione
  invece di due, ritardo fuori finestra, riconoscimento somministrato anche dopo
  un richiamo riuscito. Il manuale lo dichiara, ma serve una prova a vuoto in
  aula prima del primo uso reale.
- **Nessuna curva di apprendimento.** Con due presentazioni e nessuna prova
  intermedia non si può stimare il tasso di apprendimento, che è
  l'informazione più interessante in un test Glr. Aggiungere prove ripetute
  cambierebbe `n_scored_items`, `raw_max` e la durata: è una decisione per la
  v1, non per la v0.
- **Nessuna rievocazione libera.** Solo richiamo con suggerimento. Una prova di
  rievocazione libera prima del richiamo con cue distinguerebbe meglio recupero
  spontaneo e recupero guidato.
- **Il soffitto è stato misurato e corretto una volta.** Con dieci coppie la
  simulazione dava il 10,9% dei 17-22enni al punteggio massimo e il 35,5% a 18
  punti o più su 20: il vertice della distribuzione era indistinguibile. La forma
  è stata portata a quattordici coppie (`raw_max` 28). La correzione è per
  lunghezza della forma, non per difficoltà degli item: con coppie concrete
  arbitrarie non è credibile sostenere di poter costruire una gamma ampia di
  difficoltà, quindi i `difficulty_target` restano in una banda stretta e il
  soffitto si abbassa perché azzeccarne quattordici è meno probabile che
  azzeccarne dieci.

  Effetto misurato sulla popolazione simulata, fascia 17–22 anni:

  | | 10 coppie (raw_max 20) | 14 coppie (raw_max 28) |
  |---|---|---|
  | al punteggio massimo | 10,9% | 2,5% |
  | entro 2 punti dal massimo | 35,5% | 12,7% |
  | media, in % del massimo | 76% | 67% |

- Il soffitto residuo va riverificato nel report di routing dopo ogni modifica
  ai `difficulty_target`, e nel pilot con persone reali. Il pavimento nella
  fascia 6–10 anni resta all'1,8%, accettabile.
