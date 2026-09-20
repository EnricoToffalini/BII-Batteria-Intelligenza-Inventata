# RR — istruzioni e chiavi

Forma completa in bozza: 20 item scored e 2 item di prova. La chiave qui sotto
deve sempre coincidere con `items/source/RR.csv`; il CSV è la fonte, questa
pagina è la versione leggibile per l'esaminatore.

## Vocabolario dei simboli

RR usa **sei simboli e nessun altro**, dichiarati in `spec/subtests/RR.yml`:

| Simbolo | Nome | Simbolo | Nome |
|---|---|---|---|
| ● | cerchio pieno | ○ | cerchio vuoto |
| ■ | quadrato pieno | □ | quadrato vuoto |
| ▲ | triangolo pieno | △ | triangolo vuoto |

Sono tre forme × due riempimenti. Il vocabolario è chiuso di proposito: le
regole degli item si basano su forma e riempimento, quindi introdurre un
settimo simbolo cambierebbe silenziosamente lo spazio delle regole possibili.
Un test fallisce se nel CSV compare un simbolo non dichiarato.

Tutti e sei sono nel blocco Unicode *Geometric Shapes* (U+25A0–U+25CF) e sono
presenti in qualunque font di sistema, quindi si stampano senza sostituzioni.

## Notazione

- le figure di una sequenza sono separate da uno spazio: `● ■ ▲`;
- quando le figure formano un gruppo compatto si scrivono unite: `●○●`;
- gruppi diversi dello stesso item sono separati da `/`: `●● / ▲▲ / ■■`;
- `?` indica la posizione da completare.

## Istruzione

> Adesso guardiamo delle figure. Ogni volta ti dirò una regola oppure ti farò
> vedere degli esempi. Tu devi capire come funziona e scegliere la risposta
> giusta fra le quattro.

La consegna di ogni item va **letta ad alta voce** mentre la persona guarda le
figure. La regola può essere riletta una volta su richiesta, senza spiegarla e
senza fare esempi in più. Non si nomina la regola al posto della persona e non
si dice se una risposta è giusta, tranne negli item di prova.

Non c'è limite di tempo per item. Dopo circa un minuto senza risposta si invita
una volta a scegliere; se la persona non sceglie, si registra `omitted`.

## Item di prova

Negli item di prova si corregge l'errore spiegando la regola per esteso.

| Item | Risposta | Regola da spiegare |
|---|---|---|
| RR-PR-01 | A — ○ | le due figure si alternano |
| RR-PR-02 | A — ■ ○ ■ | la regola tocca solo i ●, gli altri restano |

Se la persona sbaglia entrambi gli item di prova, si possono rifare una volta
sola prima di passare agli item scored. Il fatto va annotato in `notes`.

## Chiave rapida

| Ordine | Item | Risposta | Famiglia |
|---|---|---|---|
| 1 | RR-SC-01 | B — ○ | series_completion |
| 2 | RR-SC-02 | C — ● ■ ● | rule_transformation |
| 3 | RR-SC-03 | C — ▲ | constraint_ordering |
| 4 | RR-SC-04 | D — ▲▲▲▲ | series_completion |
| 5 | RR-SC-05 | A — ▲ ● ▲ ▲ | rule_transformation |
| 6 | RR-SC-06 | C — ▲▲ | rule_induction |
| 7 | RR-SC-07 | A — ▲ | constraint_ordering |
| 8 | RR-SC-08 | D — △ | series_completion |
| 9 | RR-SC-09 | C — ■ ▲ ▲ | conditional_rule |
| 10 | RR-SC-10 | D — ■ ▲ ○ ● | rule_transformation |
| 11 | RR-SC-11 | B — ■□■ | rule_induction |
| 12 | RR-SC-12 | A — ▲ ● ■ | constraint_ordering |
| 13 | RR-SC-13 | D — ● | series_completion |
| 14 | RR-SC-14 | A — ● ○ ▲ ○ | conditional_rule |
| 15 | RR-SC-15 | C — △ ■ ▲ ○ | rule_transformation |
| 16 | RR-SC-16 | D — ○■△ | rule_induction |
| 17 | RR-SC-17 | D — non si può sapere | constraint_ordering |
| 18 | RR-SC-18 | A — un gruppo in cui si vede un ■ | conditional_rule |
| 19 | RR-SC-19 | B — ■ | series_completion |
| 20 | RR-SC-20 | A — ○●▲ | rule_induction |

Ogni risposta corretta vale 1 punto. Le altre risposte e le omissioni valgono
0 solo se l'item è stato effettivamente somministrato: gli item non
somministrati per ragione esterna restano mancanti e non diventano errori.

## Risposte non elencate

Valgono le stesse tre regole di RS:

- **risposta doppia**: chiedere una volta «Quale delle due scegli?»; senza
  scelta l'item vale 0;
- **risposta fuori lista**: rileggere una volta le quattro opzioni; se la
  risposta resta fuori lista l'item vale 0 e si annota in `response`;
- **nessuna risposta**: dopo circa un minuto invitare una volta a scegliere;
  senza scelta si registra `omitted`.

## Due item che meritano attenzione

**RR-SC-17** è l'unico item in cui «non si può sapere» è la risposta corretta.
L'opzione compare anche in RR-SC-03, RR-SC-07 e RR-SC-12, dove i vincoli sono
invece sufficienti: serve proprio a impedire che la sua presenza diventi un
indizio. Non anticipare mai che in qualche item i vincoli non bastano.

**RR-SC-20** ammette due letture della regola — «le prime due figure hanno la
stessa forma e la terza no» e «la terza figura ha forma diversa dalla prima».
I tre distrattori falliscono sotto entrambe le letture, quindi la risposta
corretta è la stessa in ogni caso. Chi sostituisce questo item deve rifare
questa verifica: è l'errore più facile da introdurre negli item di induzione.

## Limiti dichiarati

La progressione di difficoltà è progettuale, non stimata. Gli item di
`conditional_rule` (9, 14, 18) sono i più esposti a fraintendimenti della
consegna più che a un vero fallimento del ragionamento: nella prima prova con
studenti conviene annotare se la persona ha capito la regola e ha comunque
scelto male, oppure non ha capito la regola.
