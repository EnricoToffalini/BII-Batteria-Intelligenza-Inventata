# CL — brief di progettazione e piano del prototipo

CL misura la rapidità di un confronto percettivo ripetitivo tra due stringhe di
simboli. È `core`, rappresenta Gs nel QI totale e forma qVE insieme a SS. La
forma definitiva prevista dalla spec comprende 100 confronti, 10 esercizi e un
limite fisso di 2 minuti, ma questo brief **non autorizza ancora a costruire la
banca completa**.

## Confine del costrutto

La persona decide se due stringhe di quattro simboli sono identiche, simbolo
per simbolo e nello stesso ordine. La regola rimane uguale per tutta la prova.
Non si chiedono trasformazioni, completamenti, conteggi, inferenze o memoria
della stringa: introdurli sposterebbe il compito da velocità di confronto verso
Gf o Gwm.

Ogni riga mostra entrambe le stringhe contemporaneamente e offre le due risposte
`UGUALE` e `DIVERSO`. La persona marca una sola casella. Gli item di prova danno
feedback; durante la prova scored non si dà feedback e non si ripete la
consegna salvo un richiamo generale a continuare in ordine.

## Grammatica dello stimolo

- Ogni stringa contiene esattamente quattro posizioni.
- Ogni posizione è una cella di larghezza fissa; non si usano spazi di testo
  per allineare i glifi.
- Il vocabolario chiuso è dichiarato in `spec/subtests/CL.yml`: `○`, `△`, `□`,
  `◆`, `+`, `★`. Nessun altro glifo può comparire nelle stringhe.
- Non si usano coppie aperto/pieno della stessa forma (`○`/`●`, `□`/`■`): la
  discriminazione di un dettaglio interno non deve diventare una regola
  parallela.
- Colore, rotazione, dimensione e peso tipografico non portano informazione.
  Tutti i simboli sono neri, verticali e centrati nella propria cella.
- Una coppia `UGUALE` replica i quattro simboli senza alcuna variazione. Una
  coppia `DIVERSO` appartiene a una sola famiglia definita sotto.

P2 ha usato **Segoe UI Symbol**, ma P3 ha respinto la dipendenza da un font di
sistema non portabile. P2R ha quindi associato ciascun token del vocabolario a
una primitiva SVG deterministica, con bounding box e stroke comuni; P3R ha
approvato questa convenzione per un micro-lotto. La stringa nel CSV resta la
fonte semantica: il renderer non può sostituire o reinterpretare un token.

## Famiglie di confronto

Le famiglie modificano solo l'interferenza percettiva. La decisione richiesta
resta sempre identica.

| Famiglia | Stringa di sinistra | Coppia diversa | Controllo principale |
|---|---|---|---|
| `distinct_substitution` | quattro simboli diversi | sostituzione di un solo simbolo | baseline; posizione della discrepanza |
| `repeated_substitution` | una ripetizione, adiacente o separata | sostituzione di un solo simbolo | interferenza da simboli ripetuti |
| `adjacent_transposition` | almeno tre simboli diversi | scambio di due simboli adiacenti diversi | sensibilità all'ordine senza nuova regola |
| `separated_transposition` | quattro simboli diversi | scambio di due simboli non adiacenti | confronto dell'ordine su distanza maggiore |

Una coppia diversa non combina sostituzione e trasposizione. Le trasposizioni
che producono per caso la stessa stringa sono vietate. Le famiglie con
ripetizione non possono contenere più di due occorrenze dello stesso simbolo:
stringhe come `○ ○ ○ ○` ridurrebbero il confronto a un conteggio o renderebbero
troppo evidente una sostituzione.

## Bilanciamento previsto per la forma completa

Questi sono vincoli progettuali da verificare quando esisterà una banca, non
una banca già approvata:

- 50 item `UGUALE` e 50 `DIVERSO`;
- in ogni blocco grafico, differenza fra i due esiti non superiore a 2;
- non più di tre risposte uguali consecutive;
- nelle sostituzioni, le quattro posizioni della discrepanza compaiono con
  frequenza quanto più possibile uniforme;
- simboli e coppie ordinate di simboli non devono predire la risposta;
- ogni famiglia compare lungo tutto il foglio, senza un blocco finale
  sistematicamente più difficile;
- le 10 prove guidate hanno 5 esiti uguali e 5 diversi e mostrano almeno una
  sostituzione e una trasposizione, ma non entrano nel punteggio.

Il 50/50 evita una strategia vantaggiosa basata sulla risposta prevalente. Il
limite sulle sequenze riduce risposte automatiche, senza imporre
un'alternanza perfetta che diventerebbe a sua volta prevedibile.

## Layout e percorso sul foglio

Le prove guidate vanno su una pagina separata. La pagina scored deve avere un
solo percorso evidente: dall'alto in basso nella prima colonna, poi nella
colonna immediatamente a destra. Numeri di riga, testatine ripetute e frecce
`CONTINUA` al fondo della colonna servono a prevenire salti; non si usa un
percorso a serpentina.

Ogni riga contiene, nell'ordine:

1. numero piccolo dell'item;
2. prima stringa in quattro celle invisibili di uguale larghezza;
3. separatore verticale neutro;
4. seconda stringa nello stesso reticolo;
5. lettera-bersaglio `U`;
6. lettera-bersaglio `D`.

Le celle strutturano l'allineamento ma i loro bordi non vengono stampati. Le
lettere `U` e `D` sono ripetute su ogni riga e vengono barrate direttamente,
senza caselle, cerchi o altri contenitori geometrici. Il prototipo P2 ha
mostrato che una casella quadrata compete visivamente con `□`; una casella
circolare sposterebbe lo stesso problema su `○`. La marcatura non deve
richiedere di ricopiare simboli.

P2 ha confrontato due impaginazioni a scala reale:

- A4 orizzontale, 4 colonne × 25 righe;
- A3 orizzontale, 4 colonne × 25 righe.

P3 conserva **A4 come unico candidato**: è leggibile al 100% e riduce la
distanza fra stimolo e risposta; A3 aggiunge movimento oculomotorio, richiede
hardware meno comune e non migliora il matching. A4 non è ancora approvato per
la forma completa: P3R lo ha approvato soltanto per un micro-lotto e la
marcabilità va ancora verificata su carta al 100%, senza “adatta alla pagina”.

## Difficoltà prevista e ordine

CL non è adattivo e non deve avere una progressione di difficoltà come SP o RR.
I fattori di difficoltà ipotizzati sono:

- posizione più tarda della discrepanza in una scansione sinistra-destra;
- simboli ripetuti, che aumentano l'interferenza;
- trasposizione rispetto a sostituzione;
- affaticamento e cambio di colonna.

Sono ipotesi da controllare, non parametri calibrati. Dopo alcune righe iniziali
semplici, la forma completa dovrà intercalare i fattori in modo stratificato.
La posizione sul foglio non può essere usata come sinonimo di difficoltà: in
una prova timed gli ultimi item sono osservati da meno persone.

## P2 — prototipo di una sola famiglia

Il primo prototipo comprende **6 stimoli non definitivi** della famiglia
`distinct_substitution`:

- 3 `UGUALE` e 3 `DIVERSO`;
- per i diversi, discrepanza nelle posizioni 1, 2 e 4;
- quattro simboli distinti in ogni stringa;
- nessun simbolo o risposta corretta prevedibile dalla posizione nel mini-set.

P2 ha prodotto una sorgente deterministica, immagini rese a scala di stampa e
una tabella di chiavi separata. P3 ha poi ritirato A3 e P2R ha conservato i sei
stimoli nel solo A4, senza riempire le altre 94 righe con item fittizi.

## P4 — primo micro-lotto controllato

P4 ha aggiunto **8 stimoli non definitivi** della stessa famiglia, portando il
prototipo a 14 righe: 4 `UGUALE`, 4 `DIVERSO`, una sostituzione in ciascuna
posizione e copertura completa del vocabolario. Il lotto è tornato a review
gate; non autorizza una seconda espansione né modifica lo status di CL.

## Criteri osservabili applicati nei review gate

P3 e P3R hanno applicato questi criteri all'ispezione al 100%:

- tutti i sei glifi sono presenti come primitive previste, senza fallback;
- i quattro simboli di ogni stringa sono centrati e non si toccano;
- stringhe sinistra e destra hanno identica metrica e nessun indizio di
  lunghezza complessiva rivela la risposta;
- a normale distanza di lettura la riga corretta si segue senza invadere quella
  sopra o sotto;
- le lettere-bersaglio `U`/`D` sono marcabili e non dominano visivamente gli
  stimoli;
- il passaggio fra colonne è inequivocabile;
- la coppia uguale è una copia esatta e ciascuna coppia diversa ha una sola
  discrepanza prevista dalla chiave;
- l'item più difficile resta un confronto percettivo semplice, non richiede
  conteggio o memoria;
- il file riporta formato pagina e scala, così una ristampa è riproducibile.

Un esito negativo non si corregge espandendo la banca. P3R ha autorizzato un
solo lotto di otto stimoli, prodotto da P4 e ora fermo al nuovo review gate.

## Rischi di resa e contaminazione

- **Deriva delle primitive:** bounding box o stroke diversi possono rendere un
  simbolo più saliente; il test deve verificare che ogni token abbia una sola
  definizione versionata.
- **Densità eccessiva:** 100 righe su una pagina possono trasformare CL in una
  prova di inseguimento visivo o motricità fine.
- **Etichette di risposta:** le sole lettere `U` e `D` riducono l'affollamento,
  ma la comprensione della legenda va verificata negli esercizi guidati.
- **Ordine prevedibile:** un pattern regolare delle chiavi misura
  apprendimento della sequenza, non matching.
- **Differenze troppo salienti:** una sostituzione con un simbolo isolato per
  forma o densità può rendere alcuni item un pop-out.
- **Accessibilità:** visus, coordinazione motoria e familiarità con la lettura
  sinistra-destra possono influire sul punteggio e devono essere annotati in un
  futuro pilot; CL non è una misura clinica o diagnostica.

## Punti aperti

- A4 è il solo formato candidato dopo P3, ma la densità di 25 righe per colonna
  e la marcabilità delle lettere `U`/`D` richiedono ancora una stampa al 100%.
- Prima dell'integrazione finale serve almeno un rendering in un secondo
  ambiente per verificare la portabilità dell'intero foglio, non solo dei
  glifi scored.
- Non è ancora verificato che tutti, in particolare i più giovani, mantengano
  stabile la legenda `U`/`D` per due minuti. Le prove guidate devono includere
  correzione esplicita della modalità di marcatura.
- Le famiglie di trasposizione potrebbero risultare più facili, non più
  difficili, perché producono due posizioni discordanti. Vanno incluse solo
  dopo evidenza dal prototipo o da un micro-pilot.
- La correzione `corrette - errori` e il limite di 2 minuti sono già nella
  spec. Un eventuale problema osservato richiederebbe un packet di decisione
  cross-cutting, non una modifica silenziosa durante la generazione.
- Prima di dichiarare CL completo serviranno una procedura d'esame, una prova
  con utenti e un controllo esplicito che corrette, errori e omissioni siano
  conteggiabili senza ambiguità dal foglio compilato.
