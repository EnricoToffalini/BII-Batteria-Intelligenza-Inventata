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

Il font candidato per il prototipo è **Segoe UI Symbol**, presente
nell'ambiente di sviluppo e capace di coprire i sei glifi. Il rendering deve
incorporare o delineare il font: un fallback silenzioso può cambiare larghezze,
peso e centratura. Questa scelta è provvisoria finché P2 non dimostra la resa
nel PDF e nella stampa al 100%; non è una richiesta di aggiungere il font al
repository.

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
5. casella `UGUALE`;
6. casella `DIVERSO`.

Le celle strutturano l'allineamento ma i loro bordi non vengono stampati. Le
due caselle di risposta devono essere abbastanza grandi da accettare una barra
con matita senza invadere la riga vicina. La marcatura non deve richiedere di
ricopiare simboli.

P2 deve confrontare almeno due impaginazioni a scala reale prima di scegliere:

- A4 orizzontale, 4 colonne × 25 righe;
- A3 orizzontale, 4 colonne × 25 righe.

Il confronto non implica che A3 sia preferibile: deve mostrare se A4 mantiene
glifi, spaziatura e bersagli motori leggibili. La stampa va eseguita al 100%,
senza “adatta alla pagina”. Non si decide ora se il formato finale debba essere
A4 o A3.

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

P2 deve produrre una sorgente deterministica, un PDF o immagine reso a scala di
stampa e una tabella di chiavi separata. Gli stessi sei stimoli vanno collocati
in entrambe le impaginazioni candidate; non si riempiono le altre 94 righe con
item fittizi.

## Criteri osservabili per il review gate

Il prototipo può passare a P3 solo se l'ispezione a stampa o al 100% conferma:

- tutti i sei glifi sono presenti e provengono dal font previsto, senza
  quadratini mancanti o fallback;
- i quattro simboli di ogni stringa sono centrati e non si toccano;
- stringhe sinistra e destra hanno identica metrica e nessun indizio di
  lunghezza complessiva rivela la risposta;
- a normale distanza di lettura la riga corretta si segue senza invadere quella
  sopra o sotto;
- le caselle sono marcabili e le etichette non dominano visivamente gli
  stimoli;
- il passaggio fra colonne è inequivocabile;
- la coppia uguale è una copia esatta e ciascuna coppia diversa ha una sola
  discrepanza prevista dalla chiave;
- l'item più difficile resta un confronto percettivo semplice, non richiede
  conteggio o memoria;
- il file riporta formato pagina e scala, così una ristampa è riproducibile.

Un esito negativo non si corregge espandendo la banca: P3 deve approvare,
revisionare o scartare il prototipo e definire soltanto il lotto seguente.

## Rischi di resa e contaminazione

- **Fallback del font:** può rendere un glifo più piccolo o cambiare il peso;
  va rilevato nel rendering, non accettato come differenza di piattaforma.
- **Densità eccessiva:** 100 righe su una pagina possono trasformare CL in una
  prova di inseguimento visivo o motricità fine.
- **Etichette di risposta:** ripetere per esteso `UGUALE` e `DIVERSO` in ogni
  riga può introdurre affollamento e lettura; il prototipo deve misurarne
  l'impatto prima di abbreviare le etichette.
- **Ordine prevedibile:** un pattern regolare delle chiavi misura
  apprendimento della sequenza, non matching.
- **Differenze troppo salienti:** una sostituzione con un simbolo isolato per
  forma o densità può rendere alcuni item un pop-out.
- **Accessibilità:** visus, coordinazione motoria e familiarità con la lettura
  sinistra-destra possono influire sul punteggio e devono essere annotati in un
  futuro pilot; CL non è una misura clinica o diagnostica.

## Punti aperti

- A4 o A3: la decisione dipende dalla resa reale dei sei prototipi e dalla
  disponibilità pratica di stampa, non dalla quantità di spazio teorica.
- Segoe UI Symbol è disponibile nell'ambiente corrente ma non è ancora una
  dipendenza portabile. P2 deve stabilire se incorporarlo nel PDF è sufficiente
  o se serve in seguito un font libero versionabile.
- Non è ancora noto se ripetere le parole `UGUALE` e `DIVERSO` in ogni riga
  provochi più affollamento di una testatina di colonna; entrambe le soluzioni
  vanno confrontate senza cambiare la regola di risposta.
- Le famiglie di trasposizione potrebbero risultare più facili, non più
  difficili, perché producono due posizioni discordanti. Vanno incluse solo
  dopo evidenza dal prototipo o da un micro-pilot.
- La correzione `corrette - errori` e il limite di 2 minuti sono già nella
  spec. Un eventuale problema osservato richiederebbe un packet di decisione
  cross-cutting, non una modifica silenziosa durante la generazione.
- Prima di dichiarare CL completo serviranno una procedura d'esame, una prova
  con utenti e un controllo esplicito che corrette, errori e omissioni siano
  conteggiabili senza ambiguità dal foglio compilato.
