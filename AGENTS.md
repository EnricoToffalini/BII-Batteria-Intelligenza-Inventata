# AGENTS.md — BII repository instructions

## Project purpose

BII (Batteria d'Intelligenza Inventata) is a didactic mock intelligence battery. It is designed to be psychometrically plausible and fully usable for teaching, but it is **not a clinical or diagnostic instrument** and its norms are simulated unless explicitly stated otherwise.

Read `ROADMAP_V0.md` before substantial work.

## Core development rule

**Battery coherence is more important than preserving existing simulated outputs.**

The current simulations, synthetic norms, CFA results, conversion tables and Shiny behavior are derived artifacts. If real item/stimulus development shows that item counts, scoring, difficulty progression, start points, basal rules, ceiling rules, timing, index composition or other assumptions should change, update the specification first and regenerate affected outputs.

Do not patch around a specification conflict merely to preserve old results.

## Source of truth

As the migration progresses, `spec/` is the authoritative machine-readable source of truth.

Do not hard-code values in R/Shiny/docs when they can be loaded from the specification, including:

- subtest IDs and names;
- roles (`core`, `completion`, `supplementary`);
- item counts;
- raw-score ranges;
- start points;
- basal/inversion rules;
- ceiling/stop rules;
- time limits;
- index/QI composition.

Until migration is complete, treat `_BII - Batteria Intelligenza Inventata.md` as the legacy specification and explicitly document any temporary duplication.

## Item development

Every scored item must have a stable ID and an explicit scoring key/rubric.

Visual stimuli should be deterministic and reproducible whenever feasible. Prefer SVG, scripted geometry and versioned source assets over opaque manually edited raster files.

Do not generate large item banks in one pass without review. Work by subtest and item family, with small prototypes followed by QA and expansion.

### Only build what you can build faithfully

Each subtest spec declares `stimulus_production`: the capability its stimuli
actually require (`text_only`, `symbol_text`, `symbol_grid`, `vector_geometry`,
`manipulative`). The vocabulary is defined in `spec/battery.yml`.

**Do not populate an item bank whose `stimulus_production` you cannot deliver
properly.** An agent without reliable figure-generation must not write items for
a `vector_geometry` subtest in prose, in ASCII art, or as placeholders to be
replaced later: a mock battery with fake stimuli is worse than one with an empty
subtest, because the gap stops being visible. Pick a subtest you can actually
finish, and say in your summary which ones you left untouched and why.

`stimulus_production` is not a downgrade path. If a subtest genuinely does not
need figures, change its `stimulus_production` deliberately and record why — as
was done for RR in `docs/decisions/0004-item-development-strategy.md`. Do not
change it merely to make a subtest fit the tools at hand, and never change a
subtest whose construct depends on the figural format: MR, MO and RP are
figural on purpose and are not to be reformulated as text.

### Closed symbol vocabularies

A subtest whose items are built from symbols declares the complete set in its
spec (`symbol_vocabulary`), and a test fails if any other symbol appears.
Adding a symbol silently enlarges the space of possible rules and may not
render in print. If a new symbol is genuinely needed, add it to the spec first
and re-check every existing item against the enlarged space.

### Open-response rubrics

For `0/1/2` subtests, keep the meaning of each level constant across the whole
subtest and state it once at the top of the rubric, then give per-item examples.
Full credit should require the *mechanism* — why a solution works, what a rule
is for — not merely a relevant or well-mannered answer. Partial credit should
mark an identifiable correct step, not a different wrong method.

Do not let a rubric reward social desirability, verbal fluency or compliance
with authority. State which items are most exposed to differences in a
respondent's experience rather than assuming none are.

## Psychometric status

Never describe synthetic standardization data as empirical norms.

Avoid naming generated outputs `OFFICIAL` when that could imply empirical validation. Prefer terms such as `simulated`, `synthetic`, `reference`, or an explicit version identifier.

Do not optimize simulated psychometric fit solely to produce attractive indices. Document tuning decisions and preserve reproducibility.

## Simulation

Long-term target pipeline:

`spec -> item bank -> item-level responses -> administration/routing -> observed raw scores -> simulated norms -> indices/QI -> QA reports`

Use explicit random seeds and write build metadata/manifests for regenerated simulations.

If a psychometrically relevant spec change occurs, determine whether simulation/norming outputs must be rebuilt.

## Adding a subtest

Administration rules live in the spec, not in code. `R/scoring/administer.R`
interprets them generically for every subtest with `route_type:
adaptive_items`. For such a subtest, adding it means **no new routing code**:

1. complete its `spec/subtests/<ID>.yml`, including an `item_bank` block;
2. write `items/source/<ID>.csv`;
3. write `items/rubrics/<ID>.md` (instruction, key or rubrics, edge cases);
4. write `items/design/<ID>.md`, with an explicit `## Punti aperti` section;
5. add a `# <ID> — <name>` section to `manual/ADMINISTRATION.md`;
6. add a provenance row in `items/PROVENANCE.md`;
7. regenerate record forms: `Rscript R/build/build_record_forms.R`;
8. regenerate the routing QA report: `Rscript R/build/routing_qa.R`;
9. add `tests/test_<id>_scoring.R` with routing cases computed by hand.

Steps 3–7 are enforced by `tests/test_consistency.R`, so a partially wired
subtest fails the suite rather than passing silently.

**Do not hand-write a key table in a rubric.** Rubrics may repeat the item
bank's key as a markdown table for the examiner's convenience, but that table
duplicates the source of truth and drifts from it silently — it happened three
times during development of CR, PG and SM. Generate the table from the CSV and
paste the output. `tests/test_rubric_key_tables.R` enforces the rule: if a
rubric names any scored item in a table, it must name them all, and each row
must carry that item's key material as it stands in the CSV.

If you write a new file of per-subtest routing rules, you are almost certainly
doing it wrong. `route_subtest()` dispatches on `route_type` through the
`BII_ROUTE_HANDLERS` registry in `R/scoring/administer.R`. Implemented:
`adaptive_items`, `delayed_retrieval`, `adaptive_levels`,
`adaptive_levels_by_microblock`. Still missing: `fixed_time` (CL, SS).

To add a route type, write a handler and register it — do not touch
`route_subtest()`. Implement it once for the whole class, not per subtest, and
keep its procedure as close as possible to `adaptive_items`: the examiner should
learn one procedure with different numbers, not several different procedures.

**Scoring derived from components.** When a subtest's item score is not recorded
directly but computed from observed components (CR's `recall` + `recognition`),
the spec declares `scoring.derived_from`, the allowed values per component, and
the score-to-condition map in `scoring.rubric`. The engine knows the condition
*names*; the score *values* stay in the spec. Two consequences that must be
preserved: the generated record form omits the `item_score` column (asking for a
number the scorer ignores invites error), and a missing component makes the
scorer **refuse** to score that item rather than assigning zero.

Quality checks that apply to a *class* of subtests belong in a shared test
(`tests/test_multiple_choice_banks.R` is the existing example), not copied into
each subtest's test file.

## Administration/scoring semantics

Keep these states distinct:

- incorrect response;
- omission;
- not administered below basal;
- not administered above ceiling;
- not administered for an external reason;
- invalidated item/subtest.

Do not silently convert external missingness into errors.

Subtest-specific rules override generic defaults when explicitly specified.

## Coding principles

Prefer small coherent changes over broad opportunistic rewrites.

## Student maintainability

The repository is a teaching tool, not an engineering exercise. A student with
basic R and spreadsheet skills must be able to replace mock items and
simulated inputs without understanding the implementation internals.

- Prefer documented CSV templates and short Markdown instructions for item
  banks, response records and manual review.
- Keep the normal workflow to a small number of commands; explain what each
  command checks or changes.
- Do not add a database, framework or abstraction layer unless a simple CSV,
  script or existing tool cannot meet a concrete need.
- Keep collected data separate from versioned sources. Do not add names,
  contact details or other directly identifying data to the repository.
- Preserve the distinction between simulated, pilot and empirical data in
  filenames, manifests, reports and UI. Real observations alone are not
  empirical norms or clinical validation.

Before editing:

1. inspect the relevant specification;
2. inspect dependent code/tests;
3. identify whether the task changes a source or a derived artifact.

After editing:

1. run relevant tests;
2. run consistency checks;
3. regenerate derived artifacts when required;
4. summarize assumptions and unresolved issues.

## Tests

Add regression tests whenever a discovered inconsistency could recur.

Important classes of tests include:

- spec validation;
- duplicate/missing item IDs;
- item count vs raw max;
- valid start-point ranges;
- basal/ceiling routing;
- manual vs software scoring;
- missing-data semantics;
- spec vs Shiny consistency;
- spec vs simulated norms consistency;
- asset existence;
- end-to-end synthetic administrations.

## Cross-cutting changes

Changes to any of the following are potentially cross-cutting and require extra review:

- item count;
- scoring scale;
- raw-score range;
- index/QI composition;
- start/basal/ceiling rules;
- time limits;
- age bands;
- item difficulty model;
- subtest role/domain.

When making such changes, list all affected downstream artifacts explicitly.

## Documentation

The examiner-facing materials must eventually be sufficient to administer the battery without reading R code.

Maintain a clear separation between:

- theory/rationale;
- administration instructions;
- scoring;
- interpretation;
- technical development/simulation notes.

## Pull-request / task completion

A task is not done merely because code runs.

A completed change should:

- leave the repository internally coherent;
- update the correct source of truth;
- include tests where appropriate;
- regenerate affected derived outputs;
- preserve explicit didactic/non-clinical disclaimers;
- state remaining uncertainties rather than silently guessing.
