---
title: Feedback star rating replacement - Plan
type: refactor
date: 2026-08-25
topic: feedback-star-rating
artifact_contract: ce-unified-plan/v1
artifact_readiness: implementation-ready
product_contract_source: ce-brainstorm
execution: code
---

# Feedback star rating replacement - Plan

## Goal Capsule

- **Objective:** Remove the abandoned jSimple Star Rating jQuery plugin and replace the member feedback form's rating control with a maintainable, progressively enhanced, dependency-free star-rating widget that preserves the existing click-to-rate and submit behaviour.
- **Means:** A vanilla-JavaScript initializer progressively enhances server-rendered radio buttons into CSS-generated stars. (KTD1, KTD2)
- **Product authority:** The maintainers of codebar planner.
- **Open blockers:** None.

## Product Contract

### Summary

Replace the hand-vendored jSimple Star Rating plugin used on the member feedback form with a progressively enhanced, vanilla-JavaScript star-rating control.
The no-JS fallback will be a native form control (radio buttons), which JavaScript then enhances into clickable CSS-generated stars.
This removes the unmaintained dependency and the inline `:javascript` HAML block while keeping the current star-rating interaction unchanged.

### Problem Frame

The feedback form currently depends on `app/assets/javascripts/jsimple-star-rating.min.js`, an abandoned third-party jQuery plugin (v2.0.0, no active maintenance).
It is the only consumer of that plugin, yet it is loaded globally through the Sprockets manifest.
The view also embeds initialization and submit-handling logic inline via the `:javascript` HAML filter, which mixes behaviour with markup and is hard to test.

### Key Decisions

- K1. Use a vanilla JavaScript initializer file in `app/assets/javascripts/` rather than a Stimulus controller or inline script. Governs R1, R2. The project has not yet wired Stimulus/Turbo and the widget appears on a single page, so a small initializer keeps the change focused and avoids introducing a new framework dependency.
- K2. Preserve the existing visual interaction (up to five stars, click to set, click the same star to clear, hover preview) rather than redesigning the rating UI. Governs R3, R4. This is a maintenance refactor, not a visual redesign.
- K3. Drive the widget from the existing `data-rating-max` attribute. Governs R2, R3, R5. The number of stars remains data-driven.
- K4. Use progressive enhancement: server-render a native form control (radio buttons or a `<select>`) as the no-JS fallback, then enhance it into stars with JavaScript. Governs R2, R5, R6. This makes the form usable and accessible when JavaScript is unavailable or fails.
- K5. Use Bootstrap 5 form utilities (`.form-check-inline` radios) and CSS `::before` content with Unicode star glyphs (`☆` / `★`) for the visual layer. Governs R2, R6. No new image or icon library is needed.

### Requirements

- R1. Remove `app/assets/javascripts/jsimple-star-rating.min.js` and its `//= require` directive from the Sprockets manifest.
- R2. Add a maintainable vanilla JavaScript initializer that progressively enhances the server-rendered `.rating` control into an interactive star-rating widget on the feedback page.
- R3. The initializer must read `data-rating-max` (currently `5`) and render that many clickable stars.
- R4. Clicking a star sets the rating, clicking the already-selected star clears the rating, hovering over stars previews the selection, and leaving the widget restores the selected state.
- R5. The selected rating must be reflected in the underlying native form control so form submission works without additional submit-time JavaScript.
- R6. Remove the inline `:javascript` block and the hidden-input-only approach from `app/views/feedback/show.html.haml`; render a visible, accessible rating control in its place.
- R7. Existing feature and system tests for feedback submission must continue to pass.

### Scope Boundaries

- **Deferred for later:** visual redesign of the rating widget; converting other forms to Stimulus; removing jQuery elsewhere in the app.
- **Outside this product's identity:** changing the feedback model, adding new rating dimensions, or altering what feedback is collected.

### Dependencies / Assumptions

- jQuery remains available for other parts of the app; the new initializer uses native DOM APIs.
- The visual star layer is rendered via CSS `::before` content using Unicode star glyphs, so no image or icon library is required for this component.
- The no-JS fallback uses Bootstrap 5 `.form-check-inline` radio buttons or a `<select>`; Bootstrap 5 is already loaded.
- No new icon library, component library, or build tooling is introduced.
- `app/assets/stylesheets/partials/_star-rating.scss` is the only stylesheet that styles `.rating`; no other view uses that class.

### Acceptance Examples

- AE1. Given a feedback page with no rating selected, when the member clicks the third star, then the rating radio with value `3` is checked and the first three stars display as selected.
- AE2. Given a feedback page with the third star selected, when the member clicks the third star again, then no rating radio is checked and no stars display as selected.
- AE3. Given a feedback page with the third star selected, when the member hovers over the fifth star and then moves the mouse away, then the display returns to three selected stars and the rating radio with value `3` remains checked.

---

## Planning Contract

### Key Technical Decisions

- KTD1. Use radio buttons as the no-JS fallback and enhance them into stars with vanilla JavaScript. (session-settled: user-approved — chosen over hidden-input-only approach: progressive enhancement improves accessibility and resilience, and the existing controller already accepts `feedback[rating]`). Governs R2, R5, R6.
- KTD2. Use CSS `::before` content with Unicode star glyphs for the visual layer. (session-settled: user-approved — chosen over keeping the `star-rating.gif` sprite: removes an image asset and avoids coupling to Font Awesome's SVG-with-JS runtime replacement). Governs R2, R3, U3.
- KTD3. Update the existing feature spec to click the rendered star label or radio input rather than the legacy `<li>` elements. Governs R7, U4.

### Assumptions

- The JS-enabled feature spec runs with a browser driver that executes the initializer before interactions.
- The existing `_star-rating.scss` can be safely reworked because `star-rating.gif` is only used by this component.
- No other form or page reuses the `.rating` class or the `jsimple-star-rating.min.js` plugin.

### Sequencing

1. U1 and U2 can be drafted in either order, but both must be present before U3 styling is finalised.
2. U3 depends on U1 and U2.
3. U4 depends on U1, U2, and U3.

---

## Implementation Units

### U1. Add vanilla-JavaScript star-rating initializer

- **Goal:** Replace the jSimple plugin behaviour with a small native-JS initializer that progressively enhances a `.rating` container.
- **Requirements:** R1, R2, R3, R4
- **Dependencies:** None
- **Files:**
  - `app/assets/javascripts/feedback-rating.js` (create)
  - `app/assets/javascripts/application.js` (modify)
- **Approach:**
  1. Create `app/assets/javascripts/feedback-rating.js`.
  2. On `DOMContentLoaded`, find `.rating` elements.
  3. Read `data-rating-max` to know how many stars to render.
  4. For each star, inject a clickable `<label>` whose star is rendered via CSS `::before` content.
  5. Wire click handlers to check/uncheck the corresponding radio button and toggle `fas`/`far` classes on all labels.
  6. Wire mouseenter/mouseleave to preview and restore the selected state.
  7. Remove `//= require 'jsimple-star-rating.min.js'` from `app/assets/javascripts/application.js` and add `//= require feedback-rating`.
- **Patterns to follow:** Keep the file style consistent with other small initializers in `app/assets/javascripts/` (e.g., `dietary-restrictions.js`, `how-you-found-us.js`).
- **Test scenarios:**
  - Happy path: clicking the third star checks the radio with value `3` and marks stars 1–3 as selected.
  - Toggle off: clicking the already-selected star unchecks every radio and clears selected styling.
  - Hover preview: hovering the fifth star highlights stars 1–5; moving the mouse away restores the checked state.
  - No-JS fallback: with JavaScript disabled, the radio buttons remain visible and submittable.
- **Verification:** The JS-enabled feature spec reaches the rating widget and the browser console shows no errors.

### U2. Replace hidden rating input with radio-button fallback

- **Goal:** Render an accessible native rating control that works without JavaScript and remove the inline JavaScript block.
- **Requirements:** R5, R6
- **Dependencies:** None (can be developed alongside U1)
- **Files:**
  - `app/views/feedback/show.html.haml` (modify)
- **Approach:**
  1. Replace `= f.hidden_field :rating` with a `.rating` container that holds inline radio buttons for values 1 through `data-rating-max`.
  2. Use `f.radio_button :rating, value` for each option, wrapped in `label` tags.
  3. Keep the native radios accessible but visually hidden (Bootstrap's `.visually-hidden` or an equivalent CSS rule) so the star labels are the visible click targets.
  4. Remove the `:javascript` HAML block that initialised the plugin and copied `data-val` on submit.
  5. Preserve the existing `data-rating-max="5"` attribute on `.rating`.
- **Patterns to follow:** Match the existing form's Bootstrap/Simple Form markup; keep the required-field label and abbr.
- **Test scenarios:**
  - Form submits the selected radio value to `FeedbackController#submit`.
  - Validation still fails with "Rating can't be blank" when no radio is selected.
- **Verification:** Controller spec for valid and invalid submissions passes.

### U3. Update star-rating styles to use CSS-generated stars

- **Goal:** Replace the sprite-based star styling with CSS-generated stars and remove the now-unused image asset.
- **Requirements:** R2, R3, R6
- **Dependencies:** U1, U2
- **Files:**
  - `app/assets/stylesheets/partials/_star-rating.scss` (modify)
  - `app/assets/images/star-rating.gif` (delete)
- **Approach:**
  1. Rewrite `.rating` styles so the widget displays inline star labels instead of `<li>` sprites.
  2. Style selected stars with `fas fa-star` and unselected stars with `far fa-star`.
  3. Keep hover preview distinct from selected state using CSS classes driven by the initializer.
  4. Visually hide the native radio inputs while keeping them keyboard-focusable.
  5. Delete `app/assets/images/star-rating.gif`.
- **Patterns to follow:** Keep the existing partial structure; import path in `application.scss` already references `partials/star-rating`.
- **Test scenarios:**
  - Visual state: selected rating shows the correct number of filled stars.
  - Hover state: mouseover highlights stars up to the hovered position without changing the submitted value.
  - No asset 404: precompile succeeds and the deleted sprite is no longer referenced.
- **Verification:** `RAILS_ENV=test bundle exec rails assets:precompile` succeeds and `bundle exec rspec spec/features/member_feedback_spec.rb` passes.

### U4. Update feature test and remove old plugin file

- **Goal:** Remove the abandoned plugin asset and update the test suite to exercise the new widget.
- **Requirements:** R1, R7
- **Dependencies:** U1, U2, U3
- **Files:**
  - `app/assets/javascripts/jsimple-star-rating.min.js` (delete)
  - `spec/features/member_feedback_spec.rb` (modify)
- **Approach:**
  1. Delete `app/assets/javascripts/jsimple-star-rating.min.js`.
  2. In `spec/features/member_feedback_spec.rb`, replace `within('.rating') { all('li').at(3).click }` with a selector that targets the new star label or radio input (e.g., `within('.rating') { choose('feedback_rating_4') }` or clicking the label for the fourth star).
  3. Keep the existing Chosen dropdown waits and success/error assertions unchanged.
- **Patterns to follow:** Use Capybara's label-based or radio-based helpers rather than brittle CSS selectors.
- **Test scenarios:**
  - Covers AE1: selecting a rating and submitting shows the success message.
  - Covers the validation path in the existing spec: omitting the rating still shows "Rating can't be blank".
- **Verification:** `bundle exec rspec spec/features/member_feedback_spec.rb` passes.

---

## Verification Contract

| Gate | Command | Expected outcome |
|---|---|---|
| Unit/controller tests | `bundle exec rspec spec/controllers/feedback_controller_spec.rb spec/models/feedback_spec.rb` | All pass |
| Feature tests | `bundle exec rspec spec/features/member_feedback_spec.rb` | Passes, including the JS-enabled success scenario |
| Style/lint | `bundle exec rubocop app/assets/javascripts/feedback-rating.js app/views/feedback/show.html.haml app/assets/stylesheets/partials/_star-rating.scss spec/features/member_feedback_spec.rb` | No new offenses |
| Asset precompile | `RAILS_ENV=test bundle exec rails assets:precompile` | Succeeds without `star-rating.gif` or the jSimple plugin |

## Definition of Done

- jSimple Star Rating file and its Sprockets require are removed.
- The feedback view contains no inline `:javascript` block.
- The rating widget works without JavaScript (radio fallback) and is enhanced to CSS-generated stars when JavaScript runs.
- All tests in the Verification Contract pass.
- No new runtime dependencies are introduced.
- No `.rating` or `star-rating.gif` references remain outside the updated component.
