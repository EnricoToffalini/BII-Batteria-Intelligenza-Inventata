# 0003 — Motore di somministrazione generico e convenzioni di basale

- Stato: accettata
- Data: 2026-09-12
- Sostituisce: nessuna

## Contesto

La prima fetta verticale (SP) aveva prodotto `R/scoring/SP.R`, un file che
traduceva a mano le regole di `spec/subtests/SP.yml`. Portare RS alla forma
completa avrebbe richiesto un secondo file quasi identico, e così per gli altri
tredici subtest.

Due regole di AGENTS.md erano in tensione con quella strada: non duplicare
valori già presenti nella spec, e mantenere il repository comprensibile per uno
studente. Quindici file di routing scritti a mano avrebbero violato entrambe,
e ogni modifica alla spec avrebbe richiesto quindici modifiche coordinate.

## Decisione

Le regole adattive vengono interpretate da un motore unico,
`R/scoring/administer.R`, che legge la spec. Aggiungere un subtest con
`route_type: adaptive_items` significa scrivere la sua spec e il suo item bank,
non un nuovo file di scoring.

`R/scoring/SP.R` resta come scorciatoia leggibile (`route_sp`,
`score_sp_record`) ma non contiene più regole proprie.

Il motore copre esplicitamente le varianti già presenti nella spec:

- trigger di inversione `total_score_lt` (SP) e `correct_lt` (RS);
- criterio di basale `total_score` (SP) e `correct` (RS);
- inversione `backward` un item alla volta (SP) e `backward_in_blocks` a
  blocchi (RS).

I `route_type` non ancora coperti — `delayed_retrieval` di CR/DM, i subtest a
tempo, quelli a span — producono un errore esplicito invece di un risultato
silenziosamente sbagliato.

## Due convenzioni che il codice ha dovuto fissare

Erano implicite nella prosa e potevano essere risolte in più modi.

### Item presentati che finiscono sotto il basale

Con l'inversione a blocchi può capitare di presentare un item che poi si trova
sotto il basale stabilito. La convenzione adottata è quella corrente nelle
batterie adattive: **sotto il basale vale il credito pieno, anche se l'item era
stato presentato e sbagliato**.

L'informazione osservata non viene però buttata via: `route_subtest()` la
espone nell'attributo `presented_below_basal`, e il manuale chiede di annotare
la risposta effettiva in `notes`. Se un pilot mostrasse che questa convenzione
gonfia i punteggi bassi, va cambiata qui e nelle regole comuni del manuale, non
aggirata caso per caso.

### Finestra iniziale sufficiente e item precedenti

Se la finestra iniziale non attiva l'inversione, gli item precedenti al punto
di partenza ricevono credito pieno senza essere somministrati. Era già la
convenzione v0 di SP; ora è esplicita per tutti i subtest adattivi e resta
segnalata come da verificare nel pilot.

## Conseguenze

- `tests/test_administration_engine.R` verifica il motore sulla spec reale,
  incluso un caso che distingue davvero il blocco dall'inversione item per item.
- `R/simulation/simulate_subtest.R` sostituisce la simulazione SP-specifica e
  vale per qualunque subtest adattivo con `difficulty_target` nell'item bank.
- I moduli di registrazione diventano artefatti derivati, rigenerati da
  `R/build/build_record_forms.R`; un test fallisce se divergono dall'item bank.
- `R/build/routing_qa.R` produce un report con manifest (seed, hash della spec,
  commit) per controllare che le regole adattive restino plausibili.

## Alternative scartate

**Un file di scoring per subtest.** Più immediato da leggere per un singolo
subtest, ma duplica la spec quindici volte e rende le modifiche trasversali
inaffidabili. Scartata: la scorciatoia per-subtest si ottiene comunque con
poche righe di wrapper.

**Unificare l'inversione di RS su quella di SP.** Avrebbe semplificato il
motore e il manuale, ma è una modifica psicometrica alla spec fatta per comodità
implementativa. Scartata: la spec resta la fonte di verità, e l'inversione a
blocchi è una scelta difendibile per un subtest a scelta multipla.
