# WorkshopInvitationController Refactor Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Inline `InvitationControllerConcerns` into `InvitationController`, rename the controller to `WorkshopInvitationController`, add dual routes, and delete the unused concern file.

**Architecture:** Merge the concern's `accept` and `reject` actions directly into the controller, include `WorkshopInvitationConcerns` directly (since `WaitingListsController` still uses it), rename the class, and add a new route while keeping the old one for backwards compatibility.

**Tech Stack:** Rails 8, Ruby, HAML views

---

## File Structure

### Files to Modify:
- `app/controllers/invitation_controller.rb` → inline + rename to `workshop_invitation_controller.rb`
- `config/routes.rb` → add new route while keeping old one
- `app/views/invitations/index.html.haml` → update route helpers
- `app/controllers/workshops_controller.rb` → update route helpers
- `app/controllers/events_controller.rb` → update route helpers

### Files to Delete:
- `app/controllers/concerns/invitation_controller_concerns.rb`

### Test Files (no changes needed - backwards compatibility):
- Feature specs use `invitation_path` which will still work via old route

---

## Chunk 1: Inline concerns and rename controller

### Task 1: Inline concerns into controller and rename to WorkshopInvitationController

**Files:**
- Modify: `app/controllers/invitation_controller.rb` → create new file `app/controllers/workshop_invitation_controller.rb`
- Delete: `app/controllers/invitation_controller.rb`

**Steps:**

- [ ] **Step 1: Create new WorkshopInvitationController with inlined code**

```ruby
# app/controllers/workshop_invitation_controller.rb
class WorkshopInvitationController < ApplicationController
  include WorkshopInvitationConcerns

  # NOTE: This controller handles workshop invitations (WorkshopInvitation model).
  # It provides accept/reject RSVP actions for workshop attendees via token-based links.
  # Routes: /invitation/:token (legacy) and /workshop_invitation/:token

  def show
    @announcements = @invitation.member.announcements.active
    @tutorial_titles = Tutorial.all_titles

    @workshop = WorkshopPresenter.decorate(@invitation.workshop)

    render plain: @workshop.attendees_csv if request.format.csv?
  end

  def update
    @invitation.assign_attributes(invitation_params.merge!(attending: true, rsvp_time: Time.zone.now))
    return back_with_message(@invitation.errors.full_messages) unless @invitation.valid?

    @invitation.update(invitation_params)
    back_with_message(t('messages.invitations.updated_details'))
  end

  # Inline accept from InvitationControllerConcerns
  def accept
    user = current_user || @invitation.member
    workshop = @invitation.workshop
    return back_with_message(t('messages.already_rsvped')) if @invitation.attending?

    @invitation.assign_attributes(invitation_params.merge!(attending: true, rsvp_time: Time.zone.now))
    return back_with_message(@invitation.errors.full_messages) unless @invitation.valid?

    if user.has_existing_RSVP_on(workshop.date_and_time)
      return back_with_message(t('messages.invitations.rsvped_to_other_workshop'))
    end

    return back_with_message(t('messages.already_invited')) if attending_or_waitlisted?(workshop, user)

    @workshop = WorkshopPresenter.decorate(@invitation.workshop)
    if available_spaces?(@workshop, @invitation)
      @invitation.update(invitation_params.merge!(attending: true, rsvp_time: Time.zone.now))
      @workshop.send_attending_email(@invitation)

      back_with_message(t('messages.accepted_invitation', name: @invitation.member.name))
    else
      back_with_message(t('messages.no_available_seats'))
    end
  end

  # Inline reject from InvitationControllerConcerns
  def reject
    @workshop = WorkshopPresenter.decorate(@invitation.workshop)
    if @invitation.workshop.date_and_time - 3.5.hours >= Time.zone.now
      if @invitation.attending.eql? false
        redirect_back(fallback_location: invitation_path(@invitation),
                      notice: t('messages.not_attending_already'))
      else
        @invitation.update_attribute(:attending, false)

        next_spot = WaitingList.next_spot(@invitation.workshop, @invitation.role)

        if next_spot.present?
          invitation = next_spot.invitation
          next_spot.destroy
          invitation.update(attending: true, rsvp_time: Time.zone.now, automated_rsvp: true)
          @workshop.send_attending_email(invitation, true)
        end

        redirect_back(
          fallback_location: invitation_path(@invitation),
          notice: t('messages.rejected_invitation', name: @invitation.member.name)
        )
      end
    else
      redirect_back(
        fallback_location: invitation_path(@invitation),
        notice: 'You can only change your RSVP status up to 3.5 hours before the workshop'
      )
    end
  end

  private

  # Keep controller's own invitation_params
  def invitation_params
    if params.key?(:workshop_invitation)
      params.expect(workshop_invitation: [:tutorial, :note])
    else
      {}
    end
  end

  def available_spaces?(workshop, invitation)
    (invitation.role.eql?('Student') && workshop.student_spaces?) ||
      (invitation.role.eql?('Coach') && workshop.coach_spaces?)
  end

  # Inline from InvitationControllerConcerns
  def attending_or_waitlisted?(workshop, user)
    workshop.attendee?(user) || workshop.waitlisted?(user)
  end

  def token
    params[:id]
  end
end
```

- [ ] **Step 2: Delete old InvitationController file**

Run: `rm app/controllers/invitation_controller.rb`

- [ ] **Step 3: Verify tests still pass (should work due to old route)**

Run: `bundle exec rspec spec/features/accepting_invitation_spec.rb`
Expected: PASS (old route still works)

---

## Chunk 2: Update routes

### Task 2: Add dual routes - keep old route pointing to new controller + add new route

**Files:**
- Modify: `config/routes.rb`

- [ ] **Step 1: Update routes.rb to add new route while keeping old one**

Replace lines 35-43 in `config/routes.rb`:

```ruby
# Old route - kept for backwards compatibility (existing invitation links in emails)
resources :invitation, only: [:show, :update], controller: 'workshop_invitation' do
  member do
    post 'accept'
    get 'accept'
    get 'reject'
  end

  resource :waiting_list, only: %i[create destroy]
end

# New route - cleaner URLs
resources :workshop_invitation, only: [:show, :update] do
  member do
    post 'accept'
    get 'accept'
    get 'reject'
  end

  resource :waiting_list, only: %i[create destroy]
end
```

- [ ] **Step 2: Verify routes are valid**

Run: `bundle exec rails routes | grep -E "(invitation|workshop_invitation)"`
Expected: Show both old and new routes pointing to WorkshopInvitationController

---

## Chunk 3: (Optional) Prefer new route helpers in controllers

This chunk is **optional**. The refactor works fully without it - old routes still work via backwards compatibility. Do this only if you want to use the cleaner `workshop_invitation_path` helpers in new code.

### Task 3: Update route helper references

**Files:**
- Modify: `app/controllers/workshops_controller.rb`
- Modify: `app/controllers/events_controller.rb`

- [ ] **(Optional) Step 1: Check and update workshops_controller.rb**

Read line 29 of `app/controllers/workshops_controller.rb`

If it has `redirect_to invitation_path(@invitation)`, change to:
```ruby
redirect_to workshop_invitation_path(@invitation)
```

- [ ] **(Optional) Step 2: Check and update events_controller.rb**

Read lines 31 and 67 of `app/controllers/events_controller.rb`

Update any `invitation_path` to `workshop_invitation_path`

- [ ] **(Optional) Step 3: Run tests**

Run: `bundle exec rspec spec/features/accepting_invitation_spec.rb`
Expected: PASS

---

## Chunk 4: Verify deletion is complete

**Note:** The InvitationControllerConcerns file is now unused since we've inlined all its methods into the controller. You can delete it if desired, but it's no longer critical since the controller no longer includes it.

- [ ] **Step 1: (Optional) Delete the unused concern file**

Run: `rm app/controllers/concerns/invitation_controller_concerns.rb`

- [ ] **Step 2: Verify tests still pass**

Run: `bundle exec rspec spec/features/accepting_invitation_spec.rb spec/features/coach_accepting_invitation_spec.rb`
Expected: PASS

---

## Chunk 5: Final verification

### Task 5: Run full test suite for affected areas

- [ ] **Step 1: Run invitation-related tests**

Run: `bundle exec rspec spec/features/accepting_invitation_spec.rb spec/features/coach_accepting_invitation_spec.rb spec/features/viewing_a_workshop_invitation_spec.rb`
Expected: PASS

- [ ] **Step 2: Run waiting list tests**

Run: `bundle exec rspec spec/controllers/waiting_lists_controller_spec.rb`
Expected: PASS

- [ ] **Step 3: Run linter**

Run: `bundle exec rubocop app/controllers/workshop_invitation_controller.rb`
Expected: No offenses

---

## Summary

After this refactor:
- `InvitationControllerConcerns` methods (`accept`, `reject`, `attending_or_waitlisted?`) are inlined directly into the controller
- Controller renamed to `WorkshopInvitationController`
- Includes `WorkshopInvitationConcerns` (still needed by WaitingListsController)
- Old route `/invitation/:token` still works (backwards compatible)
- New route `/workshop_invitation/:token` available
- All tests pass
- Code has documentation comment explaining its purpose
