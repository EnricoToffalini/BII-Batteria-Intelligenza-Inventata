# CL — decisione del review gate P3

**Decisione: revisione richiesta.** La famiglia `distinct_substitution` non è
scartata, ma il prototipo P2 non è approvato per l'espansione. P4 resta
bloccato.

## Evidenze esaminate

- sorgente e chiavi dei sei prototipi;
- controlli automatici di `tests/test_cl_prototype.R`;
- SVG e PNG A4/A3 rigenerati senza variazioni di hash;
- ispezione a risoluzione originale dei due fogli;
- dimensioni fisiche dichiarate dal generatore: glifi 4 mm, caselle 3,4 mm,
  righe A4 6,48 mm e righe A3 9,96 mm.

La review è grafica e concettuale, non empirica. Non è stata effettuata una
prova con partecipanti né una stampa fisica compilata a matita.

## Esito per criterio

| Criterio | Esito | Evidenza |
|---|---|---|
| regola unica e risposta determinata | passa | tre coppie identiche; tre con una sola sostituzione verificata |
| vocabolario chiuso | passa | tutti e soli i sei token della spec |
| centratura e separazione dei glifi | passa | nessun contatto o variazione di metrica nei rendering |
| indizi di larghezza o posizione | passa | reticolo identico a sinistra e destra |
| percorso fra righe e colonne | passa | numeri, guide e `CONTINUA` sono leggibili |
| distinzione stimolo-risposta | **non passa** | `□` e casella quadrata hanno forma e dimensione simili |
| portabilità del rendering | **non passa** | lo SVG dipende da Segoe UI Symbol installato localmente |
| formato A4 | condizionale | leggibile a schermo; marcabilità su carta non verificata |
| formato A3 | non preferito | più spazio, ma maggiore distanza stimolo-risposta e stampa meno accessibile |

## Decisioni di design

### 1. Risposta senza contenitore geometrico

La persona barrerà direttamente una `U` o una `D` stampata su ogni riga. Non si
useranno quadrati, cerchi o altri contenitori: un quadrato collide con `□`, un
cerchio con `○`, e sostituire un contenitore con un altro sposterebbe soltanto
il problema. La testata continua a spiegare `U = UGUALE` e `D = DIVERSO`.

Questa modifica non cambia `response_format: binary_marking`, la chiave o lo
scoring aggregato. Riduce invece un indizio percettivo estraneo al confronto
fra stringhe.

### 2. Primitive SVG al posto del font di sistema

I token del CSV restano `○`, `△`, `□`, `◆`, `+`, `★`, come dichiarato nella
spec. Il renderer revisionato deve mapparli uno a uno a primitive SVG con:

- bounding box comune;
- centro comune;
- stroke e riempimento dichiarati;
- una sola definizione per token;
- errore se il CSV contiene un token senza definizione o il renderer definisce
  un token estraneo alla spec.

Questo elimina il fallback tipografico senza trasformare CL in un compito di
geometria: le figure restano caratteri discreti in un reticolo regolare e non
portano relazioni spaziali complesse.

### 3. Solo A4 per la revisione

Il prossimo rendering usa A4 orizzontale, 4 colonne × 25 righe. A3 viene
ritirato dal percorso corrente: non ha mostrato un vantaggio che compensi
distanza oculomotoria e minore disponibilità di stampa. La barra da 50 mm resta
nel prototipo per controllare la scala.

La scelta A4 è ancora condizionata a una stampa al 100% e a una prova di
marcatura; non è un'approvazione della forma completa.

## Modalità di produzione dopo il gate

La famiglia è abbastanza formale per un **generatore con QA automatico**, non
per costruzione manuale item per item. L'espansione dovrà però avvenire per
micro-lotti con review visiva: una generazione automatica non approva da sola
salienza, densità o carico grafomotorio.

P3 non stabilisce ancora la dimensione di P4. Prima serve un prototipo
revisionato che dimostri le nuove convenzioni; soltanto il review gate seguente
potrà autorizzare e dimensionare il primo lotto aggiuntivo.

## Unico packet successivo autorizzato

**P2R — revisione del prototipo CL esistente.** Nessun nuovo stimolo:

1. mantenere i medesimi sei CSV e le medesime chiavi;
2. sostituire i glifi testuali con primitive SVG determinate dai token;
3. sostituire le caselle con `U` e `D` barrabili direttamente;
4. generare soltanto A4 a 300 dpi;
5. aggiungere test sulla corrispondenza completa fra vocabolario e primitive;
6. ispezionare il nuovo rendering e verificare nuovamente gli hash al rebuild.

P4 e l'item bank da 100 elementi restano fuori ambito.
