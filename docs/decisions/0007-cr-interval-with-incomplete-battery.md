# 0007 — Intervallo CR con la batteria incompleta: CR solo in esercitazione

- Stato: accettata
- Data: 2026-10-01
- Si appoggia a: [0005](0005-route-types-and-derived-scoring.md)

## Contesto

CR richiede un ritardo di 15 minuti (finestra 14–16) fra studio e recupero.
Per rendere il ritardo confrontabile fra persone, `spec/battery.yml` stabilisce
anche come riempirlo: RP, CL e, se mancano minuti, il filler visivo `F15_V`.
Nessuno dei tre esiste ancora. Con i materiali attuali l'intervallo non può
essere riempito come previsto, e un riempitivo scelto caso per caso (in
particolare un compito verbale) renderebbe il punteggio non confrontabile.

## Opzioni considerate

1. **Costruire prima `F15_V`.** Non basta: il filler dura 2–4 minuti e non
   copre l'intervallo. Servirebbe un filler lungo quanto l'intervallo, cioè una
   modifica alla spec, e resta un compito grafico.
2. **Sequenza provvisoria v0.** Riempire l'intervallo con RR e PG, i subtest
   disponibili meno verbali (14–18 minuti in tutto), spostando RR dopo lo
   studio CR e anticipando PG. Reversibile, ma introduce nella spec una
   sequenza che non è quella della batteria finita.
3. **CR solo in esercitazione** finché RP e CL non esistono.

## Decisione

Opzione 3. La spec mantiene la sola sequenza definitiva. Il manuale dichiara che
con la batteria attuale CR si usa soltanto in esercitazione: chi conduce annota
in `notes` come ha riempito l'intervallo, e il punteggio non è confrontabile
con quello della procedura prevista.

## Conseguenze

- CR e l'indice qAR in versione base non sono utilizzabili in condizioni
  standard finché RP e CL non sono completi. Il QI totale non è comunque
  calcolabile prima di allora.
- Nessuna modifica a spec, routing, scoring o norme simulate.
- Quando RP e CL saranno disponibili, l'avviso del manuale va rimosso; se
  servirà anche `F15_V`, va costruito come pacchetto grafico separato.
