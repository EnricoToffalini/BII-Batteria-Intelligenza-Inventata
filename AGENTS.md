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

## Psychometric status

Never describe synthetic standardization data as empirical norms.

Avoid naming generated outputs `OFFICIAL` when that could imply empirical validation. Prefer terms such as `simulated`, `synthetic`, `reference`, or an explicit version identifier.

Do not optimize simulated psychometric fit solely to produce attractive indices. Document tuning decisions and preserve reproducibility.

## Simulation

Long-term target pipeline:

`spec -> item bank -> item-level responses -> administration/routing -> observed raw scores -> simulated norms -> indices/QI -> QA reports`

Use explicit random seeds and write build metadata/manifests for regenerated simulations.

If a psychometrically relevant spec change occurs, determine whether simulation/norming outputs must be rebuilt.

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
