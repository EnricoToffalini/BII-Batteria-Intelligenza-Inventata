# SS — decisione del review gate P5R2

**Decisione: revisione richiesta prima di qualunque espansione.** P5RR ha
eliminato le alternanze di righe che avevano bloccato P5R, ma il nuovo
rimescolamento ha introdotto una diagonale completa di target e due blocchi
2×2 di target agli estremi del percorso. Le primitive e il layout passano di
nuovo; la disposizione delle 60 celle no. Nessun lotto di espansione è
autorizzato.

## Evidenze esaminate

- `stimulus_cells.csv` e `stimulus_keys.csv` (12 celle di pratica, 60 di
  prototipo);
- SVG e PNG A4 a 300 dpi, ispezionati sia ridotti (vista d'insieme del foglio)
  sia a risoluzione originale sulla matrice;
- controlli automatici di `tests/test_ss_prototype.R`, tutti superati
  (`Rscript tests/run_all.R`: 29 file superati);
- un audit dei pattern spaziali più ampio dei test: diagonali, blocchi 2×2,
  quadranti, distanze fra righe anche dopo uno spostamento di una colonna,
  periodicità entro riga e distribuzione dei distrattori per riga e metà
  foglio;
- una ricostruzione in un secondo ambiente (Linux, librsvg 2.58, font
  sans-serif di sistema Inter).

Come in P5R, stampa al 100% e marcatura a matita restano differite al
controllo finale per decisione del responsabile del progetto.

## Esito per criterio

| Criterio | Esito | Evidenza |
|---|---|---|
| vocabolario e primitive | passa | sei primitive distinte; nessun clipping o collisione a 300 dpi |
| scala e completezza A4 | passa digitalmente | invariate rispetto a P5R |
| portabilità delle primitive | **passa** (nuovo) | nel secondo ambiente l'SVG è identico byte per byte e le 72 celle sono identiche pixel per pixel; differisce soltanto il testo, reso con un altro font |
| vincoli P5R (alternanze, colonne 2–4, righe uguali o complementari) | passa | confermati dai test e dall'audit |
| percorso per righe e distribuzione per quadranti | passa | target per quadrante 8, 7, 7, 8; metà sinistra e destra 15 e 15 |
| assenza di cluster e diagonali | **non passa** | diagonale principale R1C1–R6C6 interamente di target; blocchi 2×2 in R1–R2/C1–C2 e R5–R6/C9–C10 |
| righe quasi uguali o quasi complementari | **non passa** | righe 1 e 2 differiscono in 2 posizioni su 10; righe 1 e 3 in 9; le righe 3 e 6 sono quasi identiche se spostate di una colonna, e così le righe 1 e 6 (1 differenza) |
| distribuzione dei distrattori critici | debole | `circle_horizontal` sta per 5/6 nella metà destra, `square_vertical` per 5/6 nella sinistra |
| pop-out e salienza | passa solo provvisoriamente | nessuna primitiva emerge sulle altre, ma la diagonale di cerchi si vede nella vista d'insieme |

## Difetto che blocca l'espansione

Con `T` = target e `D` = distrattore, la matrice è:

```text
     1 2 3 4 5 6 7 8 9 10
R1   T T D D T D D T D D
R2   T T D D T T D T D T
R3   D D T T D T T D D T
R4   T D D T D T D D T D
R5   D T D T T D T D T T
R6   D T T D D T D D T T
```

Le celle R1C1, R2C2, R3C3, R4C4, R5C5 e R6C6 sono tutte target. Nel rendering
la diagonale si vede come una linea di cerchi che va dal blocco 2×2 di inizio
percorso a quello di fine percorso. È proprio il caso escluso dal brief
(«nessun cluster o diagonale che riveli il target»). Con 20 righe, una struttura
del genere permetterebbe di prevedere le posizioni dei target senza applicare
la congiunzione forma-orientamento.

I controlli aggiunti in P5RR guardano soltanto righe, colonne e corrispondenze
esatte fra righe. Non potevano rilevare diagonali, blocchi o quasi-copie: il
difetto mostra di nuovo che ogni rimescolamento va verificato anche contro le
strutture bidimensionali.

## Osservazione sulla composizione (non risolvibile qui)

Con sei occorrenze per distrattore, i cerchi sono 36 su 60 e 30 di questi
sono target. La strategia «barra ogni cerchio» ottiene `30 − 6 = 24` su 30
senza mai guardare la linea interna; sulla forma completa darebbe `100 − 20 =
80` su 100. La strategia «barra ogni linea verticale» ottiene 18 su 30 (60 su
100). La congiunzione è quindi necessaria soltanto per 6 celle su 60, e la
prova rischia di misurare soprattutto la discriminazione della forma.

Questo non dipende dalla disposizione: deriva dalla composizione 100/20×5
fissata nella spec. Cambiarla è una decisione cross-cutting (spec, brief,
prototipo, test ed eventualmente il modello di falsi allarmi della
simulazione), quindi questo gate non la cambia. È registrata come
pacchetto di decisione N14 in `docs/development/WORK_PACKETS.md`, senza
promuoverlo.

## Revisione autorizzata (P5RR2)

Il packet successivo può soltanto rimescolare di nuovo le 60 celle `prototype`,
mantenendo invariati pratica, composizione, conteggi target per riga
`4, 6, 5, 4, 6, 5`, primitive, layout, timing, scoring e vocabolario, e tutti i
vincoli già testati in P5RR.

Deve aggiungere a `validate_ss_prototype()` e ai test controlli che impediscano:

- diagonali di target (in entrambe le direzioni) lunghe più di tre celle;
- blocchi 2×2 composti solo da target;
- coppie di righe target/distrattore a distanza di Hamming minore di 2 o
  maggiore di 8, o minore di 3 se le righe sono adiacenti;
- coppie di righe a distanza minore di 2 dopo uno spostamento di una colonna
  in entrambe le direzioni;
- un distrattore critico (`circle_horizontal`, `square_vertical`,
  `triangle_vertical`) con più di 4 occorrenze su 6 nella stessa metà del
  foglio.

La disposizione attuale viola ciascuno di questi controlli: diagonale lunga
6, due blocchi 2×2, righe adiacenti 1–2 a distanza 2, righe 1–3 a distanza 9,
righe 1–6 e 3–6 a distanza 1 dopo lo spostamento, `circle_horizontal` e
`square_vertical` 5/6 in una metà.

**Fattibilità verificata.** Una prima formulazione più severa (distanza fra
3 e 7 per ogni coppia, anche dopo lo spostamento) non era soddisfacibile: su
200 000 disposizioni casuali che rispettavano già i vincoli di riga, nessuna
superava anche colonne, diagonali, blocchi e distanze. Con le soglie sopra
indicate ne sono state trovate 9 su 200 000, e per una di esse circa l'1,3%
delle assegnazioni casuali dei distrattori rispetta sia i vincoli di
adiacenza di P5RR sia quello per metà foglio. Il vincolo è quindi stretto ma
soddisfacibile. P5RR2 deve cercare la disposizione con un seed esplicito
documentato, non costruirla a mano.

Per la forma da 20 righe i vincoli sulle coppie di righe non scalano così come
sono: 190 coppie invece di 15 renderebbero la ricerca casuale impraticabile.
Prima di qualunque espansione vanno riformulati, per esempio limitandoli alle
righe entro una distanza fissa.
Dopo il nuovo rendering serve un altro review gate digitale (P5R3). La forma da
200 celle resta non autorizzata. Se N14 cambiasse la composizione, P5RR2
andrebbe rifatto sulla nuova composizione invece di proseguire.

## Note minori

- La pratica è fuori dall'ambito e protetta da snapshot. La sua seconda riga
  (`D T D T D T`) è perfettamente alternata, ma ha sei celle, non è scored e
  viene corretta con l'esaminatore: non blocca il gate.
- Nel secondo ambiente il PNG non è identico byte per byte a quello versionato,
  perché il testo usa un font diverso. Gli hash del report P5RR valgono quindi
  solo a parità di font; il test non dipende da essi.
