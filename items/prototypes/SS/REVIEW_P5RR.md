# SS — report della disposizione ridotta revisionata P5RR

## Ambito

P5RR rimescola soltanto le 60 celle `prototype` che non avevano superato il
gate P5R. Le 12 celle di pratica, le primitive, il layout, la composizione, i
conteggi target per riga, timing, scoring e vocabolario restano invariati. Il
packet non crea la forma da 200 celle.

## Correzione della regolarità spaziale

Le nuove sequenze target (`T`) / distrattore (`D`) sono:

```text
TTDDTDDTDD
TTDDTTDTDT
DDTTDTTDDT
TDDTDTDDTD
DTDTTDTDTT
DTTDDTDDTT
```

I target per colonna sono `3, 4, 2, 3, 3, 4, 2, 2, 3, 4`. Quindi ogni colonna
ne contiene da due a quattro, contro il precedente intervallo 1–4. Nessuna
riga è duplicata o complementare a un'altra e nessuna alternanza `T/D` supera
cinque celle consecutive.

Ogni distrattore compare ancora sei volte. La nuova disposizione evita anche
distrattori identici adiacenti sia in orizzontale sia in verticale.

## QA automatico

`validate_ss_prototype()` e `tests/test_ss_prototype.R` proteggono ora:

- le 12 celle di pratica tramite snapshot dei token;
- 30 target e 30 distrattori;
- sei occorrenze per ciascun distrattore;
- conteggi target per riga `4, 6, 5, 4, 6, 5`;
- da due a quattro target per colonna;
- massimo due celle consecutive dello stesso tipo;
- massimo cinque celle in alternanza target/distrattore;
- assenza di righe duplicate o complementari;
- assenza di distrattori identici adiacenti per riga e colonna;
- corrispondenza fra token, chiave e vocabolario chiuso.

## Ispezione visiva

Il PNG A4 a 300 dpi è stato ispezionato a risoluzione originale. La matrice
revisionata mantiene dimensioni, spaziatura, guide e percorso del prototipo
precedente; non mostra più le righe alternate che avevano bloccato P5R. Non
sono emersi clipping, collisioni o differenze di scala fra primitive.

Anche il PDF A4 vettoriale è stato rasterizzato indipendentemente a 150 dpi:
pratica, matrice, testi e barra da 50 mm risultano completi e leggibili.

## Riproducibilità

Due build consecutive hanno prodotto gli stessi SHA-256 per gli artefatti
senza metadati temporali:

| File | SHA-256 |
|---|---|
| `SS_search_prototype_A4_portrait.svg` | `5A8DFDD6F6631438A5181DE597156F973B6A0E0D64D273F8EB62632FE7589B69` |
| `SS_search_prototype_A4_portrait_300dpi.png` | `2AA3DABBE5520525BC1DAD4FCA0CFBF044F8DD4FC942BDE3C9DADFA329FCBF9C` |

Il PDF contiene un timestamp Cairo; il test ne controlla dimensione A4 e
rendering, non l'identità byte per byte.

## Esito

P5RR soddisfa il proprio criterio di uscita e passa a un nuovo review gate
digitale. Nessuna espansione è implicita. Marcabilità a matita e scala della
stampante restano differite al controllo finale per decisione del responsabile
del progetto.
