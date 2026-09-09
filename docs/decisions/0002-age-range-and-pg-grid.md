# ADR 0002 — Range d'età e griglia di PG nella spec v0

- **Stato:** accettata
- **Data:** 2026-09-09

## Decisione

- Il range formale della v0 è **6;0–21;11** (72–263 mesi). La precedente
  formulazione narrativa “6;0–22;0” era incompatibile con la simulazione e le
  tabelle legacy, che terminano a 21;11. Non vengono rigenerate le norme per
  questa correzione documentale.
- PG usa una griglia **4×4**. L'esempio legacy che conteneva la cella `E5`
  descriveva invece una griglia 5×5 ed è stato corretto a un esempio 4×4.

## Motivazione

Entrambe le scelte mantengono la specifica coerente con il dato più esplicito
e con gli artefatti esistenti, senza introdurre nuovi item o parametri
psicometrici. Una futura espansione della griglia PG richiederà una modifica
di spec, item bank, routing e simulazione.
