---
title: Allow Adding Organisers During Workshop Creation - Plan
type: feat
date: 2026-08-09
artifact_contract: ce-unified-plan/v1
artifact_readiness: implementation-ready
product_contract_source: ce-plan-bootstrap
execution: code
---

# Allow Adding Organisers During Workshop Creation

## Goal Capsule

- **Objective:** Let admins choose a workshop's organisers while creating the workshop from a chapter page, so the workshop can be fully configured in one step.
- **Authority hierarchy:** Issue [#2398](https://github.com/codebar/planner/issues/2398) and maintainer comments in that issue set the scope and approach.
- **Execution profile:** Small Rails view/controller change, additive feature with no data migration.
- **Stop conditions:** The feature works when creating from a chapter page and does not change the existing general `/admin/workshops/new` flow.
- **Tail ownership:** ce-work or manual implementation; this plan is the handoff artifact.

---

## Product Contract

### Summary

When an admin clicks **New workshop** from a chapter's admin page, the new-workshop form will pre-select that chapter, hide the chapter dropdown, and show the chapter's organisers pre-selected but editable. Submitting the form creates the workshop and assigns the selected organisers. Creating a workshop from any other context continues to work exactly as it does today.

### Problem Frame

Today an admin must create a workshop and then edit it to manage organisers. The create form has no organisers field because the set of valid organisers depends on the chosen chapter, and the chapter is not known until the form is submitted. The chapter page already knows which chapter the admin is viewing, so it can seed the create form with that context.

### Requirements

- R1. The **New workshop** link on the chapter admin page passes the chapter id to the create form.
- R2. When the create form receives a chapter id, it pre-selects that chapter and hides the chapter dropdown.
- R3. When the create form receives a chapter id, it shows the chapter's organisers as pre-selected but editable.
- R4. Submitting the create form with selected organisers assigns those organisers to the new workshop.
- R5. Creating a workshop without a chapter id continues to auto-grant all chapter organisers after save, matching current behavior.

### Scope Boundaries

- **Deferred for later:** Dynamic update of the organisers list when the chapter dropdown changes in the general create form.
- **Outside this product's identity:** Changing how organisers are managed on the edit page, changing chapter-organiser membership, or adding organiser management outside the admin area.

---

## Planning Contract

### Key Technical Decisions

- KTD1. **Pre-selection signal:** Use a `chapter_id` query parameter on `new_admin_workshop_path`, as proposed by maintainers in the issue comments.
- KTD2. **Form branching:** Render the chapter select and organisers input conditionally based on a pre-selected chapter passed to the view. This keeps the existing general create form unchanged when no chapter is pre-selected.
- KTD3. **Organiser assignment:** Reuse the existing `assign_organisers` helper in `create` when organiser params are submitted; otherwise keep the current auto-grant-all-chapter-organisers behavior.

### Sources & Research

- `app/controllers/admin/workshops_controller.rb` — current `new`, `create`, and organiser helper methods.
- `app/views/admin/workshops/_form.html.haml` and `app/views/admin/workshops/_shared_form.html.haml` — current new-workshop form structure and chapter select.
- `app/views/admin/workshops/_edit_form.html.haml` — existing organisers input pattern to mirror.
- `app/views/admin/chapters/show.html.haml` — the **New workshop** entry point.
- `spec/features/admin/workshops_spec.rb` — existing feature coverage for workshop creation.
- No institutional learnings were found in `docs/solutions/` for this area.

---

## Implementation Units

### U1. Pass chapter_id from chapter show page

- **Goal:** Seed the new-workshop form with the chapter context when the admin starts from a chapter page.
- **Requirements:** R1.
- **Dependencies:** None.
- **Files:** `app/views/admin/chapters/show.html.haml`.
- **Approach:** Update the **New workshop** link to pass `chapter_id: @chapter.id`.
- **Patterns to follow:** Existing `link_to` with route helper.
- **Test scenarios:**
  - Happy path: link from chapter show page includes the chapter id parameter.
- **Verification:** Visiting a chapter show page renders a **New workshop** link whose href includes `chapter_id=<id>`.

### U2. Pre-select chapter in new action

- **Goal:** Build a workshop pre-associated with the chapter when `chapter_id` is present.
- **Requirements:** R2.
- **Dependencies:** U1.
- **Files:** `app/controllers/admin/workshops_controller.rb`.
- **Approach:** In `new`, when `params[:chapter_id]` is present and valid, build `Workshop.new(chapter_id: params[:chapter_id])`. The view should derive the pre-selected chapter from `@workshop.chapter` / `@workshop.chapter_id` so the same form state survives a failed `create` re-render.
- **Patterns to follow:** Existing `Workshop.new` build pattern and Pundit authorization.
- **Test scenarios:**
  - Happy path: `GET /admin/workshops/new?chapter_id=X` builds a workshop with `chapter_id` set.
  - Edge case: invalid or missing `chapter_id` falls back to an empty workshop without raising an error.
- **Verification:** The new action renders successfully with the correct chapter pre-selected.

### U3. Permit and assign organisers on create

- **Goal:** Persist the selected organisers when the chapter-prefixed form is submitted.
- **Requirements:** R4, R5.
- **Dependencies:** U2.
- **Files:** `app/controllers/admin/workshops_controller.rb`.
- **Approach:**
  1. Permit `organisers` as an array in `workshop_params`.
  2. After saving the workshop, if organiser params were submitted, call `assign_organisers(organiser_ids)` instead of auto-granting all chapter organisers.
  3. Keep auto-grant behavior when no organiser params are present.
- **Patterns to follow:** Existing `assign_organisers`, `grant_organiser_access`, and `params.expect` array syntax (`{ organisers: [] }`).
- **Test scenarios:**
  - Happy path: submitting selected organisers assigns those members as workshop organisers.
  - Happy path: creating without a pre-selected chapter still auto-grants all chapter organisers.
  - Edge case: submitting an empty organisers list removes any auto-granted organisers.
- **Verification:** Workshop organisers match the submitted selection after create.

### U4. Conditionally render chapter select and organisers input

- **Goal:** Show the chapter dropdown only when no chapter is pre-selected, and show the organisers input only when a chapter is pre-selected.
- **Requirements:** R2, R3.
- **Dependencies:** U2.
- **Files:** `app/views/admin/workshops/_form.html.haml`, `app/views/admin/workshops/_shared_form.html.haml`.
- **Approach:**
  1. Wrap the chapter association in `_shared_form.html.haml` so it can be hidden when a chapter is pre-selected.
  2. Add the organisers input to the new form, mirroring `_edit_form.html.haml`, when a chapter is pre-selected.
- **Patterns to follow:** `_edit_form.html.haml` organisers input (`collection: chapter.organisers`, `value_method: :id`, `label_method: :full_name`, `input_html: { multiple: true }`).
- **Test scenarios:**
  - Happy path: form with `chapter_id` shows organisers input and hides chapter select.
  - Happy path: form without `chapter_id` shows chapter select and no organisers input.
  - Edge case: a failed `create` re-render keeps the chapter select hidden and the organisers input visible.
- **Verification:** Both form variants render without errors and submit the expected parameters.

### U5. Feature test coverage

- **Goal:** Cover the end-to-end chapter-prefixed create flow with organisers.
- **Requirements:** R1, R2, R3, R4.
- **Dependencies:** U1, U2, U3, U4.
- **Files:** `spec/features/admin/workshops_spec.rb`.
- **Approach:** Add a feature spec that navigates to a chapter show page, clicks **New workshop**, adjusts the pre-selected organisers, submits, and asserts the created workshop has the expected organisers.
- **Patterns to follow:** Existing feature specs in `spec/features/admin/workshops_spec.rb` using Fabrication and Capybara.
- **Test scenarios:**
  - Happy path: create workshop from chapter page with a subset of chapter organisers assigned.
  - Edge case: create workshop from chapter page and remove all pre-selected organisers.
- **Verification:** New feature spec passes and existing feature specs still pass.

---

## Verification Contract

| Gate | Command | When it applies |
|---|---|---|
| Feature tests | `bundle exec rspec spec/features/admin/workshops_spec.rb` | Always |
| Controller tests | `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb` | Always |
| Full suite | `make test` | Before considering done |
| Lint | `bundle exec rubocop` | Before considering done |

## Definition of Done

- [ ] All implementation units above are complete.
- [ ] `bundle exec rspec spec/features/admin/workshops_spec.rb` passes.
- [ ] `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb` passes.
- [ ] `bundle exec rubocop` reports no new offenses.
- [ ] Creating a workshop from a chapter page allows selecting organisers before save.
- [ ] Creating a workshop from `/admin/workshops/new` without a chapter id behaves exactly as before.
- [ ] No abandoned or experimental code remains in the diff.
