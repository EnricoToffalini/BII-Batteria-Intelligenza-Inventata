# MR — brief di progettazione e piano del prototipo

MR misura il ragionamento induttivo non verbale su regole implicite. È un
subtest `core` di Gf, contribuisce a qIF, QI rapido e QI totale e deve quindi
restare distinto sia dal ragionamento su regole esplicite di RR sia dalle prove
visuo-spaziali di qVS.

Questo documento chiude il gate G1. Non crea item scored, non approva una banca
da 24 item e non modifica conteggi, punti di partenza, basal, ceiling o timing.
La BII resta una batteria didattica con norme simulate, non uno strumento
clinico o diagnostico.

## Confine del costrutto

La persona osserva una matrice incompleta, induce la relazione che organizza
le celle e sceglie fra cinque alternative l'unica che completa lo schema. Il
carico principale deve essere:

- individuare una regola non dichiarata;
- distinguere attributi rilevanti da attributi costanti;
- integrare fino a tre relazioni indipendenti negli item più avanzati;
- generalizzare la relazione alla cella mancante.

MR non deve diventare principalmente:

- una prova di rotazione mentale o visualizzazione tridimensionale;
- un esercizio di conteggio scolastico o calcolo scritto;
- un compito di memoria, perché matrice e alternative restano visibili;
- una ricerca percettiva a tempo;
- una variante figurale di RR con la regola spiegata nella consegna;
- un test di familiarità con un unico tipo di matrice ripetuto 24 volte.

La rotazione è ammessa soltanto come attributo semplice e controllato (90° o
180°), mai in prospettiva e mai come unica ragione della difficoltà di un item.

## Formato comune

La spec richiede 24 item scored, due prove e cinque alternative. Le prove
mantengono la scelta legacy: una matrice 2×2 e una 3×3, entrambe con feedback.
Dopo le prove non si nominano le regole e non si confermano strategie.

Per gli item scored:

- matrici 2×2 per le relazioni singole iniziali;
- matrici 3×3 quando servono due assi o una combinazione di relazioni;
- una sola cella mancante, segnalata nello stesso modo in tutta la forma;
- alternative A–E sempre nello stesso reticolo e con uguale area disponibile;
- figure nere su fondo bianco, senza colore, texture raster o ombreggiatura;
- nessun testo, numero o glifo di font dentro le celle scored;
- matrice e alternative visibili contemporaneamente.

La posizione della cella mancante può variare negli item avanzati, ma il primo
prototipo userà sempre l'angolo in basso a destra. Variare subito la posizione
confonderebbe il test della famiglia con un cambiamento di layout.

## Grammatica vettoriale minima

Le figure saranno costruite da primitive SVG, non da font:

- contorni: cerchio, quadrato, triangolo;
- segmenti interni: verticale, orizzontale e diagonale;
- punti pieni;
- posizioni su una griglia di ancoraggio 3×3 interna alla cella;
- stato di riempimento `empty`/`filled` quando sostanzialmente necessario;
- rotazione discreta soltanto per primitive asimmetriche.

Ogni componente ha coordinate, dimensione, stroke e ordine dei layer
espliciti. Le celle della matrice condividono bounding box e margini; le cinque
alternative condividono un secondo bounding box comune. Un elemento non può
cambiare dimensione o spessore per indicare implicitamente la risposta.

Valori iniziali da verificare nel prototipo, non ancora standard definitivi:

- cella della matrice: 28–32 mm;
- area utile interna: almeno 20 mm;
- stroke principale: 0,40–0,55 mm;
- distanza minima fra componenti: 1,5 mm;
- distanza visiva netta fra matrice e alternative;
- barra fisica da 50 mm sul foglio di review.

Le etichette A–E possono usare un font di sistema perché non sono stimoli. La
geometria scored deve restare identica anche se quel font viene sostituito.

## Famiglie candidate

### 1. Trasformazione di un attributo

Formato prevalente 2×2. La relazione fra le celle della prima riga viene
applicata alla seconda: aggiungere o togliere un componente, cambiare
riempimento, sostituire una forma mantenendo gli altri attributi. Una sola
operazione nei primi item; due operazioni compatibili soltanto più avanti.

Rischio principale: ridursi ad analogia percettiva immediata. La difficoltà non
va aumentata rendendo le forme piccole o affollate.

### 2. Combinazione di insiemi di tratti

Formato 3×3. La terza cella di una riga o colonna deriva dalle prime due
mediante unione, intersezione, differenza o XOR di componenti collocati su
ancore fisse. Le operazioni non sono mescolate nello stesso item iniziale.

Questa famiglia è il candidato per il primo prototipo G3 perché esercita
geometria, layer e distrattori senza dipendere da rotazioni o abilità Gv.

### 3. Progressione controllata

Formato 3×3. Un attributo ordinato cambia per passi visibili: numero di punti,
numero di segmenti o posizione su tre ancore. Non si usano quantità oltre tre
né calcoli simbolici. La progressione deve essere osservabile su più righe o
colonne e non deducibile da una sola coppia.

Rischio principale: trasformare il compito in conteggio. Il numero è un
attributo della regola, non il solo contenuto dell'item.

### 4. Distribuzione di due attributi

Formato 3×3. Forma, riempimento, posizione o orientamento si distribuiscono
indipendentemente fra righe e colonne. Gli item avanzati possono richiedere
l'integrazione di un terzo attributo, purché ciascun asse resti identificabile.

Rischio principale: familiarità con quadrati latini. Questa famiglia non deve
dominare la forma e non deve usare sempre la stessa permutazione.

## Progressione progettuale

La progressione resta ipotetica finché i prototipi non sono revisionati:

| Posizioni | Struttura prevalente | Carico progettuale |
|---|---|---|
| 1–4 | 2×2, una trasformazione | una relazione, un attributo variabile |
| 5–8 | 2×2 o 3×3 semplice | una relazione con distrattori più vicini |
| 9–16 | 3×3 | due attributi o due assi indipendenti |
| 17–24 | 3×3 | due operazioni in sequenza o tre attributi controllati |

Gli item 5 e 9 coincidono con punti di partenza per fasce d'età. Non devono
introdurre un formato mai mostrato nelle prove o una famiglia eccezionale. La
difficoltà deve comunque crescere nel complesso: non si inseriscono item
artificialmente facili soltanto per giustificare gli start point. Se il pilot
mostra che gli start point non sono sostenibili, si modifica prima la spec e
si rigenerano i derivati.

La ripartizione finale delle 24 posizioni fra famiglie non è fissata in G1. Un
conteggio deciso prima dei prototipi darebbe una precisione fittizia.

## Distrattori e risposta unica

Ogni item deve essere definito prima come regola e stati delle celle, poi
renderizzato. La risposta corretta non viene scelta a occhio dal disegno.

Le cinque alternative devono essere uniche e includere, quando applicabile:

- applicazione parziale della regola;
- applicazione della regola sull'asse sbagliato;
- operazione inversa;
- perseverazione dell'ultima cella osservata;
- combinazione corretta con un solo attributo errato.

Prima del rendering definitivo, un controllo deve verificare che:

1. la regola parametrizzata genera una sola risposta;
2. una sola delle cinque alternative coincide con quella risposta;
3. nessun distrattore duplicato differisce soltanto nell'ordine dei layer;
4. ogni distrattore ha un rationale dichiarato;
5. nessun'altra regola ammessa nella grammatica della famiglia spiega tutte le
   celle osservate e rende corretto un distrattore.

L'ultimo controllo è essenziale: una chiave unica nel file non dimostra che la
matrice abbia una sola soluzione psicologicamente plausibile.

Nella forma completa la posizione corretta A–E deve essere bilanciata e non
seguire pattern riconoscibili. Il bilanciamento non si forza nel micro-
prototipo se peggiora i distrattori.

## Sorgenti e ID

I futuri item useranno ID stabili `MR-PR-01`/`MR-PR-02` per le prove e
`MR-SC-01`–`MR-SC-24` per gli scored. Il CSV dell'item bank conterrà metadati,
chiave, famiglia, difficoltà e riferimenti agli asset; non conterrà SVG opaco
incollato in una cella.

La geometria del prototipo sarà descritta in una tabella semplice separata
dalla chiave, con almeno:

```text
prototype_id,panel,row,column,layer,primitive,anchor,fill,rotation,status
```

`panel` distingue matrice e alternative. Il generatore deriva l'SVG da questa
tabella e da parametri di layout espliciti. La chiave e i rationale dei
distrattori vivono in un secondo file. Questa separazione permette di cambiare
stroke o spaziatura senza riscrivere la logica dell'item.

## Piano del primo prototipo G3

Il packet successivo deve produrre **quattro** item non definitivi della sola
famiglia `set_combination`:

- matrici 3×3 con cella mancante in basso a destra;
- una sola operazione per item, scelta fra unione, intersezione, differenza e
  XOR;
- componenti su ancore fisse, senza rotazioni e senza riempimenti decorativi;
- cinque alternative con rationale esplicito;
- sorgente geometrica e chiave separate;
- quattro tavole A4 di review, una per prototipo, con barra da 50 mm; una
  tavola unica ridurrebbe le celle sotto i 28-32 mm da verificare;
- SVG e PNG a 300 dpi, più controlli automatici della risposta unica dove la
  grammatica finita lo consente.

I quattro prototipi non sono item 1–4 e non autorizzano la famiglia intera. Il
review gate successivo deciderà se la combinazione di tratti è leggibile,
induttiva e sufficientemente distinta da un semplice confronto percettivo.

## Criteri del review gate

- regola ricostruibile senza spiegazione verbale aggiuntiva;
- una sola risposta plausibile sotto la grammatica dichiarata;
- alternative distinguibili ma non identificabili da dimensione o densità;
- nessun clipping, contatto involontario o variazione di stroke;
- matrice leggibile alla scala prevista senza zoom;
- assenza di dipendenza da colore, font o conoscenze scolastiche;
- nessun vantaggio sistematico dalla sola rotazione mentale;
- rationale dei quattro distrattori coerente con ciò che è disegnato;
- corrispondenza completa fra sorgente, chiave e rendering;
- barra da 50 mm corretta nella stampa al 100% prima di espandere.

## Punti aperti

- La dimensione finale delle celle e lo stroke vanno scelti dal prototipo e da
  una stampa fisica, non dalla sola anteprima digitale.
- Va deciso dopo G3 se la cella mancante debba restare sempre in basso a destra
  o variare negli item avanzati; la variazione non deve diventare difficoltà
  irrilevante.
- La grammatica delle regole ammesse deve restare abbastanza piccola da poter
  cercare spiegazioni alternative, ma non tanto piccola da rendere gli item
  ripetitivi.
- Il peso massimo delle rotazioni nella forma completa non è ancora fissato;
  deve restare minoritario e motivato da Gf, non da copertura di Gv.
- Il layout delle cinque alternative va provato con risposte dalla densità
  molto diversa: slot uguali non garantiscono uguale salienza.
- Due prove possono non bastare per persone poco familiari con le matrici. Un
  eventuale terzo esempio non scored cambierebbe la spec e richiederebbe una
  decisione separata, non va aggiunto silenziosamente.
- Servono revisione umana indipendente e pilot prima di considerare credibile
  l'ordine di difficoltà o gli start point 1/5/9.
