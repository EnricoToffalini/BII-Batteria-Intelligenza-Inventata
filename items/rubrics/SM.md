# SM — istruzioni e chiavi

SM è organizzato in **tre microblocchi**, ciascuno con un compito diverso e
**sei livelli di lunghezza** (2–7 cifre), **due prove per livello**: 36 item
scored più tre item di prova (uno per microblocco). Ogni microblocco si
somministra e si valuta **per intero e in modo indipendente**: ha il suo punto
di partenza, il suo basale e il suo ceiling, come se fosse un piccolo subtest a
sé, prima di passare al successivo.

I tre microblocchi, nell'ordine di somministrazione:

1. **Ripetizione a ritroso** (`backward_repetition`) — richiamo di una
   sequenza nell'ordine inverso;
2. **Riordino per regola** (`rule_based_reordering`) — richiamo della stessa
   sequenza dal numero più piccolo al più grande;
3. **Span aggiornato** (`running_span`) — richiamo solo delle ultime cifre
   dette, scartando quelle più vecchie.

## Materiale

Nessuno oltre alla voce: SM è interamente uditivo-verbale. Serve solo un
ambiente silenzioso.

## Istruzione generale

> Adesso ti dico dei numeri. Ascolta bene, perché dopo dovrai ripeterli in un
> modo particolare che ti spiego ogni volta.

Dire ogni cifra **a ritmo costante, circa una al secondo**, senza raggruppare le
cifre e senza cambiare intonazione. Non ripetere una sequenza già letta, tranne
negli item di prova. Non scrivere né mostrare i numeri: la prova è solo orale.

Prima di iniziare **ogni microblocco**, dare l'istruzione specifica e
somministrare il relativo item di prova.

## 1. Ripetizione a ritroso

> Ti dico dei numeri. Tu li ripeti al contrario, cioè a partire dall'ultimo.
> Per esempio, se dico «uno, nove», tu dici «nove, uno».

Item di prova: **SM-PR-01** — presentato `1 9`, risposta corretta `9 1`. Se la
persona sbaglia, mostrare la risposta corretta e rifare l'esempio una volta.

### Ripetizione a ritroso — chiave

| Livello | Item | Presentato | Risposta |
|---|---|---|---|
| 2 | SM-SC-01 | 6 9 | 9 6 |
| 2 | SM-SC-02 | 8 5 | 5 8 |
| 3 | SM-SC-03 | 5 4 7 | 7 4 5 |
| 3 | SM-SC-04 | 2 9 6 | 6 9 2 |
| 4 | SM-SC-05 | 7 3 1 6 | 6 1 3 7 |
| 4 | SM-SC-06 | 5 6 1 8 | 8 1 6 5 |
| 5 | SM-SC-07 | 5 1 7 6 3 | 3 6 7 1 5 |
| 5 | SM-SC-08 | 8 7 2 6 5 | 5 6 2 7 8 |
| 6 | SM-SC-09 | 6 8 5 2 1 3 | 3 1 2 5 8 6 |
| 6 | SM-SC-10 | 4 8 9 1 5 7 | 7 5 1 9 8 4 |
| 7 | SM-SC-11 | 7 6 8 2 5 4 9 | 9 4 5 2 8 6 7 |
| 7 | SM-SC-12 | 3 7 2 1 8 5 4 | 4 5 8 1 2 7 3 |

## 2. Riordino per regola

> Adesso ti dico altri numeri, ma tu li devi dire **dal più piccolo al più
> grande**, non nell'ordine in cui li senti. Per esempio, se dico «otto, tre»,
> tu dici «tre, otto».

Item di prova: **SM-PR-02** — presentato `8 3`, risposta corretta `3 8`. Se la
persona sbaglia, mostrare la risposta corretta e rifare l'esempio una volta.

> A livello 2 l'ordinamento crescente coincide sempre con «leggere al
> contrario» il presentato: con solo due cifre non esiste una terza
> disposizione possibile. Non è un errore di costruzione — è una proprietà
> matematica del livello più basso — ma va tenuto a mente: dal livello 3 in su
> le due cose smettono di coincidere.

### Riordino per regola — chiave

| Livello | Item | Presentato | Risposta |
|---|---|---|---|
| 2 | SM-SC-13 | 5 1 | 1 5 |
| 2 | SM-SC-14 | 7 4 | 4 7 |
| 3 | SM-SC-15 | 7 5 9 | 5 7 9 |
| 3 | SM-SC-16 | 3 6 2 | 2 3 6 |
| 4 | SM-SC-17 | 2 7 6 4 | 2 4 6 7 |
| 4 | SM-SC-18 | 3 9 6 4 | 3 4 6 9 |
| 5 | SM-SC-19 | 3 1 5 9 4 | 1 3 4 5 9 |
| 5 | SM-SC-20 | 8 3 1 7 4 | 1 3 4 7 8 |
| 6 | SM-SC-21 | 8 9 3 6 1 4 | 1 3 4 6 8 9 |
| 6 | SM-SC-22 | 4 2 7 9 5 6 | 2 4 5 6 7 9 |
| 7 | SM-SC-23 | 3 6 4 1 9 2 8 | 1 2 3 4 6 8 9 |
| 7 | SM-SC-24 | 1 4 5 9 7 6 2 | 1 2 4 5 6 7 9 |

> Le sequenze effettive sono generate da `R/build/build_sm_items.R` con seed
> fisso: se questa tabella e `items/source/SM.csv` divergono, vale il CSV.
> Aggiornare questa tabella dopo qualunque rigenerazione o modifica manuale.

## 3. Span aggiornato

> Adesso ti dico una lista di numeri, più lunga delle altre. Tu devi dirmi
> **solo gli ultimi** che ho detto, non tutti. Ti dico io quanti devi ricordare
> prima di cominciare.

Item di prova: **SM-PR-03** — dire «Adesso dimmi solo gli ultimi 2 numeri»,
presentato `9 1 8 3 2`, risposta corretta `3 2`. Se la persona sbaglia, mostrare
la risposta corretta e rifare l'esempio una volta.

Dichiarare **prima di ogni item** quante cifre finali si chiederanno: non è
un'informazione da indovinare, è la consegna del compito.

### Span aggiornato — chiave

| Livello (ultime cifre richieste) | Item | Presentato (intera lista) | Risposta |
|---|---|---|---|
| 2 | SM-SC-25 | 1 3 6 8 5 | 8 5 |
| 2 | SM-SC-26 | 7 3 2 5 1 | 5 1 |
| 3 | SM-SC-27 | 4 3 7 5 2 8 | 5 2 8 |
| 3 | SM-SC-28 | 4 2 5 9 3 7 | 9 3 7 |
| 4 | SM-SC-29 | 3 9 1 8 7 2 6 | 8 7 2 6 |
| 4 | SM-SC-30 | 3 9 8 6 7 5 2 | 6 7 5 2 |
| 5 | SM-SC-31 | 8 1 4 2 9 5 7 6 | 2 9 5 7 6 |
| 5 | SM-SC-32 | 7 1 4 6 8 9 5 2 | 6 8 9 5 2 |
| 6 | SM-SC-33 | 7 3 4 1 9 6 5 8 2 | 1 9 6 5 8 2 |
| 6 | SM-SC-34 | 6 9 3 1 7 4 2 8 5 | 1 7 4 2 8 5 |
| 7 | SM-SC-35 | 5 4 8 7 2 7 2 9 8 4 | 7 2 7 2 9 8 4 |
| 7 | SM-SC-36 | 4 5 1 3 8 1 6 8 1 2 | 3 8 1 6 8 1 2 |

## Punteggio

Ogni prova vale **1 punto se la risposta è esattamente quella richiesta**, nello
stesso ordine, senza omissioni né aggiunte. Vale 0 per qualunque discrepanza,
anche di una sola cifra o di una sola posizione. Non esistono punteggi parziali.
Range grezzo 0–36 (12 punti per microblocco).

## Somministrazione per livelli, indipendente per microblocco

Le regole sono le stesse di PG, applicate **separatamente a ciascun
microblocco**:

- si parte dal livello indicato dall'età (vedi manuale) e si somministrano
  entrambe le prove;
- **entrambe corrette** → i livelli più bassi *di quel microblocco* ricevono 1
  punto ciascuno senza essere somministrati, e si sale;
- **entrambe sbagliate** → si scende di un livello alla volta fino al basale;
  i livelli sotto ricevono 1 punto ciascuno;
- **una corretta e una sbagliata** → non si scende: si sale, e i livelli più
  bassi ricevono comunque credito pieno;
- **entrambe sbagliate salendo** → interruzione *di quel microblocco*; i suoi
  livelli successivi ricevono 0.

Poi si passa al microblocco seguente e la procedura ricomincia da capo, con
il proprio punto di partenza, il proprio basale e il proprio ceiling.

## Perché tre compiti diversi nello stesso subtest

I tre microblocchi condividono il materiale (cifre) ma richiedono operazioni
diverse sulla sequenza mantenuta in memoria: invertire l'ordine, riordinarla
secondo un criterio esterno, aggiornarla continuamente scartando le informazioni
più vecchie. È la manipolazione, non la lunghezza, il costrutto che li
differenzia — per questo lo scoring resta lo stesso (1 punto per prova
riprodotta esattamente) e cambia solo l'operazione richiesta.

## Limiti dichiarati

Ai livelli 2 le tre operazioni si sovrappongono parzialmente: con solo due
cifre, «al contrario» e «dal più piccolo al più grande» spesso producono la
stessa risposta per motivi combinatori, non perché le due abilità coincidano.
La discriminazione reale del riordino comincia dal livello 3.

La stessa scala progettuale di difficoltà (`difficulty_target`, da -3.0 a +3.0
in sei passi) è usata per tutti e tre i microblocchi. È un'assunzione dichiarata
e non verificata: non è garantito che il livello 5 di riordino sia altrettanto
difficile del livello 5 di span aggiornato. Va confrontato nel pilot.

La velocità di presentazione («circa una cifra al secondo») dipende
dall'esaminatore e non è strumentata: è il limite procedurale principale, come
per PG.
