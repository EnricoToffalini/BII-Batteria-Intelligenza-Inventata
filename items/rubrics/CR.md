# CR — istruzioni e chiavi

Quattordici coppie di parole, presentate **due volte**, con recupero **dopo 15
minuti**. Nessun item si salta e nessuno si aggiunge: l'insieme è fisso.

## La regola procedurale più importante

> **Il richiamo immediato è vietato.** Dopo lo studio non si chiede nulla sulle
> coppie: né «te le ricordi?», né una prova «per vedere come va». Un richiamo
> immediato trasforma CR in una prova di apprendimento con recupero ripetuto e
> rende il punteggio differito non confrontabile con quello di chiunque altro.

Fra studio e recupero si somministrano altri subtest, come previsto dalla
sequenza in `spec/battery.yml`. Se la sequenza si esaurisce prima dei 15 minuti,
si usa il filler `F15_A`.

## Fase 1 — studio

> Ti leggerò delle coppie di parole. Prova a ricordare quali parole vanno
> insieme, perché più tardi te ne chiederò qualcuna. Non devi dirmi niente
> adesso: ascolta e cerca di ricordare.

Leggere le quattordici coppie **nell'ordine della chiave**, una coppia ogni due
secondi circa, con una breve pausa fra le due parole della coppia. Poi fare una
pausa di cinque secondi e **rileggere l'intera lista nello stesso ordine**.

Due presentazioni, non una e non tre. Non si dà feedback, non si ripete una
singola coppia su richiesta e non si dice quante coppie sono.

## Fase 2 — recupero differito, dopo 15 minuti

Annotare il ritardo effettivo in `delay_minutes`. La finestra prevista è
**14–16 minuti**: fuori da quella finestra il punteggio si calcola comunque, ma
lo scorer emette un avviso e il dato va trattato con cautela.

### 2a — richiamo con suggerimento

> Prima ti avevo letto delle coppie di parole. Adesso ti dico la prima parola di
> ogni coppia e tu mi dici l'altra.

Per ogni item si legge **soltanto il cue** e si attende circa dieci secondi.

- risposta corretta → `recall = correct`, **si passa all'item successivo**: il
  riconoscimento non si somministra;
- risposta sbagliata → `recall = incorrect`;
- nessuna risposta entro dieci secondi → `recall = omitted`.

Non si dà feedback e non si dice se la risposta era giusta. Non si torna su un
item già passato.

### 2b — riconoscimento, solo dopo un richiamo non riuscito

Per gli item con `recall` diverso da `correct`, e **solo per quelli**:

> Adesso te la dico io fra quattro parole. Quale andava con «[cue]»?

Leggere le quattro opzioni nell'ordine della chiave. Registrare `recognition =
correct` o `incorrect`. Per gli item già recuperati si registra `recognition =
not_administered`.

> Se il richiamo non è riuscito e il riconoscimento non viene somministrato, lo
> scorer **rifiuta** di calcolare il punteggio di quell'item invece di
> assegnargli zero: una componente mancante non è una risposta sbagliata.

## Punteggio

Non si scrive un punteggio di item: si registrano le due componenti e il
punteggio viene derivato.

| `recall` | `recognition` | Punteggio |
|---|---|---|
| `correct` | `not_administered` | **2** |
| `incorrect` o `omitted` | `correct` | **1** |
| `incorrect` o `omitted` | `incorrect` | **0** |

Range grezzo 0–28. La logica è nella spec (`scoring.rubric`), non nel codice.

## Chiave rapida

Le coppie vanno lette in questo ordine in entrambe le presentazioni.

| Ordine | Item | Coppia | Riconoscimento | Risposta |
|---|---|---|---|---|
| 1 | CR-SC-01 | luna … **sedia** | poltrona / sedia / barca / cucchiaio | B |
| 2 | CR-SC-02 | cane … **bottone** | bottone / cintura / chiave / lampada | A |
| 3 | CR-SC-03 | fiume … **violino** | chitarra / barca / violino / mela | C |
| 4 | CR-SC-04 | pane … **chiave** | serratura / martello / cucchiaio / chiave | D |
| 5 | CR-SC-05 | nuvola … **martello** | martello / tenaglia / pesce / sedia | A |
| 6 | CR-SC-06 | scarpa … **mela** | pera / mela / barca / bottone | B |
| 7 | CR-SC-07 | finestra … **pesce** | rana / lampada / pesce / violino | C |
| 8 | CR-SC-08 | libro … **cucchiaio** | cucchiaio / mestolo / chiave / pesce | A |
| 9 | CR-SC-09 | albero … **lampada** | torcia / mela / sedia / lampada | D |
| 10 | CR-SC-10 | mano … **barca** | barca / zattera / martello / mela | A |
| 11 | CR-SC-11 | ponte … **guanto** | sciarpa / guanto / tamburo / chiave | B |
| 12 | CR-SC-12 | neve … **tamburo** | flauto / sedia / tamburo / barca | C |
| 13 | CR-SC-13 | sasso … **candela** | fiammifero / bottone / cucchiaio / candela | D |
| 14 | CR-SC-14 | gatto … **forchetta** | forchetta / coltello / lampada / pesce | A |

## Risposte da accettare e da non accettare

- **sinonimo o variante morfologica del bersaglio**: si accetta se identifica la
  stessa parola («le scarpe» per «scarpa», «la barca» per «barca»).
- **parola dello stesso ambito ma diversa**: non si accetta («tavolo» per
  «sedia» è `incorrect`).
- **bersaglio di un'altra coppia**: non si accetta e **va annotato in `notes`**.
  È un errore informativo: indica che la lista è stata appresa ma
  l'associazione no.
- **più parole**: si chiede una volta «Quale delle due?» e si registra la
  scelta finale; senza scelta, `incorrect`.
- **autocorrezione**: vale l'ultima risposta data entro i dieci secondi.

## Come sono costruiti i distrattori

Ogni item di riconoscimento ha quattro opzioni: il bersaglio, **una parola dello
stesso ambito** del bersaglio (che non era nella lista), e **due bersagli di
altre coppie della lista**.

I due bersagli altrui sono la parte importante: senza di essi si potrebbe
scegliere l'unica parola riconosciuta come «già sentita» e prendere 1 punto
senza ricordare l'associazione. Chi sostituisce un item deve mantenere questa
struttura.

## Limiti dichiarati

Le coppie sono **associazioni arbitrarie** per costruzione: è ciò che rende CR
una misura di apprendimento associativo e non di inferenza semantica. Due coppie
(`scarpa … mela`, `mano … barca`) sono più facili da legare con un'immagine
mentale e servono a evitare il pavimento nei più piccoli.

La forma è di quattordici coppie e non di dieci perché con dieci la simulazione
mostrava l'11% dei 17-22enni al punteggio massimo: il vertice della
distribuzione risultava indistinguibile. Vedi `items/design/CR.md`.

Il subtest è il più esposto a **errori procedurali** dell'intera batteria: un
richiamo immediato accidentale, una sola presentazione invece di due, un ritardo
fuori finestra o un riconoscimento somministrato dopo un richiamo riuscito
rendono il dato non confrontabile. In aula conviene far provare la procedura a
vuoto prima della prima somministrazione vera.

Non esiste una misura separata di apprendimento (curva su prove ripetute) né una
prova di rievocazione libera: entrambe sarebbero utili e sono fuori dalla v0.
