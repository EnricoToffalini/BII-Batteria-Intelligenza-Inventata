# Colonne dell'item bank

Il formato iniziale è volutamente ridotto. Le colonne obbligatorie sono:

| Colonna | Significato |
|---|---|
| `item_id` | ID stabile, ad esempio `SP-SC-03` |
| `subtest` | ID del subtest, ad esempio `SP` |
| `item_type` | `practice` oppure `scored` |
| `order` | Ordine provvisorio di somministrazione |
| `family` | Famiglia di item, utile per evitare troppa ripetizione |
| `difficulty_rank` | Difficoltà progettuale da 1 in su, non una stima empirica |
| `difficulty_target` | Posizione progettuale usata nelle simulazioni, non calibrata |
| `prompt` | Consegna da leggere o mostrare |
| `scoring_key` | Criterio sintetico della risposta corretta |
| `max_points` | Punteggio massimo dell'item |
| `scoring_rubric` | Regola concreta per assegnare il punteggio |
| `rubric_ref` | Collegamento alla rubrica dettagliata in Markdown |
| `source_status` | `mock`, `pilot` o `empirical` |
| `review_status` | `draft`, `reviewed` oppure `retired` |

`source_status = empirical` significa soltanto che l'item è stato rivisto sulla
base di dati documentati: non implica norme empiriche o validità clinica.

## Colonne per gli item a scelta multipla

Sono obbligatorie quando il `response_format` del subtest contiene
`multiple_choice` (oggi RS). I test le verificano.

| Colonna | Significato |
|---|---|
| `option_a` … `option_d` | Le quattro alternative, tutte compilate e diverse fra loro |
| `correct_answer` | La lettera dell'alternativa corretta: `A`, `B`, `C` o `D` |
| `distractor_rationale` | Perché ogni distrattore è un errore plausibile |

`scoring_key` deve riportare il **testo** dell'alternativa indicata da
`correct_answer`: è il controllo che intercetta l'errore più facile da
introdurre modificando un item a mano, cioè spostare un'opzione senza
aggiornare la lettera.

Un distrattore non è un riempitivo. Deve corrispondere a un errore che qualcuno
può davvero fare: campo semantico corretto ma relazione sbagliata, stadio
sbagliato di una trasformazione, quasi sinonimo del termine di partenza.

## Colonne ancora da definire

Asset visivi, tempi per item e note per l'esaminatore saranno aggiunti quando
esisterà il primo subtest che ne ha bisogno. Nessun subtest visivo, a tempo o
di memoria ha ancora un item bank.

## Che cosa succede se cambi un item bank

`order` è la posizione nella forma e può cambiare; `item_id` è l'identità
dell'item e non cambia mai. Dopo una modifica vanno rigenerati i moduli di
registrazione (`Rscript R/build/build_record_forms.R`), altrimenti
`tests/test_consistency.R` fallisce.
