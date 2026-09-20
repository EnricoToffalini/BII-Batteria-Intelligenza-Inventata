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
  terminologia tecnica.

I primi tre controlli sono automatici in `tests/test_rs_scoring.R`; gli altri
sono revisione umana e vanno rifatti a ogni sostituzione di item.

## Punti aperti

- `RS-SC-06`, `RS-SC-20`, `RS-SC-23` e `RS-SC-24` distinguono quasi sinonimi:
  sono i candidati più probabili a misurare vocabolario più che ragionamento e
  vanno osservati per primi nella prova con studenti.
- `RS-SC-16` (bruco/girino) presuppone una conoscenza comune ma scolastica
  della metamorfosi; da verificare nella fascia più giovane.
- L'ordine dei 24 item è un'ipotesi progettuale. Prima di considerare RS
  stabile servono una revisione umana indipendente e un piccolo pilot.
