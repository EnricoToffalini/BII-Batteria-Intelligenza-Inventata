# RS — piano del banco item

RS valuta il riconoscimento di relazioni semantiche, non soltanto il possesso
di vocaboli rari. Le regole restano visibili e ogni item ha una sola risposta
difendibile.

## Famiglie usate

| Famiglia | Che cosa chiede | Item |
|---|---|---|
| `category_exclusion` | escludere l'elemento che non condivide il criterio | 6 |
| `part_whole` | riconoscere la relazione parte–tutto | 4 |
| `opposition` | individuare l'opposto semantico | 5 |
| `development` | riconoscere una trasformazione o uno stadio successivo | 4 |
| `function` | identificare la funzione principale di uno strumento | 3 |
| `analogy_function` | trasferire una relazione di funzione a un nuovo caso | 2 |

`function` e `analogy_function` sono tenute distinte perché hanno un carico
diverso: la prima chiede di riconoscere una funzione nota, la seconda di
trasferire la relazione a un dominio nuovo. Le famiglie si alternano lungo la
forma e non compaiono mai due volte di seguito: serie lunghe di item identici
insegnerebbero la strategia durante la prova.

## Progressione progettuale

| Posizioni | Contenuto prevalente | Difficoltà attesa |
|---|---|---|
| 1–6 | oggetti, animali e qualità concrete ad alta frequenza | facile |
| 7–12 | relazioni comuni con un termine meno frequente | facile-media |
| 13–18 | concetti astratti presenti nel linguaggio quotidiano | media |
| 19–24 | relazioni astratte e distinzioni fini fra quasi sinonimi | medio-alta |

`difficulty_target` va da -2.4 a +2.2 con passo costante di 0.2. È una scala
progettuale scelta per distribuire gli item lungo il range, non una stima: non
va presentata come calibrazione.

## Controlli fatti sulla forma completa

- una sola risposta difendibile per item, verificata opzione per opzione;
- nessuna consegna ripetuta con le stesse opzioni;
- risposte corrette distribuite fra A, B, C e D (6/7/6/5);
- nessuna famiglia ripetuta in posizioni adiacenti;
- distrattori costruiti come errori plausibili e non come riempitivi;
- nessun item che richieda nozioni scolastiche specifiche, formule o
  terminologia tecnica;
- la risposta corretta non è l'unica opzione più lunga in parole;
- nessuna parola che SP chiede di definire compare negli stimoli.

Sono automatici i controlli su consegne ripetute, distribuzione delle risposte,
famiglie adiacenti e opzioni più lunghe (`tests/test_multiple_choice_banks.R`)
e quello sulle parole di SP (`tests/test_cross_subtest_overlap.R`); gli altri
sono revisione umana e vanno rifatti a ogni sostituzione di item.

## Punti aperti

- QA concettuale per item (2026-10-01, packet N10). Corretti sette item senza
  cambiare chiavi, ordine o difficoltà progettuale:
  - `RS-SC-03`: «pesca» sostituita da «arancia», perché RS si presenta a voce e
    «pesca» è anche l'attività del pescare;
  - `RS-SC-12`: «pino» sostituito da «pioppo». Con il pino esisteva una seconda
    risposta difendibile (l'unico albero con gli aghi); ora sia «non è un
    albero» sia «è sempreverde» indicano soltanto l'edera;
  - `RS-SC-14` e `RS-SC-21`: la risposta corretta era l'unica opzione più lunga
    o composta da più parole; ora le opzioni hanno forma parallela;
  - `RS-SC-22`: «il tempo» era difendibile (un moderatore regola anche i tempi
    degli interventi) ed è sostituito da «il traffico»;
  - `RS-SC-06` e `RS-SC-23`: la coppia di esempio usava *provvisorio* e
    *implicito*, che SP chiede di definire; la stessa parola sarebbe entrata in
    due subtest di qIC. Ora le coppie sono «parziale/totale» e
    «dichiarato/sottinteso».
- Da osservare nel pilot: `RS-SC-02` (*bussola*) in posizione 3 potrebbe
  misurare il vocabolario dei bambini di 6 anni più della relazione di
  funzione; `RS-SC-05` e `RS-SC-07` condividono i distrattori «nido» e
  «piuma», quindi chi ha scartato le due opzioni nel primo item può
  riconoscerle nel secondo.

- `RS-SC-06`, `RS-SC-20`, `RS-SC-23` e `RS-SC-24` distinguono quasi sinonimi:
  sono i candidati più probabili a misurare vocabolario più che ragionamento e
  vanno osservati per primi nella prova con studenti.
- `RS-SC-16` (bruco/girino) presuppone una conoscenza comune ma scolastica
  della metamorfosi; da verificare nella fascia più giovane.
- L'ordine dei 24 item è un'ipotesi progettuale. Prima di considerare RS
  stabile servono una revisione umana indipendente e un piccolo pilot.
