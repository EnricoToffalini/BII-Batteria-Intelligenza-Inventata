# Stato della migrazione alla spec

Da `spec_version` `0.1.0`, `spec/` è la fonte di verità per:

- catalogo dei 15 subtest, ruoli, domini e range di età;
- numero di item/prove, formato di risposta, scoring e range grezzi;
- start, inversione/basal, ceiling, timing, ritenzione e filler;
- composizione di indici e quozienti.

I consumer già collegati sono `R/1.Fitting.R`,
`R/3.Indices_tables_and_CFA.R` e `shiny/shinyBII.R`.
`R/0.Data generation.R` legge dalla spec catalogo e range dei subtest, ma è
ancora un generatore legacy a punteggio totale: i suoi parametri latenti e le
sue procedure non rappresentano un'implementazione item-level della spec.

Le duplicazioni residue nei commenti e nei blocchi `if (FALSE)` della Shiny
sono archivio leggibile del comportamento legacy e non sono eseguite. Vanno
rimosse quando la UI response-level sostituirà il calcolatore corrente.

Gli artefatti `norms_BII/` restano compatibili per ID/range/composizione degli
indici completi; i test verificano questa compatibilità minima. Non attestano
validità psicometrica né coerenza procedurale item-level.
