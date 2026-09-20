# 0004 — Ordine di sviluppo degli item e capacità di produzione degli stimoli

- Stato: accettata
- Data: 2026-09-12
- Si appoggia a: [0003](0003-generic-administration-engine.md)

## Contesto

La roadmap prevedeva di costruire gli item subtest per subtest, con una
preferenza per stimoli vettoriali deterministici dove serve grafica. Nella
pratica è emerso un vincolo che la roadmap non nominava: **chi sviluppa può
avere capacità diverse dalle capacità richieste dal subtest**.

Un agente che genera testo in modo affidabile e figure in modo inaffidabile, se
deve «completare MR», produce una delle tre cose sbagliate: item descritti in
prosa invece di disegnati, ASCII art, oppure segnaposto da sostituire dopo. Tutte
e tre fanno sparire il problema dalla vista: il subtest risulta «fatto» nei
conteggi, nei test e nel manuale, e nessuno sa più che i suoi stimoli non
esistono.

## Decisione

### 1. `stimulus_production` come campo della spec

Ogni subtest dichiara la capacità che i suoi stimoli richiedono. Il vocabolario
è in `spec/battery.yml` e il validator lo verifica:

| Valore | Significato | Subtest |
|---|---|---|
| `text_only` | testo o parlato, nessun materiale grafico | SP, RS, CS, QS, SM, CR |
| `symbol_text` | sequenze di simboli componibili come testo | RR |
| `symbol_grid` | griglie o matrici di caratteri stampabili | CL, SS, PG |
| `vector_geometry` | figure geometriche deterministiche, SVG da sorgente | MR, RP, MP, DM |
| `manipulative` | oggetti fisici oltre a un riferimento stampabile | MO |

### 2. L'ordine di sviluppo segue la capacità, non l'ordine dei subtest

Si costruiscono prima i subtest che si possono costruire fedelmente. Un item
bank vuoto è uno stato onesto e visibile; un item bank finto non lo è.

La regola operativa è in AGENTS.md: non popolare un item bank la cui
`stimulus_production` non si è in grado di produrre, e dichiarare nel riassunto
quali subtest si sono lasciati intatti e perché.

### 3. `stimulus_production` non è una scorciatoia

Si può cambiare la `stimulus_production` di un subtest, ma solo come decisione
psicometrica motivata, non per far entrare il subtest negli strumenti
disponibili. MR, MO e RP sono figurali per ragioni di costrutto e non vanno
riformulati come testo: se lo fossero, il dominio Gv e la componente figurale di
Gf sparirebbero dalla batteria mantenendo i loro nomi.

## Il caso RR, e perché è diverso

RR era `mixed_verbal_visual` con `multiple_choice_4_to_6`. È diventato
`symbol_text` con `multiple_choice_4`, e le sue sequenze usano sei simboli
geometrici dichiarati in `symbol_vocabulary`.

Non è un adattamento agli strumenti disponibili, per tre ragioni:

1. **il costrutto non cambia.** RR misura l'applicazione di regole esplicite e
   l'integrazione di vincoli. Serie, trasformazioni, vincoli d'ordine,
   condizionali e induzione di regole sono forme classiche di ragionamento
   fluido e non richiedono disegni.
2. **la contaminazione diminuisce.** Un RR in prosa correlerebbe con SP e RS
   più che con MR, spostando qIF verso Gc. I simboli tengono il carico verbale
   confinato alla consegna.
3. **MR resta figurale.** RR non sostituisce MR e non ne anticipa il contenuto:
   la componente figurale di Gf resta da costruire, con `vector_geometry`.

Il numero fisso di quattro alternative sostituisce il precedente 4–6 per
mantenere omogeneo il tasso di risposta casuale fra gli item e per non dover
rappresentare un numero variabile di opzioni nello schema dell'item bank.

## Difetti della spec corretti insieme a questa decisione

Trovati leggendo le spec dei subtest ancora da costruire.

**Regola di ceiling impossibile in SM e PG.** Entrambi dichiaravano `ceiling:
{consecutive_errors: 3, same_level: true}` senza dichiarare quante prove
contenga un livello. Con due prove per livello la condizione non è mai
soddisfacibile e la somministrazione non si fermerebbe mai. Aggiunto
`trials_per_level: 2` e portato il criterio a 2 errori consecutivi, cioè
entrambe le prove del livello sbagliate, che è la pratica corrente. Il validator
ora rifiuta qualunque regola «sullo stesso livello» che richieda più prove di
quante il livello ne contenga.

**Copertura dei livelli di SM.** Resta aperto un problema più grande, non
risolto qui: con 24 item su tre microblocchi restano 8 item per microblocco,
cioè 4 livelli di lunghezza. Un diciassettenne parte dal livello 4 e, superandolo
insieme al 5, arriva al massimo del microblocco. Chiunque abbia uno span
all'indietro di 5 o più otterrebbe il punteggio pieno, con un effetto di
soffitto su tutta la fascia 13–21. La correzione richiede di portare SM a 6
livelli per microblocco, cioè 36 item e `raw_max` 36, e va fatta contestualmente
alla costruzione del subtest perché comporta la rigenerazione delle norme
simulate. Registrato nella roadmap alla fase 3.

**Standardizzazione di QS.** `stimulus_mode` prometteva un «simple visual
support» mai definito. Sostituito con `verbal_with_scratch_paper` e due campi
espliciti (`scratch_paper_allowed: true`, `calculator_allowed: false`). Il foglio
è ammesso di proposito: senza foglio un problema a due passaggi misurerebbe
anche la memoria di lavoro, che nella BII ha già due subtest propri.

## Conseguenze

- Cinque subtest hanno una forma completa in bozza: SP, RS, RR, CS, QS. Tre su
  quattro componenti del QI rapido, e tre su nove del QI totale.
- Il QI totale non è ancora calcolabile: mancano MR, MO, RP (figurali), SM, CL,
  CR.
- `tests/test_consistency.R` richiede ora, per ogni item bank, anche il piano di
  progettazione con i punti aperti dichiarati.
- I controlli di qualità comuni ai banchi a scelta multipla stanno in
  `tests/test_multiple_choice_banks.R` e si applicano da soli a ogni nuovo
  item bank a scelta multipla.

## Alternative scartate

**Generare comunque gli item visivi come descrizioni testuali da illustrare
dopo.** Sembra un avanzamento e non lo è: il debito diventa invisibile e il
conteggio dei subtest «pronti» mente. Scartata.

**Rendere testuali tutti i subtest costruibili come testo, MR compreso.** Avrebbe
portato rapidamente a quindici subtest «completi», eliminando però il dominio Gv
e la componente figurale di Gf. Sarebbe stata una batteria diversa con i nomi di
questa. Scartata.
