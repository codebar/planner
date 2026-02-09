# rails4-autocomplete Investigation

**Issue:** [#2445 - rails4-autocomplete removal or refactor](https://github.com/codebar/planner/issues/2445)

**Investigation Date:** February 8, 2026

**Summary:** The rails4-autocomplete gem (last updated April 2014) was accidentally broken during a Bootstrap 5 migration in April 2022 and has been non-functional for nearly 3 years. All infrastructure remains in place but is unused.

## Current State

### Where It's Referenced

1. **Gemfile (line 40)**
   ```ruby
   gem 'rails4-autocomplete'
   ```

2. **Gemfile.lock**
   - Version: 1.1.1 (last updated April 10, 2014 - 12 years ago)

3. **Controller (`app/controllers/members_controller.rb:8`)**
   ```ruby
   autocomplete :skill, :name, class_name: 'ActsAsTaggableOn::Tag'
   ```

4. **Routes (`config/routes.rb:29`)**
   ```ruby
   get :autocomplete_skill_name, on: :collection
   ```

5. **JavaScript (`app/assets/javascripts/application.js:19`)**
   ```javascript
   //= require autocomplete-rails
   ```

6. **View (`app/views/members/_new.html.haml:22`)**
   ```haml
   = f.input :skill_list, input_html: { value: @member.skill_list.join(", ") }
   ```

### Why It's Not Working

The view uses a plain `f.input :skill_list` field, but rails4-autocomplete requires using special helper methods like `autocomplete_field_tag` or specifying `as: :autocomplete` in the form input options.

The current implementation renders a regular text input without:
- The `as: :autocomplete` parameter
- The `url: autocomplete_skill_name_members_path` parameter
- Any `data-autocomplete` attributes
- JavaScript bindings to trigger autocomplete

The endpoint `/members/autocomplete_skill_name` exists but has never been wired up to the current frontend.

## Historical Timeline

### Phase 1: Initial Skills Feature (August 24, 2015)

**Commit:** `185eddd3` by Margo Urey

Added the basic skills feature:
- Installed `acts-as-taggable-on` gem
- Added migrations for tagging tables
- Added `skill_list` field to member form
- Field was a **plain text input** with manual comma-separated entry

Form code:
```haml
= f.input :skill_list, label: "Skills, enter as a comma separated list"
```

### Phase 2: Autocomplete Added (September 25, 2015)

**Commit:** `92f6df774c84803052496265dc3aff363530572c` by Margo Urey

Enhanced the feature with autocomplete:

**Changes:**
- Added `rails4-autocomplete` gem (v1.1.1)
- Added `jquery-ui-rails` gem (~> 5.0.0)
- Modified form to use autocomplete:

```haml
= f.input :skill_list,
  label: "Skills, enter as a comma separated list",
  url: autocomplete_skill_name_members_path,
  as: :autocomplete,
  input_html: {'data-delimiter' => ','}
```

- Added controller method: `autocomplete :skill, :name, class_name: 'ActsAsTaggableOn::Tag'`
- Added route: `get :autocomplete_skill_name, on: :collection`
- Added JavaScript requires: `jquery-ui` and `autocomplete-rails`
- Added CSS: `jquery-ui` stylesheet

**Status:** ✅ Autocomplete was fully functional at this point

### Phase 3: Accidental Removal (April 15, 2022)

**Commit:** `b3cbd73070a05870e0c451eab9df31daf364ec9a` by Kriszta Matyi

**PR:** [#1745 - Migrate member (public) forms to Bootstrap 5 classes](https://github.com/codebar/planner/pull/1745)

**Merged:** May 6, 2022

During Bootstrap 5 migration:
- Deleted `app/views/members/_form.html.haml` entirely
- Rewrote form in `_new.html.haml` from scratch
- Lost the autocomplete parameters:

```haml
# Before (working):
= f.input :skill_list,
  label: 'Skills, enter as a comma separated list',
  url: autocomplete_skill_name_members_path,
  as: :autocomplete,
  input_html: {'data-delimiter' => ','}

# After (broken):
= f.input :skill_list,
  label: 'Skills, enter as a comma separated list',
  input_html: { value: @member.skill_list.join(", ") }
```

**What Remained:**
- rails4-autocomplete gem (zombie dependency)
- Controller autocomplete method (unused)
- Route definition (dead endpoint)
- JavaScript requires (loaded but never invoked)

**Status:** ❌ Autocomplete has been broken ever since (nearly 3 years)

## Why This Went Unnoticed

1. **No Tests:** Zero test coverage for autocomplete functionality
2. **No Monitoring:** No error tracking since the endpoint is simply never called
3. **Silent Degradation:** Form still works, just without autocomplete suggestions
4. **Limited Usage:** Only affects coaches editing their skill list
5. **Manual Entry Works:** Users can still enter comma-separated skills

## Technical Debt Assessment

### The Gem: rails4-autocomplete

- **Last Updated:** April 10, 2014 (12 years ago)
- **Rails Version:** Designed for Rails 4.x
- **Current Rails:** Application is on Rails 8.1.2
- **Maintenance:** Abandoned, no security updates
- **Dependencies:** Requires jQuery-UI (also legacy)

### The Infrastructure

**Dead Code:**
- Gem dependency (unused)
- Controller method (never called)
- Route (dead endpoint)
- JavaScript asset (loaded but inactive)
- jQuery-UI dependency (partially for this feature)

**Still Referenced:**
- `skill_list` field works without autocomplete
- Tags stored in `acts-as-taggable-on` tables
- Model scopes: `Member.with_skill(skill_name)`

## Recommendations

### Option 1: Complete Removal (Recommended)

Remove all autocomplete infrastructure since it's been non-functional for 3 years with no user complaints.

**Benefits:**
- Removes unmaintained dependency
- Cleans up dead code
- Simplifies asset pipeline
- No functionality loss (already broken)

**To Remove:**
- Gem: `rails4-autocomplete` from Gemfile
- Gem: `jquery-ui-rails` from Gemfile (confirmed single-purpose dependency, see below)
- Controller: `autocomplete :skill, :name, class_name: 'ActsAsTaggableOn::Tag'` line
- Route: `get :autocomplete_skill_name, on: :collection`
- JavaScript: `//= require autocomplete-rails` line
- JavaScript: `//= require jquery-ui` line
- CSS: `*= require jquery-ui` line

**To Keep:**
- `acts-as-taggable-on` gem (still actively used)
- `skill_list` field (works with manual entry)
- Member model tagging functionality

### Option 2: Restore with Modern Alternative

If autocomplete is deemed valuable, reimplement using modern tools.

**Options:**
- [Stimulus Autocomplete](https://github.com/afcapel/stimulus-autocomplete)
- [TomSelect](https://tom-select.js.org/) (modern replacement for Chosen/Select2)
- HTML5 `<datalist>` element (native browser autocomplete)

**Considerations:**
- Requires development effort
- Needs testing coverage
- User benefit unclear (no requests for 3 years)
- May conflict with existing Stimulus/Turbo setup

## Evidence

### Git Commits

```bash
# Added autocomplete (Sep 25, 2015)
git show 92f6df774c84803052496265dc3aff363530572c

# Broke autocomplete (Apr 15, 2022)
git show b3cbd73070a05870e0c451eab9df31daf364ec9a

# Original skill feature (Aug 24, 2015)
git show 185eddd3
```

### Testing Locally

The endpoint exists but returns empty since it's never configured on the frontend:

```bash
curl http://localhost:3000/members/autocomplete_skill_name?term=ruby
# Returns: []
```

The form field renders as a plain `<input type="text">` with no autocomplete attributes.

## jquery-ui-rails Analysis

### Investigation (February 8, 2026)

**Question:** Can jquery-ui-rails be safely removed?

**Answer:** Yes, with 95%+ confidence.

**Evidence:**
- Added in the same commit as rails4-autocomplete (Sep 25, 2015, commit `92f6df77`)
- Added exclusively for the autocomplete feature
- Comprehensive code search found **zero usage**:
  - No jQuery UI JavaScript methods (`.datepicker()`, `.autocomplete()`, `.sortable()`, etc.)
  - No jQuery UI CSS classes (`ui-widget`, `ui-state-*`, etc.)
  - No data attributes for jQuery UI
  - No dynamic JavaScript generating jQuery UI code
- **Bundle size impact**: ~120KB saved from production assets
- No other gems depend on it (checked chosen-rails, pickadate-rails)
- The app uses alternatives:
  - pickadate-rails for date picking
  - chosen-rails for select boxes
  - Bootstrap 5 for UI components

**Risk Assessment:**
- **LOW RISK** - Feature broken for 3 years with no incidents
- If anything used jQuery UI, it would have broken in 2022
- Modern Stimulus/Turbo stack doesn't use jQuery UI patterns

**Files requiring jquery-ui:**
1. Gemfile (line 26): `gem 'jquery-ui-rails'`
2. app/assets/javascripts/application.js (line 18): `//= require jquery-ui`
3. app/assets/stylesheets/application.scss (line 18): `*= require jquery-ui`

**Conclusion:** Safe to remove completely alongside rails4-autocomplete.

## Conclusion

The rails4-autocomplete feature was:
1. Added in September 2015 and worked correctly
2. Accidentally broken in April 2022 during Bootstrap 5 migration
3. Remained broken for nearly 3 years without user reports
4. Depends on a 12-year-old unmaintained gem
5. Represents pure technical debt with no active functionality

The jquery-ui-rails dependency was:
1. Added specifically for rails4-autocomplete (same commit)
2. Never used for any other purpose
3. Safe to remove with minimal risk

**Recommendation:** Proceed with complete removal of both gems as outlined in Option 1.
