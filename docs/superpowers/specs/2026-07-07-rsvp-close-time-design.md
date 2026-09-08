# RSVP Close Time for Workshops

## Problem

Workshop RSVPs don't close automatically. Students and coaches can RSVP after
3pm on the day of the workshop if capacity hasn't been reached, causing
last-minute pairing and venue security issues.

## Current State

- The `workshops` table already has an `rsvp_closes_at` datetime column
- `Workshop#rsvp_available?` checks it but is **never called** — it's dead code
- The active RSVP gating is `available_for_rsvp?` which only checks
  `invitable_yet? && date_and_time.future?`
- There's already a pattern for local-date/local-time virtual attributes
  (`rsvp_open_local_date`, `rsvp_open_local_time`) that convert to UTC via
  `DateTimeConcerns#datetime_from_fields`
- The admin workshop form has fields for "Open RSVPs at" but no close counterpart

## Design

### Model (`app/models/workshop.rb`)

**Virtual attributes** — added to `attr_accessor`:
- `rsvp_close_local_date` (String, DD/MM/YYYY)
- `rsvp_close_local_time` (String, HH:MM)

**Callback** — added to the existing `before_validation` list:
```ruby
before_validation :set_closes_at
```

**Private method** (same pattern as `set_opens_at`):
```ruby
def set_closes_at
  new_closes_at = datetime_from_fields(rsvp_close_local_date, rsvp_close_local_time)
  self.rsvp_closes_at = new_closes_at if new_closes_at
end
```

**Timezone-aware getter** (same pattern as `rsvp_opens_at`):
```ruby
def rsvp_closes_at
  return nil unless super
  super.in_time_zone(time_zone)
end
```

**Validation:**
Close time must be before workshop start time (when both are present).

```ruby
validate :rsvp_close_before_workshop_start

def rsvp_close_before_workshop_start
  return unless rsvp_closes_at && date_and_time
  return if rsvp_closes_at < date_and_time
  errors.add(:rsvp_close_local_date, "must be before the workshop start time")
end
```

**Gating change** — wire the existing `rsvp_available?` into the RSVP flow:
```ruby
def available_for_rsvp?
  invitable_yet? && rsvp_available?
end
```

`rsvp_available?` already handles the nil case (returns `future?`, i.e. workshop
date/time is still in the future) so existing workshops without a close time are
unaffected.

### Controller (`app/controllers/admin/workshops_controller.rb`)

Add params to `workshop_params`:
```ruby
:rsvp_close_local_date, :rsvp_close_local_time
```

### Controller (`app/controllers/workshop_invitation_controller.rb`)

Guard in `accept` action, after the `already_rsvped` check, before anything else:
```ruby
return back_with_message(t('messages.invitations.closed')) unless workshop.rsvp_available?
```

Reject/update actions remain ungated — people who RSVP'd before close can still
change their status or cancel.

### View (`app/views/admin/workshops/_shared_form.html.haml`)

In the RSVP details card, after the existing open-RSVP fields:
```haml
= f.input :rsvp_close_local_date, as: :string, input_html: { data: { value: @workshop.rsvp_closes_at.try(:strftime, '%d/%m/%Y') } }
= f.input :rsvp_close_local_time, as: :string, input_html: { data: { value: @workshop.rsvp_closes_at.try(:time).try(:strftime, '%H:%M') } }
```

Labels: "Close RSVPs at" (for both fields, date then time).

### I18n (`config/locales/en.yml`)

Add message key:
```yaml
messages:
  invitations:
    closed: "RSVPs for this workshop are now closed."
```

### Admin bypass

The `Admin::InvitationsController#update` path is authorised via Pundit and
already allows organisers/admins to add or remove attendees regardless of
RSVP state. No changes needed.

## Tests

- **Workshop model (timezone context)**: add `rsvp_closes_at` getter/setter
  tests mirroring the existing `rsvp_opens_at` tests
- **Workshop model (validation)**: test close time must be before workshop start
- **Workshop model (`rsvp_available?`)**: existing tests already cover the
  `rsvp_closes_at` logic; confirm they hold after wiring
- **Controller (`workshop_invitation`)**: test that `accept` is blocked when
  `rsvp_available?` returns false
- **Feature/admin**: test that the new form fields render in the create and
  edit workshop pages

## Files Changed

1. `app/models/workshop.rb` — virtual attrs, callback, getter, validations, gating
2. `app/controllers/admin/workshops_controller.rb` — permitted params
3. `app/controllers/workshop_invitation_controller.rb` — accept guard
4. `app/views/admin/workshops/_shared_form.html.haml` — form fields
5. `config/locales/en.yml` — message key
6. `spec/models/workshop_spec.rb` — model tests
7. `spec/controllers/workshop_invitation_controller_spec.rb` — controller guard test
8. `spec/features/admin/manage_workshop_spec.rb` — form field test
