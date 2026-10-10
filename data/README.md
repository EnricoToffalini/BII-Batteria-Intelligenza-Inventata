# Passare da mock a dati raccolti

Questa cartella è il punto di passaggio più semplice tra una esercitazione con
dati simulati e una piccola raccolta reale. Non richiede di modificare R o la
Shiny.

1. Copiare i file di `data/templates/` che servono in `data/collected/`.
2. Assegnare un codice anonimo a ogni partecipante (`P001`, `P002`, …), senza
   nome, email, telefono o altri identificativi diretti.
3. Compilare una riga per item nel file delle risposte.
4. Eseguire:

```powershell
Rscript R/data/check_responses.R data/collected/responses.csv
```

Il comando non calcola un QI e non modifica file: dice solo se i dati usano
gli item, le età e gli stati previsti dalla batteria corrente. Per CR controlla
anche che un protocollo completo possa essere corretto dalle componenti
osservate; il punteggio viene verificato ma non salvato. È il controllo da fare
prima di qualsiasi analisi.

## Punteggio derivato di CR

`responses.csv` è un template comune: `recall`, `recognition` e
`delay_minutes` restano vuote per gli altri subtest. Per CR:

- lasciare sempre vuoto `item_score`, perché viene derivato;
- registrare `recall` come `correct`, `incorrect` oppure `omitted`;
- registrare `recognition` come `correct` o `incorrect` dopo un richiamo non
  riuscito, e come `not_administered` dopo un richiamo corretto;
- ripetere in `delay_minutes` il ritardo effettivo del recupero.

Il checker rifiuta valori non previsti dalla spec e un protocollo completo non
correggibile, per esempio un richiamo errato senza successivo riconoscimento.

## Prove a tempo (CL, SS)

CL e SS non hanno una riga per item: ogni foglio somministrato produce una sola
riga di conteggi. Per queste prove usare `timed_records.csv`, una riga per
persona e prova:

| Colonna | CL | SS |
|---|---|---|
| `correct`, `errors` | righe corrette e sbagliate | vuote |
| `hits`, `false_alarms` | vuote | target marcati e distrattori marcati |
| `omissions` | righe senza risposta | target non marcati |
| `actual_time_minutes` | tempo effettivo, con il punto decimale (`2.5`) | idem |
| `procedure_notes` | interruzioni o anomalie, senza dati identificativi | idem |

Lasciare vuote le colonne dell'altra prova. Poi eseguire:

```powershell
Rscript R/data/check_timed_records.R data/collected/timed_records.csv
```

Il comando controlla codice, età, colonne, range delle componenti e vincoli
fra componenti letti dalla spec (per esempio, in SS `hits + omissions` non può
superare il numero di target), poi elenca **tutti** i problemi con il numero di
riga del file. Un tempo non registrato o diverso da quello previsto produce
solo un avviso: non cambia il punteggio grezzo. Va bene anche un file con le
sole colonne di un modulo di registrazione CL o SS, se contiene una sola prova.

## Punteggi grezzi

Quando i controlli passano, i punteggi grezzi si ottengono con:

```powershell
Rscript R/data/score_collected.R data/collected/responses.csv --timed=data/collected/timed_records.csv --out=data/collected/raw_scores.csv
```

`--timed` e `--out` sono facoltativi. Il comando ripete prima i controlli e si
ferma se un file non è valido; poi produce una riga per persona e subtest con
`raw_score`, `raw_max`, `status` e `notes`:

| `status` | Significato |
|---|---|
| `complete` | punteggio grezzo calcolato; in `notes` eventuali avvisi procedurali |
| `external_missing_or_invalidated` | almeno un item `external_missing` o `invalidated`: il totale non si calcola |
| `incomplete_record` | il protocollo non contiene tutti gli item scored; in `notes` il motivo |

Il comando **non** calcola punteggi ponderati, indici o QI: le norme della BII
sono simulate e non vanno applicate a dati raccolti come se fossero empiriche.
Il file scritto con `--out` resta in `data/collected/`, ignorata da Git.

## Accordo fra due correttori (SP, CS, QS)

Le rubriche aperte 0/1/2 dipendono dal giudizio di chi corregge. Prima di
fidarsi di una rubrica conviene far correggere le stesse risposte a due
persone, **ciascuna senza vedere i punteggi dell'altra**. Usare
`scorer_agreement.csv`, una riga per risposta:

| Colonna | Contenuto |
|---|---|
| `subject_id` | codice anonimo, come negli altri file |
| `subtest`, `item_id` | item scored di SP, CS o QS (non gli item di prova) |
| `response` | la risposta trascritta, uguale per i due correttori |
| `score_a`, `score_b` | punteggio 0, 1 o 2 assegnato da ciascun correttore |

Includere solo item effettivamente somministrati con una risposta: le
omissioni valgono 0 per regola e gonfierebbero l'accordo. I nomi dei
correttori non vanno nel file. Poi eseguire:

```powershell
Rscript R/data/check_scorer_agreement.R data/collected/scorer_agreement.csv
```

Il comando controlla il file, poi riporta per subtest e per item l'accordo
esatto, il kappa pesato quadratico, la differenza media fra correttori (un
valore lontano da 0 indica che uno dei due è sistematicamente più generoso) e
l'elenco dei disaccordi 2 contro 0, che sono i primi da discutere: di solito
indicano un esempio mancante o ambiguo nella rubrica. Non applica soglie: con
meno di 30 risposte per subtest il kappa è molto instabile e va letto insieme
agli item che generano i disaccordi.

`data/collected/` è ignorata da Git per evitare pubblicazioni accidentali di
dati raccolti. Per condividere dati, creare prima una versione davvero
anonimizzata e documentare autorizzazioni, consenso e finalità didattica.

I dati reali non trasformano automaticamente le norme simulate in norme
empiriche. Finché non esiste un protocollo di raccolta e analisi appropriato,
i risultati restano descrittivi e didattici.
