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
| `prompt` | Consegna da leggere o mostrare |
| `scoring_key` | Criterio sintetico della risposta corretta |
| `scoring_rubric` | Regola concreta per assegnare il punteggio |
| `review_status` | `draft`, `reviewed` oppure `retired` |

Le colonne future (asset, opzioni, distractor, tempi, note) saranno aggiunte
solo quando un subtest ne avrà davvero bisogno.
