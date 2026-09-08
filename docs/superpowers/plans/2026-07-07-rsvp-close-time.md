# RSVP Close Time Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add UI fields and wiring so organisers can set an RSVP closing date/time on workshops.

**Architecture:** Mirror the existing `rsvp_opens_at` pattern — virtual attributes `rsvp_close_local_date`/`rsvp_close_local_time` convert to UTC-stored `rsvp_closes_at` via `datetime_from_fields`. The already-existing `rsvp_available?` method is wired into `available_for_rsvp?` and the invitation-accept path. Admin attendance management is unaffected.

**Tech Stack:** Rails 8.1, HAML, SimpleForm, RSpec

## Global Constraints

- Follow existing patterns: virtual date+time fields, `before_validation` callback, `datetime_from_fields`, timezone-aware getter
- `rsvp_closes_at` nil means RSVPs stay open until workshop starts (current default behaviour)
- Only one validation: close time must be before workshop start time
- `WorkshopInvitationController#accept` uses `workshop.rsvp_available?` to gate
- `Admin::InvitationsController#update` is not gated (organisers bypass)
- Labels on form: "Close RSVPs at"

---
### Task 1: Model Changes

**Files:**
- Modify: `app/models/workshop.rb`
- Test: `spec/models/workshop_spec.rb`

**Interfaces:**
- Consumes: `datetime_from_fields` (already in model), `Workshop#time_zone` (delegated to chapter)
- Produces: `Workshop#rsvp_closes_at` (timezone-aware getter), `Workshop#available_for_rsvp?` (updated)

- [ ] **Step 1: Write the failing model tests**

Add to `spec/models/workshop_spec.rb` in the `context 'time zone fields'` block:

```ruby
context 'rsvp_closes_at' do
  it 'saves the local time in UTC' do
    workshop.update!(
      rsvp_close_local_date: '12/06/2015',
      rsvp_close_local_time: '18:30'
    )

    expect(workshop.read_attribute(:rsvp_closes_at)).to eq(utc_time)
  end

  it 'retrieves the local time from the saved UTC value' do
    workshop.update_attribute(:rsvp_closes_at, utc_time)

    expect(workshop.rsvp_closes_at).to eq(pacific_time)
    expect(workshop.rsvp_closes_at.zone).to eq('PDT')
  end
end
```

Add validation tests in the `validates` block:

```ruby
context '#rsvp_closes_at' do
  it 'must be before the workshop start time' do
    workshop.date_and_time = Time.zone.now + 1.hour
    workshop.rsvp_closes_at = Time.zone.now + 2.hours

    workshop.valid?
    expect(workshop.errors[:rsvp_close_local_date]).to include("must be before the workshop start time")
  end

  it 'is valid when close time is before workshop start' do
    workshop.date_and_time = Time.zone.now + 2.hours
    workshop.rsvp_closes_at = Time.zone.now + 1.hour

    expect(workshop.valid?).to be(true)
  end

  it 'is valid when no close time is set' do
    workshop.rsvp_closes_at = nil
    expect(workshop.valid?).to be(true)
  end
end
```

- [ ] **Step 2: Run model tests to verify they fail**

Run: `bundle exec rspec spec/models/workshop_spec.rb -n 3`
Expected: the new tests fail (methods/virtual attrs not defined), existing tests still pass

- [ ] **Step 3: Implement model changes**

In `app/models/workshop.rb`:

Add `:rsvp_close_local_date, :rsvp_close_local_time` to `attr_accessor`:
```ruby
attr_accessor :local_date, :local_time, :local_end_time, :rsvp_open_local_date, :rsvp_open_local_time,
              :rsvp_close_local_date, :rsvp_close_local_time
```

Add `before_validation :set_closes_at` callback:
```ruby
before_validation :set_date_and_time, :set_end_date_and_time, if: proc { |model| model.chapter_id.present? }
before_validation :set_opens_at
before_validation :set_closes_at
```

Add the timezone-aware getter after the existing `rsvp_opens_at` override:
```ruby
def rsvp_closes_at
  return nil unless super

  super.in_time_zone(time_zone)
end
```

Change `available_for_rsvp?`:
```ruby
def available_for_rsvp?
  invitable_yet? && rsvp_available?
end
```

Add validation and private method in the `private` section, after `set_opens_at`:
```ruby
validate :rsvp_close_before_workshop_start

# ... existing methods ...

def set_closes_at
  new_closes_at = datetime_from_fields(rsvp_close_local_date, rsvp_close_local_time)
  self.rsvp_closes_at = new_closes_at if new_closes_at
end

def rsvp_close_before_workshop_start
  return unless rsvp_closes_at && date_and_time
  return if rsvp_closes_at < date_and_time
  errors.add(:rsvp_close_local_date, "must be before the workshop start time")
end
```

- [ ] **Step 4: Run model tests to verify they pass**

Run: `bundle exec rspec spec/models/workshop_spec.rb -n 3`
Expected: all tests pass

- [ ] **Step 5: Commit**

```bash
git add app/models/workshop.rb spec/models/workshop_spec.rb
git commit -m "feat: add rsvp_closes_at model support with validation"
```

---
### Task 2: Controller + I18n Changes

**Files:**
- Modify: `app/controllers/admin/workshops_controller.rb`, `app/controllers/workshop_invitation_controller.rb`, `config/locales/en.yml`
- Test: `spec/features/accepting_invitation_spec.rb`

**Interfaces:**
- Consumes: `Workshop#rsvp_available?`, I18n key
- Produces: permitted params, gated accept action

- [ ] **Step 1: Write test + implementation together**

Add I18n key to `config/locales/en.yml` under `messages.invitations:` (around line 191):
```yaml
      closed: "RSVPs for this workshop are now closed."
```

Verify YAML: `bundle exec ruby -e "require 'yaml'; YAML.load_file('config/locales/en.yml')"`

Add permitted params to `app/controllers/admin/workshops_controller.rb`, `workshop_params`:
```ruby
:rsvp_open_local_date, :rsvp_open_local_time, :description,
:rsvp_close_local_date, :rsvp_close_local_time,
:coach_spaces, :student_spaces,
```

Add accept guard to `app/controllers/workshop_invitation_controller.rb`, inside `def accept`, after the `already_rsvped` check:
```ruby
return back_with_message(t('messages.already_rsvped')) if @invitation.attending?
return back_with_message(t('messages.invitations.closed')) unless @invitation.workshop.rsvp_available?
```

Add test to `spec/features/accepting_invitation_spec.rb` inside the `context '#workshop'` block:
```ruby
context 'when RSVPs are closed' do
  scenario 'cannot accept an invitation after the close time' do
    invitation.workshop.update(rsvp_closes_at: 1.hour.ago)

    visit invitation_route
    click_on 'Attend'

    expect(page).to have_content('RSVPs for this workshop are now closed.')
    expect(invitation.reload.attending).not_to be(true)
  end
end
```

- [ ] **Step 2: Run the test**

Run: `bundle exec rspec spec/features/accepting_invitation_spec.rb -n 1`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add app/controllers/admin/workshops_controller.rb app/controllers/workshop_invitation_controller.rb config/locales/en.yml spec/features/accepting_invitation_spec.rb
git commit -m "feat: gate invitation acceptance by rsvp_closes_at"
```

---
### Task 3: Form Fields

**Files:**
- Modify: `app/views/admin/workshops/_shared_form.html.haml`
- Test: `spec/controllers/admin/workshops_controller_spec.rb`

**Interfaces:**
- Consumes: `Workshop#rsvp_closes_at` (timezone-aware), `Workshop#rsvp_close_local_date`, `Workshop#rsvp_close_local_time` (virtual attrs)
- Produces: form fields posted in `workshop_params`

- [ ] **Step 1: Write controller param test**

Add to `spec/controllers/admin/workshops_controller_spec.rb` inside the existing `context '#create'` block:

```ruby
it 'permits rsvp_close_local_date and rsvp_close_local_time' do
  expect { post :create, params: { workshop: { rsvp_close_local_date: '01/12/2020', rsvp_close_local_time: '15:00' } } }
    .not_to raise_error(ActionController::UnpermittedParameters)
end
```

- [ ] **Step 2: Add form fields**

In `app/views/admin/workshops/_shared_form.html.haml`, inside the RSVP details card, after the existing `rsvp_open_local_time` field:

```haml
        = f.input :rsvp_close_local_date, label: 'Close RSVPs at', as: :string, input_html: { data: { value: @workshop.rsvp_closes_at.try(:strftime, '%d/%m/%Y') } }
        = f.input :rsvp_close_local_time, label: false, as: :string, input_html: { data: { value: @workshop.rsvp_closes_at.try(:time).try(:strftime, '%H:%M') } }
```

The first field gets the label "Close RSVPs at", the second has no label (time is implied). Matches the existing open-RSVP fields.

- [ ] **Step 3: Run the param test**

Run: `bundle exec rspec spec/controllers/admin/workshops_controller_spec.rb -n 1`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add app/views/admin/workshops/_shared_form.html.haml spec/controllers/admin/workshops_controller_spec.rb
git commit -m "feat: add RSVP close time fields to workshop form"
```

---
### Task 4: Final Verification

- [ ] **Step 1: Run full test suite**

Run: `bundle exec parallel_rspec spec/ -n 3`
Expected: all tests pass

- [ ] **Step 2: Commit any final fixes**

```bash
git add -A
git commit -m "chore: fix test adjustments after full suite run"
```
