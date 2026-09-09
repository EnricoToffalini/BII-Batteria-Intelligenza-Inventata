# Changelog

Il progetto usa versionamento semantico pre-1.0. I cambiamenti a item,
scoring, routing, range grezzi, composizione di indici o simulazione sono
psicometricamente rilevanti e devono indicare gli artefatti rigenerati.

## Unreleased

### Added

- Fondazione del repository per `v0.0.0-dev`: README, convenzioni, decision
  record iniziale, comando unico di test e comando unico di rebuild.
- `spec/` come fonte di verità per 15 subtest, ruoli, range grezzi, routing,
  indici, quozienti, filler e ritenzione differita; loader e validator R.

### Changed

- La Shiny e gli script legacy di fit/indici leggono ora dalla spec range e
  composizioni applicabili.
- Il range formalizzato è 6;0–21;11; PG usa una griglia 4×4.

### Known legacy limitations

- Il simulatore legacy resta aggregate-score e contiene parametri transitori;
  non implementa ancora item bank o routing.
- Le norme legacy e alcuni path Shiny contengono `OFFICIAL`; saranno sostituiti
  al primo rebuild item-level derivato dalla spec.
