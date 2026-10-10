# CL — report del prototipo P2

> Report storico del rendering P2. Le criticità qui registrate hanno portato
> al gate P3 e alla revisione P2R; per lo stato corrente vedere
> `REVIEW_P2R.md`. Questo file non descrive più il generatore attuale.

## Ambito

Il prototipo contiene sei stimoli **non definitivi** della sola famiglia
`distinct_substitution`. Non è un item bank, non entra nello scoring e non
autorizza l'espansione ai 100 item previsti dalla spec.

Sorgenti e chiavi:

- `distinct_substitution.csv`: stringhe mostrate;
- `distinct_substitution_keys.csv`: risposta corretta e posizione della
  discrepanza;
- `R/build/build_cl_prototype.R`: validazione, impaginazione e rendering.

Il comando di build è:

```text
Rscript R/build/build_cl_prototype.R
```

Produce SVG con dimensioni fisiche dichiarate e PNG a 300 dpi per A4 e A3
orizzontali. Il generatore richiede `rsvg`, `magick`, `systemfonts` e il font
Segoe UI Symbol esatto (`seguisym.ttf`); interrompe il build invece di accettare
un fallback.

## QA automatico

`tests/test_cl_prototype.R` e il generatore verificano che:

- gli stimoli siano esattamente sei e tutti `non_definitive`;
- esista una sola famiglia, `distinct_substitution`;
- ogni stringa abbia quattro simboli e la stringa sinistra ne abbia quattro
  distinti;
- compaiano soltanto i sei simboli dichiarati nella spec e il micro-set li
  eserciti tutti;
- vi siano tre coppie uguali e tre diverse;
- ogni coppia diversa contenga una sola sostituzione, nelle posizioni 1, 2 e 4;
- chiave e posizione dichiarata coincidano con le stringhe;
- i due SVG dichiarino le dimensioni A4/A3, il font e la barra da 50 mm.

## Rendering ispezionati

Sono stati ispezionati i due PNG a risoluzione originale:

| Layout | Pixel a 300 dpi | Larghezza blocco | Altezza riga teorica |
|---|---:|---:|---:|
| A4 orizzontale, 4 × 25 | 3508 × 2480 | 66,25 mm | 6,48 mm |
| A3 orizzontale, 4 × 25 | 4961 × 3508 | 97,00 mm | 9,96 mm |

La barra da 50 mm consente di verificare lo scaling su una stampa di prova. Le
prime versioni hanno fatto emergere due difetti, entrambi corretti nel
generatore prima di conservare gli artefatti: un punto mediano corrotto dalla
locale R di Windows e la barra di scala sovrapposta a `CONTINUA`.

## Esito dell'ispezione visiva

Aspetti riusciti in entrambi i layout:

- tutti i glifi sono presenti, nitidi e riconoscibili;
- i quattro simboli hanno centri regolari e non si toccano;
- le due stringhe usano la stessa metrica, quindi la loro larghezza non rivela
  la risposta;
- separatore, numeri di riga, testatine `U`/`D` e percorso fra colonne sono
  distinguibili;
- ogni coppia uguale è una copia esatta e le tre diverse mostrano una sola
  sostituzione coerente con la chiave;
- il contrasto delle guide di riga è inferiore a quello degli stimoli.

Differenze osservate:

- **A4** è compatto ma leggibile nel rendering al 100%. I 6,48 mm per riga
  lasciano poco margine verticale attorno ai glifi da 4 mm e alle caselle da
  3,4 mm: la marcabilità con matita va verificata su carta.
- **A3** offre molto più spazio verticale, ma aumenta la distanza orizzontale
  fra stringhe e caselle di risposta. Questo può aggiungere movimento oculare e
  grafomotorio senza migliorare il matching; inoltre richiede una stampante A3.

## Problemi che P3 deve decidere

1. Il glifo `□` assomiglia molto alle caselle di risposta. Nel rendering la
   differenza di dimensione non elimina la possibile interferenza. P3 deve
   scegliere se usare bersagli di risposta circolari oppure proporre una
   modifica motivata del vocabolario nella spec.
2. Il formato A4 sembra il candidato pratico migliore, ma l'ispezione digitale
   non sostituisce una stampa al 100% e una prova di marcatura. Non è ancora
   approvato.
3. Le etichette compatte `U` e `D` riducono l'affollamento, con la legenda
   completa in testata. Va verificato che siano comprese stabilmente anche dai
   più giovani dopo gli esercizi guidati.
4. Il font è verificato nell'ambiente Windows corrente, ma non è una dipendenza
   portabile del repository. P3 deve decidere se accettare questo limite per il
   prossimo micro-lotto o richiedere un font libero incorporabile.

## Raccomandazione per il gate

Portare il prototipo a P3 senza espanderlo. Il layout non presenta artefatti che
impediscano la review, ma la somiglianza fra `□` e casella di risposta e la
marcabilità A4 richiedono una decisione esplicita prima di generare altri item.
