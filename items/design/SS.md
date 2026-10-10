# SS — brief di progettazione e piano del prototipo

SS misura la ricerca visiva selettiva rapida in una matrice di simboli. È un
subtest di `completion`: completa qVE con CL ma non contribuisce al QI totale.
La forma prevista dalla spec mostra 200 stimoli, dei quali 100 target, e
registra `hits`, `false_alarms` e `omissions`. Questo brief non crea una banca
item, non approva il foglio definitivo e non trasforma la durata pianificata di
2–3 minuti in un limite fisso.

La BII resta uno strumento didattico con norme simulate, non clinico o
diagnostico.

## Confine del costrutto

La persona percorre una matrice in ordine e barra ogni occorrenza di un unico
target definito prima dell'inizio. La regola rimane identica per tutto il
foglio. Il compito richiede selezione visiva ripetitiva e controllo dei falsi
allarmi, ma non deve richiedere:

- cambio di regola o set-shifting;
- memoria di più target;
- conteggio per decidere se marcare;
- inferenze, completamenti o trasformazioni geometriche;
- confronto fra coppie di stringhe, che duplichererebbe CL;
- conoscenze verbali o scolastiche oltre alla consegna.

La maggiore componente attentiva rispetto a CL è intenzionale e spiega il
ruolo di completamento dell'indice. Non deve però diventare il principio che
genera la difficoltà: la difficoltà prevista deriva da densità, somiglianza
percettiva e posizione nel percorso, non da regole esecutive aggiuntive.

## Regola unica

La regola candidata è:

> Barra ogni **cerchio con una linea verticale all'interno**. Non barrare gli
> altri simboli.

Il target è una congiunzione di due caratteristiche sempre visibili: contorno
circolare e linea interna verticale. I distrattori condividono una delle due
caratteristiche oppure nessuna. Il target viene mostrato accanto alla consegna
e resta visibile durante la prova; non è un elemento da ricordare.

La marcatura candidata è una singola barra obliqua che attraversa il simbolo.
Nessun simbolo pre-stampato contiene linee diagonali: così una marcatura leggera
non può essere scambiata con una caratteristica dello stimolo.

## Vocabolario chiuso e primitive

Il vocabolario completo è dichiarato in `spec/subtests/SS.yml`. I token sono
identificatori semantici per il generatore, non testo da stampare.

| Token | Resa prevista | Ruolo |
|---|---|---|
| `circle_vertical` | cerchio aperto + linea verticale interna | **target** |
| `circle_horizontal` | cerchio aperto + linea orizzontale interna | distrattore: stesso contorno |
| `square_vertical` | quadrato aperto + linea verticale interna | distrattore: stessa linea |
| `square_horizontal` | quadrato aperto + linea orizzontale interna | distrattore |
| `triangle_vertical` | triangolo aperto + linea verticale interna | distrattore: stessa linea |
| `triangle_horizontal` | triangolo aperto + linea orizzontale interna | distrattore |

Ogni token deve essere reso con una primitiva SVG deterministica. Le sei
primitive condividono:

- bounding box e centro;
- dimensione esterna nominale;
- stroke del contorno e della linea interna;
- colore nero su fondo bianco;
- distanza minima fra linea interna e contorno.

Rotazione, colore, dimensione e spessore non portano informazione. Non sono
ammessi font di sistema per i simboli scored, fallback, glifi aggiuntivi o
decorazioni. Il triangolo non deve risultare più grande o più scuro soltanto
per compensare la sua forma: la salienza va giudicata sul rendering, non
corretta a intuito nel CSV.

## Composizione della forma

La composizione formalizzata nella spec rende esplicita l'interpretazione già
implicita nei range di scoring:

- 100 `circle_vertical` target;
- 20 occorrenze per ciascuno dei cinque distrattori;
- 100 target + 100 distrattori = 200 stimoli totali;
- `n_scored_items: 100` indica i 100 target che possono produrre hit o
  omissione, non il numero di celle stampate.

La prevalenza target del 50% non è presentata come ottimale o calibrata: è il
vincolo v0 già incorporato nella spec e nella simulazione. Un futuro pilot può
motivare una modifica, ma sarebbe una decisione cross-cutting su conteggi,
range, scoring e output derivati.

Per la forma completa, la distribuzione deve inoltre rispettare:

- target per riga variabili, indicativamente 4–6, senza rendere il totale della
  riga una seconda regola;
- target distribuiti in modo approssimativamente uniforme fra colonne e
  quadranti;
- non più di tre target o tre distrattori consecutivi lungo il percorso;
- nessun distrattore identico in celle orizzontalmente adiacenti e non più di
  due target consecutivi. Con sei target in una riga di dieci celle, almeno
  una coppia di target adiacenti è combinatorialmente inevitabile;
- nessun cluster o diagonale che riveli il target senza identificarne le
  caratteristiche;
- ciascun tipo di distrattore distribuito lungo tutto il foglio, non confinato
  a righe o zone specifiche.

Questi vincoli evitano strategie basate sulla posizione. Non costituiscono una
progressione di difficoltà e non devono produrre un pattern periodico.

## Identità delle celle e sorgente futura

Ogni cella deve avere un identificatore stabile `SS-Rrr-Ccc`, per esempio
`SS-R03-C07`. Il futuro CSV degli stimoli avrà almeno:

```text
stimulus_id,row,column,token,is_target,status
```

Le 200 righe descriveranno il foglio e la chiave, non un record di risposta
item-level. La somministrazione e lo scoring restano aggregati tramite
`score_fixed_time_record()`: non si devono creare 200 risposte fittizie per
adattare SS a `score_subtest_record()`.

## Layout candidato

La matrice scored candidata è **A4 verticale, 20 righe × 10 colonne**. È
deliberatamente diversa dal foglio A4 orizzontale a quattro colonne di CL:
SS richiede una scansione continua di singoli simboli, non confronti per riga.

Vincoli iniziali del layout:

- margini stampabili di almeno 12 mm;
- matrice centrata, larga circa 160 mm;
- passo orizzontale candidato di 16 mm;
- passo verticale candidato di 10–11 mm;
- simboli con estensione esterna candidata di 5–6 mm;
- numero di riga piccolo sul margine sinistro;
- guide orizzontali molto leggere, senza box attorno alle singole celle;
- nessuna alternanza di colore o riempimento fra righe;
- target campione e consegna separati chiaramente dalla matrice scored;
- barra fisica da 50 mm e dicitura “stampa 100%” nei prototipi.

Il percorso è da sinistra a destra nella riga 1, poi ritorno al margine sinistro
della riga 2 e così via fino alla riga 20. Non si usa un percorso a serpentina.
Numeri di riga e guide devono prevenire salti senza trasformare la prova in un
compito di inseguimento di linee.

## Prova guidata

`n_practice_items: 1` viene interpretato come **un unico blocco di pratica**,
non come una singola cella. Il candidato per il prototipo contiene 12 celle:

- 6 target e 6 distrattori;
- tutti i cinque tipi di distrattore almeno una volta;
- la stessa dimensione, spaziatura e modalità di marcatura della matrice;
- feedback immediato, con correzione di omissioni e falsi allarmi;
- conferma esplicita che il target resta visibile durante la prova.

La durata legacy di 15–20 secondi è una stima per la prova guidata, non un
criterio di punteggio. Se la regola non è compresa, si ripete la spiegazione e
si usa un nuovo esempio non scored prima di iniziare; non si insegna una
strategia di scansione diversa da quella prescritta.

## Tempo e procedura

La spec dichiara `planned_minutes: [2, 3]`, non `fixed_minutes`. Di conseguenza:

- il prototipo non decide se il tempo finale sarà 2, 2,5 o 3 minuti;
- uno scostamento dal piano produce al massimo un warning procedurale;
- il punteggio non riceve bonus o penalità ulteriori per il tempo individuale;
- il tempo effettivo va sempre registrato;
- una futura scelta di limite fisso richiede modifica della spec e revisione
  degli output derivati, non una nota nascosta nel foglio.

Il comando di inizio e fine deve essere unico. Durante la matrice non si
correggono errori e non si ricorda la regola, salvo un richiamo neutro a
continuare in ordine quando la persona si ferma per una ragione procedurale.

## Scoring e controllabilità manuale

Per ogni cella:

- target marcato → `hit`;
- target non marcato → `omission`;
- distrattore marcato → `false_alarm`;
- distrattore non marcato → nessun conteggio.

Il punteggio principale resta `max(0, hits - false_alarms)`. Hit, omissioni e
falsi allarmi vanno riportati separatamente. Il futuro foglio di correzione
deve permettere il conteggio con una sovrapposizione o una chiave per coordinate
senza affidarsi alla memoria dell'esaminatore.

La composizione formalizzata impone anche che `hits + omissions` non superi il
numero di target. Il packet N1 ha dichiarato il vincolo nella spec
(`max_from: stimulus_composition.target_count`); scorer e checker dei record lo
applicano senza ricopiare il valore 100.

## Piano del primo prototipo

Il packet successivo non deve generare 200 stimoli. Deve produrre:

1. le sei primitive SVG del vocabolario;
2. il blocco di pratica da 12 celle;
3. una matrice non definitiva di **6 righe × 10 colonne** collocata nel reticolo
   A4 verticale a scala finale;
4. 30 target e 30 distrattori, con 6 occorrenze per ciascun distrattore;
5. conteggi target per riga `4, 6, 5, 4, 6, 5`, in un ordine non segnalato alla
   persona;
6. sorgente CSV separata dalla chiave/conteggi derivati;
7. SVG e PNG a 300 dpi, senza riempire le altre 14 righe con stimoli fittizi.

Il prototipo serve a confrontare salienza, spaziatura, percorso e marcabilità.
Non viene somministrato a tempo per stimare prestazioni e non autorizza la forma
completa.

## Criteri osservabili per il review gate

Il prototipo può avanzare soltanto se l'ispezione a scala di stampa conferma:

- tutte e sole le sei primitive dichiarate sono presenti;
- contorni e linee interne restano distinguibili senza ingrandimento;
- il target non è più grande, più scuro o più isolato dei distrattori;
- `circle_horizontal`, `square_vertical` e `triangle_vertical` sono abbastanza
  simili da richiedere la regola, ma non ambigui;
- la barra a matita è distinguibile dalla linea interna stampata;
- la scansione di una riga non invade quella sopra o sotto;
- ritorno a sinistra e numeri di riga sono inequivocabili;
- nessun pattern di posizioni o tipo di distrattore rivela i target;
- conteggi automatici e conteggio manuale dalla chiave coincidono;
- una ristampa al 100% conserva la barra da 50 mm.

Un fallimento di salienza o marcabilità richiede revisione delle primitive o
del layout, non l'espansione della matrice.

## Rischi di resa e contaminazione

- **Pop-out del target:** un cerchio o la linea verticale possono risultare più
  salienti della combinazione; va giudicato nel campo completo.
- **Triangolo dominante:** vertici e area d'inchiostro possono renderlo più
  riconoscibile dei contorni curvi o quadrati.
- **Densità troppo bassa:** spazi eccessivi trasformano la ricerca in una serie
  di decisioni isolate e riducono la componente di scanning.
- **Densità troppo alta:** linee e contorni si fondono e contaminano il compito
  con acuità visiva o crowding.
- **Marcatura ambigua:** una barra troppo corta può sembrare una linea interna;
  una barra troppo lunga può invadere la cella vicina.
- **Strategia spaziale:** distribuzioni regolari dei target consentono di
  anticipare la posizione senza applicare la regola.
- **Carico grafomotorio:** 100 marcature possibili rendono motricità e uso della
  matita una fonte di varianza da registrare e discutere.
- **Direzione di lettura:** familiarità con la scansione sinistra-destra può
  influire sul punteggio e va annotata in un futuro pilot.
- **Correzione manuale:** senza coordinate e overlay affidabile, falsi allarmi
  e omissioni possono essere conteggiati in modo incoerente.

## Punti aperti

- La dimensione esatta dei simboli, il passo verticale e il peso delle guide
  devono essere scelti dal rendering del prototipo, non fissati in astratto.
- La marcatura con barra obliqua richiede una prova fisica a matita; in caso di
  ambiguità si confronta una breve sottolineatura, senza cambiare la regola.
- La durata finale resta pianificata in 2–3 minuti. Serve un pilot prima di
  scegliere un eventuale `fixed_minutes`.
- Il 50% di target deriva dalla struttura v0, non da dati empirici; prevalenza
  e penalità dei falsi allarmi andranno rivalutate insieme, non separatamente.
- Prima dell'integrazione va definita una procedura semplice per correggere una
  marcatura accidentale senza renderla indistinguibile da un falso allarme.
- Il vincolo è `hits + omissions <= target_count`, non un'uguaglianza. Se la
  procedura finale conterà come omissione ogni target non marcato, compresi
  quelli non raggiunti allo scadere del tempo, la somma dovrà essere esattamente
  il numero di target: è una decisione di correzione da prendere con il foglio
  di correzione, non in N1.
- Un rendering in un secondo ambiente resta necessario prima del freeze della
  forma per verificare la portabilità di testo e primitive.
