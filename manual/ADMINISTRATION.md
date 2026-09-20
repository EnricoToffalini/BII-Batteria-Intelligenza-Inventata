# Manuale di somministrazione — sezioni disponibili

> Materiale didattico, non clinico. Le procedure sono plausibili ma non
> validate empiricamente.

Otto subtest su quindici hanno una sezione completa. I sette rimanenti non
hanno ancora un item bank e quindi nemmeno una procedura da documentare.

| Subtest | Ruolo | Come si somministra |
|---|---|---|
| [SP](#sp--significato-delle-parole) | core | per item, inversione uno alla volta |
| [RS](#rs--relazioni-semantiche) | core | per item, inversione a blocchi di tre |
| [RR](#rr--ragionamento-per-regole) | core | per item, inversione uno alla volta |
| [CR](#cr--coppie-da-ricordare) | core | insieme fisso, in due momenti separati |
| [SM](#sm--sequenze-e-manipolazione) | core | per livelli, tre microblocchi indipendenti |
| [CS](#cs--conoscenza-sociale) | supplementare | per item, finestra iniziale di due |
| [QS](#qs--quantità-e-strategie) | supplementare | per item, finestra iniziale di due |
| [PG](#pg--posizioni-su-griglia) | completion | per livelli, griglia 4×4 |

Le **regole comuni** qui sotto valgono per SP, RS, RR, CS e QS. CR, SM e PG
hanno procedure proprie, descritte nelle rispettive sezioni.

> **Il QI totale non è ancora calcolabile**: richiede nove subtest core e ne
> sono pronti cinque. Non presentare punteggi compositi come completi.

## Regole comuni ai subtest adattivi per item

Le procedure sotto sono uguali per SP, RS, RR, CS e QS, e valgono per ogni subtest con
`route_type: adaptive_items`. Cambiano solo i numeri, che ogni sezione riporta.

1. **Punto di partenza.** Si sceglie in base all'età in mesi. Non si parte mai
   dall'item 1 «per sicurezza» quando la tabella indica un item più avanti.
2. **Finestra iniziale.** Si somministrano i primi item consecutivi dal punto
   di partenza e si valuta se il risultato è sufficiente.
3. **Inversione.** Se non lo è, si torna indietro fino a stabilire il basale.
   Durante l'inversione non si applica mai la regola di interruzione.
4. **Basale.** Gli item precedenti al basale non si somministrano e ricevono il
   punteggio pieno. Se un item si trova sotto il basale ma era già stato
   presentato durante l'inversione, riceve comunque il punteggio pieno: la
   risposta osservata si annota in `notes` ma non entra nel totale.
5. **Ripresa.** Terminata l'inversione, si riprende dal primo item più difficile
   non ancora somministrato.
6. **Interruzione.** Si interrompe dopo la serie di zeri prevista dal subtest.
   Gli item successivi ricevono 0 punti inferiti.
7. **Stati.** Si registra sempre uno stato, mai una cella vuota:
   `administered`, `omitted`, `below_basal`, `above_ceiling`,
   `external_missing`, `invalidated`. Gli ultimi due non sono errori: in loro
   presenza il totale del subtest non viene calcolato automaticamente.

# SP — Significato delle Parole

## Materiali

- elenco degli item in `items/source/SP.csv`;
- rubriche in `items/rubrics/SP.md`;
- record form `materials/record_forms/SP_record_form.csv`;
- cronometro facoltativo per annotare la durata totale, senza bonus di tempo.

## Istruzione

Leggere l'istruzione e i due item di prova riportati nella rubrica SP. Durante
gli item scored è consentita una sola query neutra, «Puoi spiegarmi meglio?»,
quando la risposta è troppo vaga per assegnare il punteggio. Non suggerire
sinonimi o contesti e non dare feedback.

## Punto di partenza

| Età | Primo item scored |
|---|---|
| 6;0–8;11 | 1 |
| 9;0–12;11 | 4 |
| 13;0–21;11 | 7 |

Somministrare inizialmente tre item consecutivi a partire dal punto di
partenza.

## Inversione e basale

Se nei primi tre item si ottengono meno di 4 punti su 6, procedere a ritroso un
item alla volta. Il basale è raggiunto quando tre item consecutivi, letti nel
loro ordine naturale, ricevono 2 punti ciascuno. Gli item più facili non
somministrati sotto quel basale ricevono 2 punti inferiti.

Se i primi tre item totalizzano almeno 4 punti, non si applica l'inversione e
gli item precedenti al punto di partenza ricevono 2 punti inferiti. Questa è
una convenzione v0 da controllare nella simulazione e nel pilot.

Terminata l'eventuale inversione, riprendere dal primo item più difficile non
ancora somministrato.

## Interruzione

Interrompere dopo tre item consecutivi con punteggio 0 nella progressione in
avanti. Gli item successivi non somministrati ricevono 0 punti inferiti. Non
applicare la regola di interruzione mentre si procede a ritroso.

## Registrazione e scoring

Usare uno dei seguenti stati senza confonderli:

- `administered`: risposta osservata, con punteggio 0/1/2;
- `omitted`: item presentato ma senza risposta, punteggio 0;
- `below_basal`: non somministrato sotto basale, 2 punti inferiti;
- `above_ceiling`: non somministrato sopra ceiling, 0 punti inferiti;
- `external_missing`: non somministrato per motivo esterno, dato mancante;
- `invalidated`: item invalidato, dato mancante.

In presenza di `external_missing` o `invalidated`, il totale SP non viene
calcolato automaticamente. Il range grezzo valido è 0–36.

# RS — Relazioni Semantiche

## Materiali

- elenco degli item in `items/source/RS.csv`;
- istruzione, chiave e casi particolari in `items/rubrics/RS.md`;
- record form `materials/record_forms/RS_record_form.csv`;
- nessun materiale visivo: RS è interamente orale.

## Istruzione

Leggere l'istruzione e i due item di prova riportati nella rubrica RS. Negli
item di prova si corregge l'errore spiegando la relazione; negli item scored non
si dà feedback, non si spiegano le parole delle opzioni e non si suggerisce
quale relazione cercare.

Leggere sempre la consegna e poi tutte e quattro le opzioni, anche se la persona
risponde prima della fine. L'intero item può essere ripetuto una volta,
invariato.

## Punto di partenza

| Età | Primo item scored |
|---|---|
| 6;0–8;11 | 1 |
| 9;0–12;11 | 5 |
| 13;0–21;11 | 9 |

Somministrare inizialmente tre item consecutivi a partire dal punto di
partenza.

## Inversione e basale

Se nei primi tre item si ottengono meno di 2 risposte corrette, procedere a
ritroso **a blocchi di tre item**: si somministrano i tre item precedenti per
intero, poi si controlla il basale. Questa è la differenza rispetto a SP, dove
si torna indietro un item alla volta.

Il basale è raggiunto quando tre item consecutivi, letti nel loro ordine
naturale, sono tutti corretti. Gli item più facili non somministrati sotto quel
basale ricevono 1 punto inferito.

Se i primi tre item contengono almeno 2 risposte corrette, non si applica
l'inversione e gli item precedenti al punto di partenza ricevono 1 punto
inferito. Come per SP, questa è una convenzione v0 da controllare nel pilot.

## Interruzione

Interrompere dopo tre item consecutivi sbagliati nella progressione in avanti.
Gli item successivi non somministrati ricevono 0 punti inferiti. Non applicare
la regola di interruzione mentre si procede a ritroso.

## Registrazione e scoring

Usare gli stati elencati nelle regole comuni. Il range grezzo valido è 0–24.

Risposte doppie, risposte fuori lista e mancate risposte si trattano come
descritto in `items/rubrics/RS.md`; in tutti e tre i casi la risposta effettiva
si annota in `notes` anche quando il punteggio è 0.

Per controllare il punteggio da R, dalla root del repository:

```r
source("R/scoring/administer.R")
record <- read.csv("percorso/del/record_RS.csv", stringsAsFactors = FALSE)
risultato <- score_subtest_record("RS", record)
risultato$raw_score
risultato$warnings
```

`warnings` segnala procedure improbabili — per esempio una regola di
interruzione non applicata — senza rifiutare il calcolo.

# RR — Ragionamento per Regole

## Materiali

- elenco degli item in `items/source/RR.csv`;
- vocabolario dei simboli, notazione, istruzione e chiave in
  `items/rubrics/RR.md`;
- record form `materials/record_forms/RR_record_form.csv`;
- le sequenze di figure vanno **mostrate stampate**, non descritte a voce: la
  consegna si legge, le figure si guardano.

## Istruzione

Leggere l'istruzione e i due item di prova riportati nella rubrica RR. Negli
item di prova si spiega la regola per esteso quando la risposta è sbagliata;
negli item scored non si dà feedback, non si nomina la regola al posto della
persona e non si fanno esempi aggiuntivi.

La consegna di ogni item si legge ad alta voce mentre la persona guarda le
figure, e può essere riletta una volta su richiesta. Non c'è limite di tempo:
dopo circa un minuto senza risposta si invita una volta a scegliere.

## Punto di partenza

| Età | Primo item scored |
|---|---|
| 6;0–8;11 | 1 |
| 9;0–12;11 | 4 |
| 13;0–21;11 | 7 |

Somministrare inizialmente tre item consecutivi a partire dal punto di
partenza.

## Inversione e basale

Se nei primi tre item si ottengono meno di 2 risposte corrette, procedere a
ritroso **un item alla volta**, come in SP e a differenza di RS.

Il basale è raggiunto quando tre item consecutivi, letti nel loro ordine
naturale, sono tutti corretti. Gli item più facili non somministrati sotto quel
basale ricevono 1 punto inferito.

Se i primi tre item contengono almeno 2 risposte corrette, non si applica
l'inversione e gli item precedenti al punto di partenza ricevono 1 punto
inferito.

## Interruzione

Interrompere dopo tre item consecutivi sbagliati nella progressione in avanti.
Gli item successivi non somministrati ricevono 0 punti inferiti. Non applicare
la regola di interruzione mentre si procede a ritroso.

## Registrazione e scoring

Usare gli stati elencati nelle regole comuni. Il range grezzo valido è 0–20.

Vale la pena annotare in `notes`, quando succede, se la persona ha **capito la
regola** e ha comunque scelto male: è un'informazione qualitativa utile in aula
e distingue un errore di ragionamento da un fraintendimento della consegna.

```r
source("R/scoring/administer.R")
record <- read.csv("percorso/del/record_RR.csv", stringsAsFactors = FALSE)
risultato <- score_subtest_record("RR", record)
risultato$raw_score
```

# CS — Conoscenza Sociale

CS è **supplementare**: approfondisce qIC ma non entra nel QI totale. Si
somministra solo se serve il quadro completo degli indici.

## Materiali

- elenco degli item in `items/source/CS.csv`;
- rubriche item per item in `items/rubrics/CS.md`;
- record form `materials/record_forms/CS_record_form.csv`;
- nessun materiale visivo: CS è interamente orale.

## Istruzione

Leggere l'istruzione e l'item di prova riportati nella rubrica CS. Durante gli
item scored è consentita **una sola query neutra**, «Puoi spiegarmi meglio?»,
quando la risposta è troppo vaga per assegnare il punteggio. Non suggerire
contenuti, non completare la frase e non approvare o disapprovare la risposta.

## Punto di partenza

| Età | Primo item scored |
|---|---|
| 6;0–8;11 | 1 |
| 9;0–12;11 | 3 |
| 13;0–21;11 | 5 |

Somministrare inizialmente **due** item consecutivi a partire dal punto di
partenza: CS ha item lunghi e una finestra iniziale di due, non di tre.

## Inversione e basale

Se nei primi due item si ottengono meno di 2 punti su 4, procedere a ritroso un
item alla volta. Il basale è raggiunto quando due item consecutivi, letti nel
loro ordine naturale, ricevono 2 punti ciascuno. Gli item precedenti ricevono
2 punti inferiti.

Se i primi due item totalizzano almeno 2 punti, non si applica l'inversione e
gli item precedenti al punto di partenza ricevono 2 punti inferiti.

## Interruzione

Interrompere dopo tre item consecutivi con punteggio 0 nella progressione in
avanti. Non applicare la regola di interruzione mentre si procede a ritroso.

## Registrazione e scoring

Usare gli stati elencati nelle regole comuni. Il range grezzo valido è 0–20.

Trascrivere la risposta in `response` **prima** di assegnare il punteggio, e
annotare in `notes` se è stata usata la query neutra. Su un subtest a risposta
aperta la trascrizione è ciò che rende il punteggio verificabile da un secondo
correttore.

> **Attenzione al punteggio.** CS non premia la gentilezza né la lunghezza
> della risposta: 2 punti richiedono il *meccanismo*, cioè perché quella
> soluzione funziona o a che cosa serve quella regola. Una risposta cortese ma
> senza meccanismo vale 1.

# QS — Quantità e Strategie

QS è **supplementare**: approfondisce qIF ma non entra nel QI totale. Chiede
operazioni aritmetiche elementari e dipende quindi in parte dalla
scolarizzazione, più di quanto sia desiderabile per un subtest fluido.

## Materiali

- elenco degli item in `items/source/QS.csv`;
- rubriche item per item in `items/rubrics/QS.md`;
- record form `materials/record_forms/QS_record_form.csv`;
- **un foglio bianco e una matita** per i calcoli della persona esaminata;
- nessuna calcolatrice.

## Istruzione

Leggere l'istruzione e l'item di prova riportati nella rubrica QS. Il foglio per
i calcoli si mette a disposizione **dall'inizio**, non solo quando la persona lo
chiede: metterlo a disposizione a metà prova renderebbe gli item non
confrontabili.

Ogni item può essere riletto una volta per intero. Non c'è limite di tempo:
dopo circa novanta secondi si chiede una volta «Vuoi provare a dirmi come
faresti?».

## Punto di partenza

| Età | Primo item scored |
|---|---|
| 6;0–8;11 | 1 |
| 9;0–12;11 | 4 |
| 13;0–21;11 | 7 |

Somministrare inizialmente **due** item consecutivi a partire dal punto di
partenza.

## Inversione e basale

Se nei primi due item si ottengono meno di 2 punti su 4, procedere a ritroso un
item alla volta. Il basale è raggiunto quando due item consecutivi ricevono 2
punti ciascuno. Gli item precedenti ricevono 2 punti inferiti.

## Interruzione

Interrompere dopo tre item consecutivi con punteggio 0 nella progressione in
avanti. Non applicare la regola di interruzione mentre si procede a ritroso.

## Registrazione e scoring

Usare gli stati elencati nelle regole comuni. Il range grezzo valido è 0–24.

Il punteggio 1 esiste per una ragione precisa: separa chi ha impostato bene il
problema e si è fermato a metà da chi non lo ha impostato. Quando la risposta
non basta a decidere fra 1 e 0, si chiede **una sola volta** «Come hai fatto?»,
dopo che la risposta è già stata data. Trascrivere la risposta in `response` e
il passaggio dichiarato in `notes`.

Il foglio dei calcoli non si corregge e non si conserva come dato.

# CR — Coppie da Ricordare

CR è **core** e contribuisce al QI totale. Non segue le regole comuni dei
subtest adattivi: non ha punto di partenza per età, inversione, basale o
interruzione. Tutti fanno tutti e quattordici gli item.

CR si somministra **in due momenti separati**, con altri subtest in mezzo.

## Materiali

- coppie, chiave e ordine di lettura in `items/rubrics/CR.md`;
- record form `materials/record_forms/CR_record_form.csv`;
- **un orologio o cronometro** per misurare i 15 minuti di intervallo;
- il filler `F15_A` se la sequenza di subtest si esaurisce prima.

## La regola da non violare

> **Dopo lo studio non si chiede nulla sulle coppie.** Nessun richiamo
> immediato, nemmeno informale, nemmeno «te le ricordi?». Un richiamo immediato
> aggiunge una prova di recupero che nessun altro ha fatto e rende il punteggio
> differito non confrontabile.

## Fase 1 — studio (circa 1 minuto)

Leggere le quattordici coppie nell'ordine della chiave, circa una coppia ogni
due secondi. Pausa di cinque secondi. **Rileggere l'intera lista nello stesso
ordine.** Due presentazioni esatte.

Non si dà feedback, non si ripete una coppia su richiesta, non si dice quante
coppie sono.

## Intervallo — 15 minuti

Proseguire con i subtest successivi previsti dalla sequenza. Annotare l'ora di
fine studio: serve per misurare il ritardo effettivo.

Se i subtest previsti finiscono prima dei 15 minuti, usare il filler `F15_A`
(2–4 minuti, materiale uditivo-verbale non scorato).

## Fase 2 — recupero differito (3–4 minuti)

Registrare il ritardo effettivo in `delay_minutes`. Finestra prevista **14–16
minuti**: fuori finestra il punteggio si calcola comunque ma lo scorer avvisa.

**2a — richiamo con suggerimento.** Per ogni item leggere solo la prima parola e
attendere circa dieci secondi:

| Esito | `recall` | Poi |
|---|---|---|
| risposta corretta | `correct` | si passa all'item successivo |
| risposta sbagliata | `incorrect` | si farà il riconoscimento |
| nessuna risposta in 10 secondi | `omitted` | si farà il riconoscimento |

**2b — riconoscimento.** Solo per gli item con richiamo non riuscito, leggere le
quattro opzioni nell'ordine della chiave e registrare `recognition` come
`correct` o `incorrect`. Per gli item già recuperati, `not_administered`.

## Registrazione e scoring

**Non si scrive un punteggio di item.** Il modulo non ha la colonna `item_score`
di proposito: si registrano `recall` e `recognition`, e il punteggio viene
derivato. Range grezzo 0–28.

| `recall` | `recognition` | Punteggio |
|---|---|---|
| `correct` | `not_administered` | 2 |
| `incorrect` / `omitted` | `correct` | 1 |
| `incorrect` / `omitted` | `incorrect` | 0 |

Se un richiamo è fallito e il riconoscimento non è stato somministrato, lo
scorer **si rifiuta di calcolare** quell'item invece di assegnargli 0. Il
messaggio d'errore indica quali item completare.

Annotare in `notes` quando la risposta sbagliata è il bersaglio di un'altra
coppia: indica che la lista è stata appresa ma non l'associazione, e in aula è
l'osservazione qualitativa più interessante del subtest.

```r
source("R/scoring/administer.R")
record <- read.csv("percorso/del/record_CR.csv", stringsAsFactors = FALSE)
risultato <- score_subtest_record("CR", record)
risultato$raw_score
risultato$warnings   # segnala ritardo fuori finestra o non registrato
```

# PG — Posizioni su Griglia

PG è **completion**: completa qML insieme a SM ma non entra nel QI totale.

PG non segue le regole comuni dei subtest adattivi per item: si somministra
**per livelli di lunghezza**, con due prove per livello.

## Materiali

- una **griglia 4×4 stampata con celle vuote e identiche**, senza etichette;
- sequenze, notazione e chiave in `items/rubrics/PG.md`;
- record form `materials/record_forms/PG_record_form.csv`.

> **Non mostrare una griglia con le etichette delle caselle.** Le etichette
> permettono di ripetere la sequenza a parole e trasformano una prova
> visuo-spaziale in una prova verbale.

## Istruzione

Leggere l'istruzione e somministrare **entrambi gli item di prova** a tutti,
anche a chi parte da un livello più alto. Se la persona sbaglia una prova, si
mostra la risposta corretta e si rifà una volta.

Toccare una cella circa **ogni secondo**, senza nominarla, senza contare e senza
seguire con il dito il percorso fra una cella e l'altra. Una sequenza non si
ripete mai.

## Livello di partenza

| Età | Livello di partenza |
|---|---|
| 6;0–8;11 | 2 posizioni |
| 9;0–12;11 | 3 posizioni |
| 13;0–21;11 | 4 posizioni |

## Progressione fra i livelli

Si somministrano **sempre entrambe le prove** del livello, poi si decide:

| Esito al livello | Che cosa fare |
|---|---|
| entrambe corrette | i livelli più bassi ricevono 1 punto ciascuno; si sale |
| una corretta, una sbagliata | i livelli più bassi ricevono 1 punto ciascuno; si sale |
| entrambe sbagliate al livello di partenza | si scende di un livello alla volta fino a un livello con entrambe corrette |
| entrambe sbagliate salendo | si **interrompe**; i livelli successivi ricevono 0 |

Scendendo non si applica la regola di interruzione. Se si arriva al livello 2
senza trovare un livello con entrambe le prove corrette, non si infersice nulla
sotto.

## Registrazione e scoring

Ogni prova vale 1 punto solo se la sequenza è riprodotta **esattamente**: stesso
ordine, nessuna omissione, nessuna aggiunta. Non ci sono punteggi parziali.
Range grezzo 0–16.

Usare gli stati elencati nelle regole comuni. Trascrivere in `response` la
sequenza effettivamente prodotta, anche quando è sbagliata: il tipo di errore
(inversione di due posizioni, omissione della prima, sequenza invertita) è
l'informazione qualitativa più utile del subtest e non si ricostruisce dal
punteggio.

```r
source("R/scoring/administer.R")
record <- read.csv("percorso/del/record_PG.csv", stringsAsFactors = FALSE)
risultato <- score_subtest_record("PG", record)
risultato$raw_score
```

# SM — Sequenze e Manipolazione

SM è **core** e contribuisce al QI totale, insieme a PG forma qML.

SM non segue le regole comuni dei subtest adattivi per item: si somministra
**per livelli**, come PG, ma è diviso in **tre microblocchi** con un compito
diverso ciascuno. Ogni microblocco si somministra **per intero e in modo
indipendente**, con il proprio punto di partenza, il proprio basale e il
proprio ceiling, prima di passare al successivo.

## Materiali

- nessun materiale oltre alla voce: SM è interamente uditivo-verbale;
- sequenze, istruzioni e chiave in `items/rubrics/SM.md`;
- record form `materials/record_forms/SM_record_form.csv`;
- **un ambiente silenzioso**, senza distrazioni acustiche.

## I tre microblocchi, nell'ordine di somministrazione

1. **Ripetizione a ritroso** — richiamare la sequenza al contrario.
2. **Riordino per regola** — richiamare la sequenza dal numero più piccolo al
   più grande.
3. **Span aggiornato** — richiamare solo le ultime cifre dette, scartando
   quelle più vecchie.

Prima di ciascun microblocco, dare l'istruzione specifica riportata nella
rubrica e somministrare **il suo item di prova**. Non si passa al microblocco
successivo finché il primo non è concluso (basale trovato o interruzione
raggiunta).

Dire ogni cifra a ritmo costante, circa una al secondo, senza raggruppare le
cifre. Non scrivere né mostrare i numeri: la prova è solo orale. Non ripetere
una sequenza già letta, tranne negli item di prova.

## Livello di partenza

Lo stesso per tutti e tre i microblocchi:

| Età | Livello di partenza |
|---|---|
| 6;0–8;11 | 2 cifre |
| 9;0–12;11 | 3 cifre |
| 13;0–21;11 | 4 cifre |

## Progressione fra i livelli, per ciascun microblocco

Le stesse regole di PG, applicate separatamente a ogni microblocco:

| Esito al livello | Che cosa fare |
|---|---|
| entrambe le prove corrette | i livelli più bassi *di quel microblocco* ricevono 1 punto ciascuno; si sale |
| una corretta, una sbagliata | i livelli più bassi ricevono 1 punto ciascuno; si sale comunque |
| entrambe sbagliate al livello di partenza | si scende di un livello alla volta fino a un livello con entrambe corrette |
| entrambe sbagliate salendo | si **interrompe quel microblocco**; i suoi livelli successivi ricevono 0 |

Terminato un microblocco (per basale trovato risalendo, o per interruzione), si
passa al successivo e la procedura ricomincia dal punto di partenza per età.

## Registrazione e scoring

Ogni prova vale 1 punto solo se la sequenza è riprodotta **esattamente**, nello
stesso ordine, senza omissioni né aggiunte. Non ci sono punteggi parziali.
Range grezzo 0–36 (12 punti per microblocco).

Usare gli stati elencati nelle regole comuni. Trascrivere in `response` la
sequenza effettivamente prodotta, anche quando è sbagliata: il tipo di errore
(inversione di due cifre, cifra dimenticata, ordine parzialmente corretto)
è l'informazione qualitativa più utile del subtest.

Nel microblocco «Span aggiornato», dichiarare **prima di ogni item** quante
cifre finali si chiederanno: non è un'informazione da indovinare, fa parte
della consegna.

```r
source("R/scoring/administer.R")
record <- read.csv("percorso/del/record_SM.csv", stringsAsFactors = FALSE)
risultato <- score_subtest_record("SM", record)
risultato$raw_score
```
