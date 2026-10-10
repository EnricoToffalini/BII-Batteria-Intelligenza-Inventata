# RR — piano del banco item

RR misura l'applicazione di regole esplicite e l'integrazione di vincoli: la
regola è **data o inducibile dagli esempi**, non nascosta in una figura da
interpretare. È il secondo subtest Gf accanto a MR, e insieme formano qIF.

## Perché simboli e non figure

RR era descritto come `mixed_verbal_visual`. La forma attuale usa sequenze di
sei simboli geometrici componibili come testo (`stimulus_production:
symbol_text`) invece di illustrazioni. Tre ragioni:

1. **il costrutto non ne soffre** — le famiglie usate (serie, trasformazioni,
   vincoli d'ordine, condizionali, induzione di regole) sono forme classiche di
   ragionamento fluido e non richiedono disegni;
2. **niente contaminazione lessicale** — un Gf espresso in prosa correlerebbe
   con SP e RS più che con MR; i simboli tengono il carico verbale al minimo,
   limitato alla consegna;
3. **è riproducibile** — le sequenze sono testo versionato e diffabile, non
   immagini da rigenerare a mano.

MR resta il subtest Gf figurale e richiede `vector_geometry`: RR non lo
sostituisce e non ne anticipa il contenuto.

## Famiglie usate

| Famiglia | Che cosa chiede | Item |
|---|---|---|
| `series_completion` | continuare una serie con periodo o crescita regolare | 5 |
| `rule_transformation` | applicare una regola di sostituzione o spostamento | 4 |
| `constraint_ordering` | ricavare un ordine da vincoli relazionali | 4 |
| `rule_induction` | inferire la regola da esempi positivi e negativi | 4 |
| `conditional_rule` | ragionare su una regola «se… allora» | 3 |

`conditional_rule` è la famiglia meno numerosa e comincia solo alla posizione 9:
il ragionamento condizionale è tardivo e nelle posizioni iniziali misurerebbe
la comprensione della consegna più che il ragionamento.

Le famiglie non si ripetono mai in posizioni adiacenti.

## Progressione progettuale

| Posizioni | Contenuto prevalente | Difficoltà attesa |
|---|---|---|
| 1–5 | una sola regola, esplicita, su sequenze corte | facile |
| 6–10 | regola da indurre, oppure due vincoli da combinare | facile-media |
| 11–15 | due operazioni in sequenza, tre vincoli, regole su due dimensioni | media |
| 16–20 | regole sull'ordine delle forme, vincoli sottodeterminati, contrapposizione | medio-alta |

`difficulty_target` va da -2.40 a +2.35 con passo costante di 0.25. È una scala
progettuale, non una calibrazione.

## Trappole evitate nella costruzione

- **verità vacua nei condizionali.** «Quale gruppo rispetta la regola?» rende
  corretti anche i gruppi che non contengono l'antecedente. Tutti gli item
  condizionali chiedono quindi quale gruppo **non** la rispetta, oppure usano
  una regola di conteggio senza antecedente.
- **regole multiple compatibili con gli esempi.** In `rule_induction` è facile
  che gli esempi ammettano due regole diverse e che un distrattore sia corretto
  sotto una delle due. Il controllo a mano non bastava: il QA del 2026-10-01
  ha trovato regole alternative semplici in tutti e quattro gli item di
  induzione («stessa forma» in RR-SC-06, «ultima figura piena» in RR-SC-11,
  «comincia con un cerchio» e «quadrato al centro» in RR-SC-16, «seconda
  figura vuota» in RR-SC-20), ciascuna capace di accettare un distrattore.
  Esempi e opzioni sono stati corretti senza cambiare le chiavi, e
  `tests/test_rr_rule_induction.R` prova ora in modo esaustivo le regole di una
  o due condizioni elementari.
- **«non si può sapere» come indizio.** L'opzione compare in tutti e quattro gli
  item di `constraint_ordering` ed è corretta in uno solo.
- **crescita del vocabolario simbolico.** Il set di sei simboli è dichiarato
  nella spec e verificato dai test: aggiungerne uno cambierebbe lo spazio delle
  regole possibili senza che nessuno se ne accorga.

## Punti aperti

- Gli item 4 e 13 usano gruppi di lunghezza crescente: vanno stampati con
  spaziatura chiara, altrimenti contare le figure diventa il compito reale.
- RR-SC-19 intreccia due serie e alla posizione 19 potrebbe risultare più
  difficile del previsto per carico di memoria di lavoro più che per
  ragionamento. Da osservare nel pilot.
- RR-SC-03 (2026-10-01): «è davanti al» è diventato «è prima del», come negli
  altri item di ordinamento. Su un foglio «davanti» può voler dire anche più
  vicino a chi guarda.
- RR-SC-14 (2026-10-01): la risposta corretta era l'unico gruppo di quattro
  figure fra opzioni di tre, un indizio di forma indipendente dalla regola. Ora
  tutte le opzioni hanno tre figure; un controllo comune ai banchi a scelta
  multipla impedisce che l'indizio ricompaia.
- L'ordine dei 20 item è un'ipotesi progettuale. Prima di considerare RR
  stabile servono revisione umana indipendente e un piccolo pilot.
