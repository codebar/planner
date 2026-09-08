---
title: Integrate InvitationLogger for event invitations - Plan
type: feat
date: 2026-07-29
topic: integrate-invitationlogger-events
artifact_contract: ce-unified-plan/v1
artifact_readiness: implementation-ready
product_contract_source: ce-brainstorm
execution: code
---

# Integrate InvitationLogger for event invitations - Plan

## Goal Capsule

- **Objective:** Add logging to event invitation batch sends so organisers can trace who was invited, whether delivery succeeded, and debug failures without manual DJ/email log correlation.
- **Product authority:** Morgan Roderick (issue author).
- **Open blockers:** None.

## Product Contract

### Summary

Add `InvitationLogger` integration to `InvitationManager#send_event_emails`, matching the existing workshop pattern. The admin controller will pass the current member's id as the batch initiator. Each event/chapter invitation send will produce one `InvitationLog` with per-member outcomes.

### Problem Frame

Workshops and virtual workshops already record batch progress to `InvitationLog`. Events are the remaining invitation type without this visibility. When a batch fails, the only traces are scattered across Delayed Job logs and email delivery logs, making it hard to confirm who received what.

### Requirements

- R1. `InvitationManager#send_event_emails` accepts an `initiator_id` parameter.
- R2. When `initiator_id` is present, `send_event_emails` creates a single `InvitationLog` for the event/chapter batch before sending begins.
- R3. The log's `audience` is derived from the event's `audience` field: `Students` → `students`, `Coaches` → `coaches`, any other value → `everyone`.
- R4. The log's `action` is `invite`, `loggable` is the event, `initiator` is the member identified by `initiator_id`, and `chapter_id` is the chapter passed to `send_event_emails`.
- R5. `start_batch` is called inside a `RecordNotUnique` rescue so a duplicate running batch returns early without re-sending; the unique index on active batches includes `chapter_id` so the guard is per event/chapter.
- R6. `invite_students_to_event` and `invite_coaches_to_event` thread the logger through each member outcome, recording success, failure, or skipped per `InvitationLogEntry`.
- R7. `finish_batch(total)` is called with the total number of invitees when the batch completes successfully.
- R8. `fail_batch(e)` is called when an unhandled exception aborts the batch, and the exception is re-raised.
- R9. `Admin::EventsController#invite` passes `current_user.id` to `send_event_emails` for each chapter.
- R10. The implementation is covered by specs in the existing invitation-manager logging test file, verifying log creation, per-member outcomes, duplicate-batch guard, and failure handling.
- R11. `Admin::EventsController#invite` is covered by a controller/request spec verifying that `current_user.id` is passed to `send_event_emails`.

### Key Decisions

- **One combined batch per event/chapter** — chosen over two separate student/coach logs. Matches the single async `send_event_emails` call and the workshop `everyone` pattern. (session-settled: user-directed — chosen over two separate batches: simpler failure surface and one batch per controller call.)
- **Audience derived from `event.audience`** — chosen over always using `everyone`. Keeps the log semantically accurate for students-only or coaches-only events. Governs R3.
- **`chapter_id` set explicitly and included in the active-batch unique index** — chosen over leaving it `nil` (which would make the duplicate-batch guard per-event and break multi-chapter events). `InvitationLogger` accepts an explicit `chapter_id` parameter and the unique index is updated to include it. Governs R4, R5.

### Scope Boundaries

- `send_meeting_emails` is out of scope; it remains unlogged.
- A migration is required to add `chapter_id` to the `invitation_logs` unique active-batch index.
- `InvitationLogger` is updated to accept an explicit `chapter_id` parameter.

### Acceptance Examples

- AE1. **Event inviting both students and coaches**
  - **Covers R1, R2, R3, R4, R6, R7, R9.**
  - **Given:** An event with `audience` not equal to `Students` or `Coaches`, a chapter with subscribed students and coaches, and an admin member.
  - **When:** The admin clicks invite.
  - **Then:** One `InvitationLog` is created with `audience: 'everyone'`, `action: 'invite'`, `status: 'completed'`, and `total_invitees` equal to the number of students plus coaches invited.
- AE2. **Duplicate batch guard**
  - **Covers R5.**
  - **Given:** A running `InvitationLog` already exists for the same event, chapter, and audience.
  - **When:** The same event/chapter is triggered again while the first batch is still running.
  - **Then:** The second call returns early without creating duplicate invitations or logs.
- AE3. **Failure during event send**
  - **Covers R6, R8.**
  - **Given:** The event mailer raises an exception for every member.
  - **When:** The admin clicks invite.
  - **Then:** The `InvitationLog` status is `failed`, `error_message` contains the exception, and the exception propagates.

### Sources / Research

- `app/services/invitation_manager.rb` — existing workshop logging pattern in `send_workshop_emails` and `send_virtual_workshop_emails`.
- `app/services/invitation_logger.rb` — logger API: `start_batch`, `finish_batch`, `fail_batch`, `log_success`, `log_failure`, `log_skipped`.
- `app/controllers/admin/events_controller.rb` — `invite` action iterates over event chapters and calls `send_event_emails`.
- `app/models/invitation_log.rb` — polymorphic `loggable`, enum `action`, optional `initiator` and `chapter`.
- `db/schema.rb` — current unique index on active batches does not include `chapter_id`.
- `spec/services/invitation_manager_logging_spec.rb` — existing workshop logging specs to mirror.

## Planning Contract

### Key Technical Decisions

- KTD1. **`InvitationLogger` receives an explicit `chapter_id` parameter.** The current logger derives `chapter_id` from `loggable.try(:chapter_id)`, which works for workshops but returns `nil` for events (events have `has_and_belongs_to_many :chapters`). Passing `chapter_id` explicitly makes the logger reusable for any loggable. Governs U1, U3.
- KTD2. **Add `chapter_id` to the active-batch unique index.** The existing unique index is `(loggable_type, loggable_id, audience, action, status) WHERE status = 'running'`. Adding `chapter_id` lets the duplicate-batch guard protect per event/chapter rather than per event. Governs U2.
- KTD3. **Keep the controller's per-chapter loop.** The admin invite action already calls `send_event_emails` once per chapter. Each call creates one `InvitationLog` for that event/chapter. The event itself remains the `loggable`. Governs U4.

### High-Level Technical Design

The change is a pattern extension, not a new service. `InvitationManager#send_event_emails` mirrors the existing `send_workshop_emails` flow:

1. Accept `initiator_id`.
2. Build an `InvitationLogger` with the event, initiator, chapter, derived audience, and `:invite` action.
3. Call `start_batch` inside a `RecordNotUnique` rescue.
4. Thread the logger through the existing per-member invitation loops so each member outcome is logged.
5. Call `finish_batch(total)` on success or `fail_batch(e)` and re-raise on failure.

`InvitationLogger` is updated to accept an explicit `chapter_id` in `initialize` and `start_batch`. Workshop and virtual-workshop callers pass `workshop.chapter_id` explicitly so existing behaviour is unchanged.

A single migration replaces the active-batch unique index with one that includes `chapter_id`.

### Risks & Dependencies

- **Migration safety.** The index change is a metadata-only operation; no table data is rewritten. The new unique index is a strict superset of the old columns.
- **Signature change.** `send_event_emails` gains a third parameter. Only `Admin::EventsController#invite` calls it, so the blast radius is small.
- **Existing logging-spec bug.** `spec/services/invitation_manager_logging_spec.rb` has a `logs batch as failed when exception occurs` test that currently asserts `status: 'completed'` and `error_message: nil`. That assertion looks wrong against the production code, so the event failure tests should not copy it blindly. Verify the expected behaviour before mirroring the test.
- **No `Admin::EventsController` spec exists.** The new controller test will be added to a new or existing request spec.

### Open Questions

None.

## Implementation Units

### U1. Update `InvitationLogger` to accept an explicit `chapter_id`

- **Goal:** Make the logger reusable for loggables that do not have a single `chapter_id` attribute.
- **Requirements:** R4, R5.
- **Files:** `app/services/invitation_logger.rb`.
- **Approach:** Add an optional `chapter_id` parameter to `initialize`. Use the passed value in `start_batch` instead of `@loggable.try(:chapter_id)`. Update `send_workshop_emails` and `send_virtual_workshop_emails` in `app/services/invitation_manager.rb` to pass `workshop.chapter_id` explicitly.
- **Test scenarios:**
  - Existing workshop logging specs still pass and still set `chapter_id`.
  - `InvitationLogger.new(event, initiator, audience, :invite, chapter_id: chapter.id).start_batch` sets `chapter_id` to the provided value.
- **Verification:** `bundle exec rspec spec/services/invitation_manager_logging_spec.rb`.

### U2. Add migration for the active-batch unique index

- **Goal:** Make the duplicate-batch guard per event/chapter.
- **Requirements:** R5.
- **Files:** `db/migrate/...`, `db/schema.rb`.
- **Approach:** Create a migration that removes the existing unique index `index_invitation_logs_unique_active` and adds a new one on `(loggable_type, loggable_id, chapter_id, audience, action, status)` with the same partial condition `WHERE status = 'running'`. Verify `db/schema.rb` updates.
- **Test scenarios:**
  - Running the migration up and down leaves the schema consistent.
  - Two `InvitationLog` records with the same `loggable`, `audience`, `action`, and `status: running` but different `chapter_id`s can coexist.
  - Two with the same `loggable`, `chapter_id`, `audience`, `action`, and `status: running` cannot coexist.
- **Verification:** `bundle exec rake db:migrate db:schema:dump` and `bundle exec rspec spec/services/invitation_manager_logging_spec.rb`.

### U3. Integrate `InvitationLogger` into `send_event_emails`

- **Goal:** Add the same batch logging pattern to event invitations that workshops already have.
- **Requirements:** R1, R2, R3, R4, R5, R6, R7, R8.
- **Files:** `app/services/invitation_manager.rb`.
- **Approach:**
  1. Change `send_event_emails(event, chapter)` to `send_event_emails(event, chapter, initiator_id = nil)`.
  2. Look up the initiator; build a logger with the event, initiator, chapter, derived audience, and `:invite`.
  3. Call `start_batch` inside a `RecordNotUnique` rescue.
  4. Update `invite_students_to_event` and `invite_coaches_to_event` to accept an optional `logger` and log success/failure/skipped around each member.
  5. Call `finish_batch(total)` on success, or `fail_batch(e)` and re-raise on failure.
  6. Map `event.audience` to the logger audience: `Students` → `students`, `Coaches` → `coaches`, any other value → `everyone`.
- **Test scenarios:**
  - With `initiator_id` present, an `InvitationLog` is created with correct `loggable`, `initiator`, `chapter_id`, `audience`, and `action`.
  - With `initiator_id` nil, no `InvitationLog` is created.
  - Successful sends increment `success_count`.
  - Skipped invitees (already invited) increment `skipped_count`.
  - Mailer failures increment `failure_count` and mark the batch `failed`.
  - A second concurrent batch for the same event/chapter/audience hits the guard and returns early.
  - Events with `audience: 'Students'` only log `students`; events with `audience: 'Coaches'` only log `coaches`; other events log `everyone`.
- **Verification:** `bundle exec rspec spec/services/invitation_manager_spec.rb spec/services/invitation_manager_logging_spec.rb`.

### U4. Pass `current_user.id` from the admin controller

- **Goal:** Surface the initiator of the event invitation batch.
- **Requirements:** R9, R11.
- **Files:** `app/controllers/admin/events_controller.rb`, new or existing request spec.
- **Approach:** In `Admin::EventsController#invite`, change the per-chapter loop to pass `current_user.id` as the third argument to `send_event_emails`.
- **Test scenarios:**
  - A logged-in admin clicking invite passes `current_user.id` to the manager for each chapter.
  - The user is redirected with the existing success notice.
- **Verification:** `bundle exec rspec spec/controllers/admin/events_controller_spec.rb` or `bundle exec rspec spec/requests/admin/events_spec.rb` if using request specs.

### U5. Add controller/request spec for event invitations

- **Goal:** Cover the controller change in R11.
- **Requirements:** R11.
- **Files:** New spec file under `spec/controllers/admin/` or `spec/requests/admin/`.
- **Approach:** Create an authorised organiser, create an event with a chapter, post to the invite action, and assert that the delayed job receives `current_user.id` or that the controller forwards it.
- **Test scenarios:**
  - Authorised organiser can trigger invitations and the initiator is forwarded.
  - Unauthorised user cannot trigger invitations.
- **Verification:** `bundle exec rspec spec/controllers/admin/events_controller_spec.rb` or `bundle exec rspec spec/requests/admin/events_spec.rb`.

## Verification Contract

- **Unit tests:** `bundle exec rspec spec/services/invitation_manager_spec.rb spec/services/invitation_manager_logging_spec.rb`.
- **Controller/request tests:** `bundle exec rspec spec/controllers/admin/events_controller_spec.rb` (or equivalent request spec path).
- **Migration:** `bundle exec rake db:migrate db:schema:dump` and `bundle exec rake db:rollback`.
- **Full test suite:** `make test` or `bundle exec parallel_rspec spec/ -n 3`.
- **Linting:** `bundle exec rubocop`.

## Definition of Done

- [ ] U1, U2, U3, U4, and U5 are implemented and all verification commands pass.
- [ ] No dead-end or experimental code remains in the diff.
- [ ] The plan's R-IDs are traceable in the implementation or tests.
- [ ] The migration is reversible and `db/schema.rb` is updated.
- [ ] The existing workshop and virtual-workshop invitation logging behaviour is unchanged.
- [ ] A draft PR is opened with a clear description linking to issue #2760.
