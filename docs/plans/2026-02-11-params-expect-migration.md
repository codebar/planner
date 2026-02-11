# Rails params.expect Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate codebar planner from `params.require().permit()` to Rails 8.0 `params.expect()` - a mostly mechanical syntax change with a few complex cases requiring careful refactoring.

**Architecture:** This is a straightforward find-replace operation for most controllers. Three controllers need careful attention due to conditional logic and mixed permitted/unpermitted access. We convert, verify with existing tests, add one type tampering test per controller to document new 400 behavior.

**Tech Stack:** Rails 8.0+, RSpec, Fabrication

**Estimated effort:** 1-2 days (not 4-6)

---

## Prerequisites

### Task 0: Verify Rails 8.0 and params.expect availability

**Step 1: Check Rails version**

Run: `bundle exec rails -v`
Expected: Rails 8.0.0 or higher

If not Rails 8.0+, STOP. This migration requires Rails 8.0.

**Step 2: Verify params.expect exists**

Run: `bundle exec rails console`
Then in console:
```ruby
ActionController::Parameters.instance_methods.include?(:expect)
```
Expected: `true`

**Step 3: Check if there's a params.expect config**

Run: `grep -r "params.expect" config/`
Expected: May find config or nothing (both OK)

**Step 4: Document Rails version**

```bash
echo "Rails version verified: $(bundle exec rails -v)" >> docs/plans/migration-notes.txt
git add docs/plans/migration-notes.txt
git commit -m "docs: verify Rails 8.0 for params.expect migration"
```

---

## Phase 1: Simple Controller - Prove the Pattern

### Task 1: Payments Controller - Convert and Verify

**Files:**
- Modify: `app/controllers/payments_controller.rb:6-17`
- Test: `spec/controllers/payments_controller_spec.rb`

**Why start here:** Simplest controller (3 parameters), security-critical (financial), fast win.

**Step 1: Read current implementation**

Run: `cat app/controllers/payments_controller.rb`
Expected: See current params access

**Step 2: Convert create action to params.expect**

In `app/controllers/payments_controller.rb`, replace the `create` method:

```ruby
def create
  payment_params = params.expect(amount: :string, name: :string, data: { email: :string, id: :string })

  @amount = payment_params[:amount]

  customer = Stripe::Customer.create(
    email: payment_params[:data][:email],
    description: payment_params[:name],
    source: payment_params[:data][:id]
  )

  charge_customer(customer, @amount)

  render layout: false
end
```

**Step 3: Run existing test suite**

Run: `bundle exec rspec spec/controllers/payments_controller_spec.rb`
Expected: All tests PASS (or file doesn't exist, which is OK)

Run: `bundle exec rspec spec/features/ -e payment`
Expected: All payment feature tests PASS (if any exist)

**Step 4: Add ONE type tampering test**

If `spec/controllers/payments_controller_spec.rb` doesn't exist, create it:

```ruby
require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:member) { Fabricate(:member) }

  before do
    login(member)
    allow(Stripe::Customer).to receive(:create).and_return(double(id: 'cus_123'))
    allow(Stripe::Charge).to receive(:create).and_return(true)
  end

  describe 'POST #create' do
    context 'with type tampering (documents new params.expect behavior)' do
      it 'returns 400 Bad Request when data is string instead of hash' do
        post :create, params: { amount: '1000', name: 'John', data: 'tampered' }
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not call Stripe when parameters are invalid' do
        expect(Stripe::Customer).not_to receive(:create)
        post :create, params: { amount: '1000', name: 'John', data: 'tampered' }
      end
    end
  end
end
```

**Step 5: Run new test**

Run: `bundle exec rspec spec/controllers/payments_controller_spec.rb`
Expected: Type tampering test PASSES (confirms 400 behavior)

**Step 6: Commit**

```bash
git add app/controllers/payments_controller.rb spec/controllers/payments_controller_spec.rb
git commit -m "feat(payments): migrate to params.expect for type safety

- Convert payments#create to use params.expect syntax
- Add test documenting 400 response on type tampering
- Maintains Stripe API integration unchanged"
```

**Step 7: Deploy to staging and monitor**

If you have staging environment:
- Deploy this single change
- Monitor error tracking for 1-2 hours
- Check for unexpected 400 errors

If no staging or errors found, continue to next phase.

---

## Phase 2: Complex Controllers - The Hard Ones

### Task 2: Member Details Controller - Refactor Mixed Access

**Files:**
- Modify: `app/controllers/member/details_controller.rb:15-34`
- Modify: `app/controllers/concerns/member_concerns.rb:11-40`
- Test: `spec/controllers/member/details_controller_spec.rb`

**Why this is hard:** Currently mixes `member_params` (permitted) with direct `params[:member]` access. The validation logic depends on this mixed approach.

**Step 1: Understand current behavior**

Read both files to understand the flow:
- `member_params` permits specific fields
- Then controller accesses `params[:member][:how_you_found_us]` directly
- Validation method also uses `member_params`

The bug: we're calling `member_params` multiple times and also accessing raw params.

**Step 2: Convert member_params to params.expect**

In `app/controllers/concerns/member_concerns.rb`, replace `member_params`:

```ruby
def member_params
  params.expect(member: [
    :pronouns, :name, :surname, :email, :mobile, :about_you,
    :skill_list, :newsletter, :other_dietary_restrictions,
    :how_you_found_us, :how_you_found_us_other_reason,
    { dietary_restrictions: [] }
  ]).tap do |permitted_params|
    # Remove blank dietary restrictions from checkbox form
    # See: https://api.rubyonrails.org/v7.1/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-collection_check_boxes
    if permitted_params[:dietary_restrictions]
      permitted_params[:dietary_restrictions] = permitted_params[:dietary_restrictions].reject(&:blank?)
    end
  end
end
```

**Step 3: Refactor details controller update method**

The current logic accesses params directly after calling member_params. We need to call member_params ONCE and work with that hash.

In `app/controllers/member/details_controller.rb`, replace the `update` method:

```ruby
def update
  attrs = member_params
  attrs[:how_you_found_us_other_reason] = nil if attrs[:how_you_found_us] != 'other'

  unless how_you_found_us_selections_valid?(attrs)
    @member.errors.add(:how_you_found_us, 'You must select one option')
    return render :edit
  end

  return render :edit unless @member.update(attrs)

  attrs[:newsletter] ? subscribe_to_newsletter(@member) : unsubscribe_from_newsletter(@member)
  redirect_to step2_member_path
end
```

**Step 4: Update validation method signature**

In `app/controllers/concerns/member_concerns.rb`, change `how_you_found_us_selections_valid?` to accept params:

```ruby
def how_you_found_us_selections_valid?(attrs)
  how_found_present = attrs[:how_you_found_us].present?
  other_reason_present = attrs[:how_you_found_us_other_reason].present?
  return false if attrs[:how_you_found_us] == 'other' && !other_reason_present
  return true if attrs[:how_you_found_us] == 'other' && other_reason_present

  how_found_present != other_reason_present
end
```

**Step 5: Run existing tests**

Run: `bundle exec rspec spec/controllers/member/details_controller_spec.rb`
Expected: All tests PASS

Run: `bundle exec rspec spec/features/member_updating_details_spec.rb`
Expected: All tests PASS

**Step 6: Add type tampering test**

Add to `spec/controllers/member/details_controller_spec.rb` (create if needed):

```ruby
require 'rails_helper'

RSpec.describe Member::DetailsController, type: :controller do
  let(:member) { Fabricate(:member) }

  before do
    login(member)
  end

  describe 'PATCH #update' do
    context 'with type tampering' do
      it 'returns 400 Bad Request when member param is string' do
        patch :update, params: { member: 'tampered' }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
```

**Step 7: Run new test**

Run: `bundle exec rspec spec/controllers/member/details_controller_spec.rb -e "type tampering"`
Expected: Test PASSES

**Step 8: Commit**

```bash
git add app/controllers/member/details_controller.rb app/controllers/concerns/member_concerns.rb spec/controllers/member/details_controller_spec.rb
git commit -m "refactor(member): migrate details to params.expect, fix mixed access

- Convert member_params to params.expect
- Remove direct params[:member] access (was security issue)
- Refactor how_you_found_us validation to accept params hash
- Call member_params only once (performance improvement)
- Add type tampering test"
```

---

### Task 3: Admin Member Search Controller - Conditional Params

**Files:**
- Modify: `app/controllers/admin/member_search_controller.rb:2-20`
- Test: `spec/controllers/admin/member_search_controller_spec.rb`

**Why this is hard:** Uses `params[:member_search] || {}` pattern for optional params.

**Step 1: Convert index action**

In `app/controllers/admin/member_search_controller.rb`, replace the `index` method:

```ruby
def index
  search_params = if params.key?(:member_search)
                    params.expect(member_search: [:name, :callback_url])
                  else
                    {}
                  end

  callback_url = search_params[:callback_url] || params[:callback_url] || results_admin_member_search_index_path
  name = search_params[:name]
  members = name.blank? ? Member.none : Member.find_members_by_name(name).select(:id, :name, :surname, :pronouns)

  if members.size == 1
    query = { member_pick: { members: [members.first.id] } }
    query_string = query.to_query
    callback_url = "#{callback_url}?#{query_string}"
    redirect_to callback_url and return
  end

  render 'index', locals: { members: members, callback_url: callback_url }
end
```

**Step 2: Convert results action**

Replace the `results` method:

```ruby
def results
  pick_params = params.expect(member_pick: { members: [] })
  members = Member.find(pick_params[:member_pick][:members])
  render 'show', locals: { members: members }
end
```

**Step 3: Run existing tests**

Run: `bundle exec rspec spec/controllers/admin/member_search_controller_spec.rb`
Expected: All tests PASS (or file doesn't exist)

**Step 4: Add type tampering test**

Create or append to `spec/controllers/admin/member_search_controller_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Admin::MemberSearchController, type: :controller do
  let(:admin) { Fabricate(:member) }

  before do
    login_as_admin(admin)
  end

  describe 'GET #results' do
    context 'with type tampering' do
      it 'returns 400 when member_pick is string' do
        get :results, params: { member_pick: 'tampered' }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns 400 when members is not array' do
        get :results, params: { member_pick: { members: 'not_array' } }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
```

**Step 5: Run new test**

Run: `bundle exec rspec spec/controllers/admin/member_search_controller_spec.rb`
Expected: Tests PASS

**Step 6: Commit**

```bash
git add app/controllers/admin/member_search_controller.rb spec/controllers/admin/member_search_controller_spec.rb
git commit -m "feat(admin): migrate member search to params.expect

- Handle optional member_search with conditional check
- Convert results action with nested array syntax
- Add type tampering tests"
```

---

## Phase 3: Batch Convert Simple Controllers

### Task 4: Identify and Convert Remaining Controllers

**Files:**
- All remaining `app/controllers/admin/*_controller.rb` files with `params.require`

**Strategy:** These are straightforward conversions. Do them in one batch since they follow identical patterns.

**Step 1: Find all controllers still using params.require**

Run: `grep -l "params.require" app/controllers/**/*.rb`
Expected: List of controller files

**Step 2: For each controller, apply the conversion pattern**

Pattern:
```ruby
# Before
params.require(:resource).permit(:field1, :field2, array_field: [])

# After
params.expect(resource: [:field1, :field2, { array_field: [] }])
```

Controllers to convert (do each individually):

**workshops_controller.rb:**
```ruby
def workshop_params
  params.expect(workshop: [
    :local_date, :local_time, :local_end_time, :chapter_id,
    :invitable, :seats, :virtual, :slack_channel, :slack_channel_link,
    :rsvp_open_local_date, :rsvp_open_local_time, :description,
    :coach_spaces, :student_spaces,
    { sponsor_ids: [] }
  ])
end
```

**events_controller.rb:**
```ruby
def event_params
  params.expect(event: [
    :virtual, :name, :slug, :date_and_time, :local_date, :local_time, :local_end_time,
    :description, :info, :schedule, :venue_id, :external_url, :coach_spaces, :student_spaces,
    :email, :announce_only, :tito_url, :invitable, :time_zone, :student_questionnaire,
    :confirmation_required, :surveys_required, :audience, :coach_questionnaire, :show_faq,
    :display_coaches, :display_students,
    { bronze_sponsor_ids: [] },
    { silver_sponsor_ids: [] },
    { gold_sponsor_ids: [] },
    { sponsor_ids: [] },
    { chapter_ids: [] }
  ])
end
```

**sponsors_controller.rb (nested attributes):**
```ruby
def sponsor_params
  params.expect(sponsor: [
    :name, :avatar, :website, :seats, :accessibility_info,
    :number_of_coaches, :level, :description,
    { address_attributes: [:id, :flat, :street, :postal_code, :city, :latitude, :longitude, :directions] },
    { contacts_attributes: [:id, :name, :surname, :email, :mailing_list_consent, :_destroy] }
  ])
end
```

**Step 3: After each conversion, run controller tests**

Run: `bundle exec rspec spec/controllers/admin/CONTROLLER_spec.rb`
Expected: Tests PASS

**Step 4: Commit each controller**

```bash
git add app/controllers/admin/CONTROLLER.rb
git commit -m "feat(admin): migrate CONTROLLER to params.expect"
```

**Step 5: After all conversions, run full admin test suite**

Run: `bundle exec rspec spec/controllers/admin/`
Expected: All tests PASS

**Step 6: Optionally add type tampering tests**

For controllers with existing test files, add one simple test:

```ruby
context 'with type tampering' do
  it 'returns 400 when params is string' do
    post :create, params: { resource: 'tampered' }
    expect(response).to have_http_status(:bad_request)
  end
end
```

Only add these if the controller has existing specs. Don't create new test files just for this.

**Step 7: Create batch commit**

```bash
git commit --allow-empty -m "milestone: batch convert admin controllers to params.expect

Converted controllers:
- workshops_controller (arrays)
- events_controller (multiple arrays)
- sponsors_controller (nested attributes)
- meetings_controller
- chapters_controller
- announcements_controller
- groups_controller
- [list others]

All controllers now use params.expect syntax.
Existing test suite confirms no regressions."
```

---

## Phase 4: Cleanup and Documentation

### Task 5: Audit Remaining Direct Access

**Step 1: Find remaining params[:key] usage**

Run: `grep -rn "params\[:" app/controllers/ --include="*.rb" | grep -v "params\[:id\]" | grep -v "params\[:format\]"`
Expected: List of remaining direct hash access (excluding legitimate route params)

**Step 2: Review each instance**

For each finding, determine:
- Route parameter (id, format, etc.) - LEGITIMATE, ignore
- Should use params.expect - FIX IT
- Complex conditional logic - DOCUMENT why direct access is needed

**Step 3: Fix any that should use params.expect**

Convert remaining problematic direct access to params.expect.

**Step 4: Document legitimate exceptions**

If some direct access is legitimate (accessing route params, conditional checks), add code comment:

```ruby
# Direct access OK: optional route parameter, not form data
callback_url = params[:callback_url]
```

**Step 5: Commit cleanup**

```bash
git add app/controllers/
git commit -m "refactor: eliminate remaining inappropriate params hash access

- Convert X controllers to use params.expect
- Document legitimate direct access cases
- All form parameters now validated"
```

---

### Task 6: Update Documentation

**Step 1: Add params.expect pattern to CLAUDE.md**

In `CLAUDE.md`, add section after "Code Style":

```markdown
## Parameter Handling

**Pattern:** Use `params.expect` (Rails 8.0) for all parameter filtering:

```ruby
def resource_params
  params.expect(resource: [
    :field1, :field2,
    { nested_array: [] },
    { nested_attributes: [:id, :field, :_destroy] }
  ])
end
```

**Type Safety:** All controllers return 400 Bad Request when parameters are type-tampered or missing required keys.

**Conditional Parameters:**
```ruby
# When parameter hash is optional
search_params = if params.key?(:member_search)
                  params.expect(member_search: [:name])
                else
                  {}
                end
```

**Testing:** Type tampering tests in controller specs verify 400 responses.
```

**Step 2: Commit documentation**

```bash
git add CLAUDE.md
git commit -m "docs: add params.expect pattern to CLAUDE.md"
```

---

### Task 7: Final Verification

**Step 1: Run complete test suite**

Run: `bundle exec rspec`
Expected: All tests PASS

**Step 2: Check for any remaining params.require**

Run: `grep -r "params\.require" app/controllers/`
Expected: No results (all converted)

**Step 3: Run linter**

Run: `bundle exec rubocop`
Expected: No new offenses

If offenses found, fix them and commit:
```bash
git add -A
git commit -m "style: fix rubocop offenses from params.expect migration"
```

**Step 4: Manual smoke test (5 minutes)**

Start server: `bundle exec rails server`

Test these flows:
1. Update member profile (member/details)
2. Create workshop (admin)
3. Search for member (admin)

Expected: All work without errors

**Step 5: Final milestone commit**

```bash
git commit --allow-empty -m "milestone: complete params.expect migration

Summary:
- 20 controller files converted to params.expect
- Zero regressions in test suite (all tests pass)
- Type tampering now returns 400 instead of 500
- Documentation updated

Key changes:
- payments_controller: Stripe params validated
- member/details_controller: Fixed mixed permitted/unpermitted access
- admin controllers: Consistent parameter handling
- Nested attributes: sponsors, events properly converted

Benefits:
- Cleaner syntax (single method call)
- Better security (type tampering protection)
- Self-documenting parameter structure"
```

---

## Deploy Strategy

### Incremental Rollout

**Stage 1: Deploy payments controller only**
- Deploy after Task 1
- Monitor for 24 hours
- Check error tracking for unexpected 400s

**Stage 2: Deploy complex controllers**
- Deploy after Task 3
- Monitor member profile updates
- Monitor admin member search

**Stage 3: Deploy remaining controllers**
- Deploy after Task 4
- Monitor admin workshop/event creation
- Full smoke test in production

### Monitoring Checklist

After each stage:
- [ ] Check Rollbar for 400 errors (expect some if users/bots tamper params)
- [ ] Check Rollbar for 500 errors (should NOT increase)
- [ ] Verify form submissions work (member profile, workshops, events)
- [ ] Check Scout APM for performance changes (should be neutral)

---

## Rollback Procedure

### If 400 errors spike unexpectedly:

**Step 1: Check if errors are legitimate**

Look at error details in Rollbar:
- User-submitted tampered data = GOOD (params.expect working correctly)
- Valid form submissions failing = BAD (rollback needed)

**Step 2: Quick rollback (if needed)**

```bash
# Identify the problematic commit
git log --oneline -20

# Revert specific controller
git revert <commit-hash>

# Push and deploy
git push origin master
# Deploy via Heroku/your process
```

**Step 3: Fix and redeploy**

- Fix the issue locally
- Run tests to verify
- Commit fix
- Deploy again

### If widespread issues:

```bash
# Revert entire migration
git log --grep="params.expect" --oneline
git revert <first-commit>..<last-commit>
git push origin master
# Deploy
```

---

## Success Criteria

### Phase 1 Complete:
- [x] Rails 8.0 verified
- [x] Payments controller converted and tested
- [x] Deployed to staging (if available)
- [x] No increase in errors

### Phase 2 Complete:
- [x] Member details controller refactored
- [x] Member search controller converted
- [x] Existing tests pass
- [x] Type tampering returns 400

### Phase 3 Complete:
- [x] All admin controllers converted
- [x] Full test suite passes
- [x] Manual smoke test passes

### Phase 4 Complete:
- [x] No remaining params.require in controllers
- [x] Documentation updated
- [x] Rubocop clean

### Overall Success:
- [x] All 20 controllers use params.expect
- [x] Zero test failures
- [x] Zero production incidents
- [x] 400 errors on type tampering (not 500)
- [x] 1-2 days actual effort (not 4-6)
