#!/bin/bash
set -e

BASE="6a73071c"

echo "Resetting to $BASE..."
git reset --hard "$BASE"

echo ""
echo "=== Commit 1: feat(invitations): add invitation_logs migration and models ==="

# Migration
git checkout 3a4f2dbf -- db/migrate/20260330193245_create_invitation_logs.rb

# Models (minimal from d8863478 - no scopes/utility methods yet)
git checkout d8863478 -- app/models/invitation_log.rb
git checkout d8863478 -- app/models/invitation_log_entry.rb

# Fabricators
git checkout d8863478 -- spec/fabricators/invitation_log_fabricator.rb
git checkout d8863478 -- spec/fabricators/invitation_log_entry_fabricator.rb

# Model specs
git checkout d8863478 -- spec/models/invitation_log_spec.rb
git checkout 503fb86f -- spec/models/invitation_log_entry_spec.rb

# Schema
git checkout c1c02233 -- db/schema.rb

git add -A
git commit -m "feat(invitations): add invitation_logs migration and models

- Create invitation_logs and invitation_log_entries tables
- Add InvitationLog model with enums, associations, expiration callback
- Add InvitationLogEntry model with status tracking
- Add fabricators for test data
- Add model specs

Co-Authored-By: opencode <noreply@opencode.ai>"

echo "Running model tests..."
bundle exec rspec spec/models/invitation_log_spec.rb spec/models/invitation_log_entry_spec.rb 2>&1 | tail -5
echo ""

echo "=== Commit 2: feat(invitations): add InvitationLogger service ==="

git checkout b4a44ef2 -- app/services/invitation_logger.rb
git checkout b4a44ef2 -- spec/services/invitation_logger_spec.rb

git add -A
git commit -m "feat(invitations): add InvitationLogger service

- Service for logging invitation batch operations
- Tracks success/failure/skip counts per batch
- Provides convenience methods for starting/finishing/failing batches

Co-Authored-By: opencode <noreply@opencode.ai>"

echo "Running service tests..."
bundle exec rspec spec/services/invitation_logger_spec.rb 2>&1 | tail -5
echo ""

echo "=== Commit 3: feat(invitations): integrate logging into InvitationManager ==="

# Concerns with logging integration
git checkout 7e1d2ab9 -- app/models/concerns/workshop_invitation_manager_concerns.rb

# Controller to pass initiator_id
git checkout 436fe167 -- app/controllers/admin/workshops_controller.rb

# Workshop model with invitation_logs association + presenter scope fix
git checkout 383e131b -- app/models/workshop.rb

# Integration spec
git checkout 7e1d2ab9 -- spec/models/invitation_manager_logging_spec.rb

git add -A
git commit -m "feat(invitations): integrate logging into InvitationManager

- Add invitation_logs association to Workshop model
- Integrate InvitationLogger into workshop email sending
- Pass current_user.id for audit trail
- Handle WorkshopPresenter via workshop.model in scope

Co-Authored-By: opencode <noreply@opencode.ai>"

echo "Running integration tests..."
bundle exec rspec spec/models/invitation_manager_logging_spec.rb 2>&1 | tail -5
echo ""

echo "=== Commit 4: feat(invitations): add admin UI for viewing invitation logs ==="

# Controller (final version with pagy fix)
git checkout b1915fbb -- app/controllers/admin/workshop_invitation_logs_controller.rb

# Policy (final version with is_admin_or_chapter_organiser?)
git checkout 503fb86f -- app/policies/invitation_log_policy.rb

# Views (final versions with content_for fix)
git checkout a0fc1955 -- app/views/admin/workshop_invitation_logs/index.html.haml
git checkout a0fc1955 -- app/views/admin/workshop_invitation_logs/show.html.haml

# Shared partial from original admin UI commit
git checkout cbafb93c -- app/views/admin/workshop_invitation_logs/_invitation_log.html.haml

# Workshop show page with logs section
git checkout cbafb93c -- app/views/admin/workshops/show.html.haml

# Routes (final version with controller: option)
git checkout e3008275 -- config/routes.rb

# Seeds
git checkout f7f701be -- db/seeds.rb

# Controller and policy specs
git checkout 503fb86f -- spec/controllers/admin/workshop_invitation_logs_controller_spec.rb
git checkout 503fb86f -- spec/policies/invitation_log_policy_spec.rb

git add -A
git commit -m "feat(invitations): add admin UI for viewing invitation logs

- Add WorkshopInvitationLogsController with index/show actions
- Add InvitationLogPolicy for authorization
- Add views for listing and detail of invitation logs
- Add route nesting under admin/workshops
- Add seed data for invitation logs
- Add controller and policy specs

Co-Authored-By: opencode <noreply@opencode.ai>"

echo "Running controller and policy tests..."
bundle exec rspec spec/controllers/admin/workshop_invitation_logs_controller_spec.rb spec/policies/invitation_log_policy_spec.rb 2>&1 | tail -5
echo ""

echo "=== Commit 5: feat(invitations): add cleanup job for expired logs ==="

git checkout 284656d6 -- app/jobs/cleanup_expired_invitation_logs_job.rb
git checkout 284656d6 -- lib/tasks/invitation_logs.rake
git checkout 284656d6 -- spec/jobs/cleanup_expired_invitation_logs_job_spec.rb

git add -A
git commit -m "feat(invitations): add cleanup job for expired logs

- Add CleanupExpiredInvitationLogsJob for 180-day retention
- Add rake task invitation_logs:cleanup
- Add job specs

Co-Authored-By: opencode <noreply@opencode.ai>"

echo "Running cleanup job tests..."
bundle exec rspec spec/jobs/cleanup_expired_invitation_logs_job_spec.rb 2>&1 | tail -5
echo ""

echo ""
echo "=== Final verification: all tests ==="
bundle exec rspec \
  spec/models/invitation_log_spec.rb \
  spec/models/invitation_log_entry_spec.rb \
  spec/services/invitation_logger_spec.rb \
  spec/models/invitation_manager_logging_spec.rb \
  spec/controllers/admin/workshop_invitation_logs_controller_spec.rb \
  spec/policies/invitation_log_policy_spec.rb \
  spec/jobs/cleanup_expired_invitation_logs_job_spec.rb \
  --format progress 2>&1 | tail -15

echo ""
echo "=== Final git log ==="
git log --oneline -5
