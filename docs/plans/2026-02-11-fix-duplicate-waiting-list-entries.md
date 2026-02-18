# Fix Duplicate Waiting List Entries Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Prevent duplicate waiting list entries by making `WaitingList.add()` idempotent and adding database constraints.

**Architecture:** Use `find_or_create_by` instead of `create` in `WaitingList.add()` to ensure idempotency. Add unique database constraint on `invitation_id`. Clean up existing duplicates in migration.

**Tech Stack:** Rails 8.1, RSpec, PostgreSQL

**Related Issue:** [#2479](https://github.com/codebar/planner/issues/2479)

---

## Task 1: Add Model Tests for Idempotency

**Files:**
- Modify: `spec/models/waiting_list_spec.rb`

**Step 1: Write failing test for idempotent behavior**

Add in the existing `context '#add'` block:

```ruby
it 'is idempotent - returns existing record when called twice' do
  invitation = Fabricate(:workshop_invitation, workshop: workshop)

  first_call = WaitingList.add(invitation)
  second_call = WaitingList.add(invitation)

  expect(first_call.id).to eq(second_call.id)
  expect(WaitingList.by_workshop(workshop).count).to eq(1)
end
```

**Step 2: Write failing test for auto_rsvp preservation**

Add after the previous test:

```ruby
it 'does not change auto_rsvp on subsequent calls' do
  invitation = Fabricate(:workshop_invitation, workshop: workshop)

  first_entry = WaitingList.add(invitation, true)
  second_entry = WaitingList.add(invitation, false)

  expect(second_entry.reload.auto_rsvp).to eq(true)
end
```

**Step 3: Run tests to verify they fail**

Run: `bundle exec rspec spec/models/waiting_list_spec.rb`

Expected: 2 new failures in the `#add` context - "expected 1, got 2" and similar

**Step 4: Commit failing tests**

```bash
git add spec/models/waiting_list_spec.rb
git commit -m "test: add failing tests for WaitingList idempotency"
```

---

## Task 2: Make WaitingList.add() Idempotent

**Files:**
- Modify: `app/models/waiting_list.rb:11-13`

**Step 1: Update add method to use find_or_create_by**

Replace the `add` method:

```ruby
def self.add(invitation, auto_rsvp = true)
  find_or_create_by(invitation: invitation) do |waiting_list|
    waiting_list.auto_rsvp = auto_rsvp
  end
end
```

**Step 2: Run tests to verify they pass**

Run: `bundle exec rspec spec/models/waiting_list_spec.rb`

Expected: All 8 tests pass (6 existing + 2 new)

**Step 3: Commit implementation**

```bash
git add app/models/waiting_list.rb
git commit -m "fix: make WaitingList.add() idempotent

Use find_or_create_by instead of create to prevent duplicate
waiting list entries for the same invitation. First call wins
for auto_rsvp setting.

Refs #2479"
```

---

## Task 3: Add Controller Test for Double-Submission

**Files:**
- Modify: `spec/controllers/waiting_lists_controller_spec.rb`

**Step 1: Check if controller spec exists**

Run: `ls spec/controllers/waiting_lists_controller_spec.rb`

If not found, create it. Otherwise, add to existing file.

**Step 2: Write comprehensive test for idempotent controller action**

If file doesn't exist, create with:

```ruby
require 'rails_helper'

RSpec.describe WaitingListsController, type: :controller do
  let(:workshop) { Fabricate(:workshop) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop) }

  describe 'POST #create' do
    it 'is idempotent when called multiple times' do
      expect {
        post :create, params: { invitation_id: invitation.token }
      }.to change { WaitingList.count }.by(1)

      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq('You have been added to the waiting list')

      # Second call should not create duplicate
      expect {
        post :create, params: { invitation_id: invitation.token }
      }.not_to change { WaitingList.count }

      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq('You have been added to the waiting list')
      expect(WaitingList.where(invitation: invitation).count).to eq(1)
    end
  end
end
```

If file exists, add the test to existing `describe 'POST #create'` block or create new one.

**Step 3: Run controller test**

Run: `bundle exec rspec spec/controllers/waiting_lists_controller_spec.rb`

Expected: Test passes (implementation already makes it work)

**Step 4: Commit controller test**

```bash
git add spec/controllers/waiting_lists_controller_spec.rb
git commit -m "test: add controller test for idempotent waiting list creation"
```

---

## Task 4: Create Migration to Clean Duplicates and Add Constraint

**Files:**
- Create: `db/migrate/YYYYMMDDHHMMSS_add_unique_index_to_waiting_lists_invitation_id.rb`

**Step 1: Generate migration**

Run: `bundle exec rails generate migration AddUniqueIndexToWaitingListsInvitationId`

This creates a timestamped file in `db/migrate/`

**Step 2: Write migration to clean duplicates safely**

Edit the generated migration file:

```ruby
class AddUniqueIndexToWaitingListsInvitationId < ActiveRecord::Migration[8.0]
  def up
    say_with_time "Cleaning up duplicate waiting list entries" do
      # Find invitation_ids with duplicates
      duplicates = WaitingList
        .select('invitation_id, COUNT(*) as duplicate_count')
        .group(:invitation_id)
        .having('COUNT(*) > 1')

      duplicate_count = duplicates.count
      say "Found #{duplicate_count} invitation_ids with duplicates"

      return if duplicate_count.zero?

      # For each duplicate set, keep oldest and delete the rest
      duplicates.each do |dup|
        entries = WaitingList
          .where(invitation_id: dup.invitation_id)
          .order(:created_at)

        # Get IDs to delete (all except first/oldest)
        ids_to_delete = entries[1..].map(&:id)
        deleted_count = ids_to_delete.size

        say "  Invitation #{dup.invitation_id}: deleting #{deleted_count} duplicate(s), keeping entry ##{entries.first.id}"

        # Use delete_all for performance and to avoid callbacks
        WaitingList.where(id: ids_to_delete).delete_all
      end

      duplicate_count
    end

    # Add unique constraint
    add_index :waiting_lists, :invitation_id, unique: true
  end

  def down
    remove_index :waiting_lists, :invitation_id
    # Note: Cannot restore deleted duplicate entries
  end
end
```

**Step 3: Run migration and verify output**

Run: `bundle exec rake db:migrate`

Expected output should show:
- "Cleaning up duplicate waiting list entries"
- Count of duplicate invitation_ids found
- For each duplicate: which entries are being deleted
- "add_index(:waiting_lists, :invitation_id)"

**Step 4: Verify schema updated**

Run: `grep -A 5 'create_table "waiting_lists"' db/schema.rb`

Expected: Shows `index ["invitation_id"], name: "index_waiting_lists_on_invitation_id", unique: true`

**Step 5: Verify no duplicates remain**

Run: `bundle exec rails runner 'puts WaitingList.group(:invitation_id).having("COUNT(*) > 1").count'`

Expected: Returns `0` (no duplicates)

**Step 6: Commit migration**

```bash
git add db/migrate/*_add_unique_index_to_waiting_lists_invitation_id.rb db/schema.rb
git commit -m "feat: add unique constraint to waiting_lists.invitation_id

Migration cleans up existing duplicates (keeping oldest entry)
before adding unique index to prevent future duplicates.

Refs #2479"
```

---

## Task 5: Run Full Test Suite and Verify Linting

**Files:**
- None (verification only)

**Step 1: Run all waiting list related tests**

Run: `bundle exec rspec spec/models/waiting_list_spec.rb spec/controllers/waiting_lists_controller_spec.rb`

Expected: All tests pass

**Step 2: Run feature tests for workshop management**

Run: `bundle exec rspec spec/features/admin/manage_workshop_attendances_spec.rb`

Expected: All tests pass

**Step 3: Run tests that use WaitingList.add**

Run: `bundle exec rspec spec/support/shared_examples/behaves_like_an_invitation_route.rb spec/models/workshop_spec.rb`

Expected: All tests pass

**Step 4: Run RuboCop on changed files**

Run: `bundle exec rubocop app/models/waiting_list.rb spec/models/waiting_list_spec.rb spec/controllers/waiting_lists_controller_spec.rb`

Expected: No offenses detected

**Step 5: Fix any linting issues if found**

If RuboCop reports issues, fix them and commit:

```bash
git add <files>
git commit -m "style: fix rubocop offenses"
```

---

## Task 6: Manual Verification

**Files:**
- None (manual testing)

**Step 1: Start Rails console**

Run: `bundle exec rails console`

**Step 2: Verify idempotency in console**

```ruby
# Test idempotency
workshop = Workshop.first || Fabricate(:workshop)
invitation = WorkshopInvitation.first || Fabricate(:workshop_invitation, workshop: workshop)

wl1 = WaitingList.add(invitation)
wl2 = WaitingList.add(invitation)

puts "Same record? #{wl1.id == wl2.id}"  # Should be true
puts "Count: #{WaitingList.where(invitation: invitation).count}"  # Should be 1
```

Expected: Both checks pass

**Step 3: Verify unique constraint prevents duplicates**

```ruby
# Try to create duplicate directly (should fail)
begin
  WaitingList.create!(invitation: invitation, auto_rsvp: true)
  puts "ERROR: Duplicate was created!"
rescue ActiveRecord::RecordNotUnique => e
  puts "GOOD: Unique constraint prevented duplicate"
end
```

Expected: "GOOD: Unique constraint prevented duplicate"

**Step 4: Exit console**

Type: `exit`

---

## Testing Summary

After completing all tasks, you should have:

- ✅ Model tests verifying idempotency (2 new tests)
- ✅ Controller test verifying double-submission protection with full response checks (1 new test)
- ✅ Migration that safely cleans duplicates with logging and adds unique constraint
- ✅ All existing tests still passing
- ✅ RuboCop clean
- ✅ Manual verification that constraints work

## Next Steps

After implementation is complete:

1. Use `@superpowers:verification-before-completion` to verify all tests pass
2. Create pull request following project conventions
3. Reference issue #2479 in PR description

## Production Deployment Notes

**Pre-deployment:**
- Review migration output in staging first
- Migration is safe to run - uses `delete_all` for performance and logs all deletions
- Expected downtime: None (migration is fast, <1 second for typical data)

**Post-deployment:**
- Monitor logs for any `ActiveRecord::RecordNotUnique` exceptions (shouldn't occur but worth checking)
- Verify waiting list functionality works correctly in production
- Check Rollbar/error tracking for any unexpected issues

**Rollback plan:**
- Code rollback: Safe - old code will continue working (no duplicates can be created anymore)
- Database rollback: Run `rake db:rollback` to remove unique index
- Note: Deleted duplicate entries cannot be restored (acceptable - they were bugs)

## Notes

- The unique constraint provides defense-in-depth at the database level
- `find_or_create_by` handles race conditions gracefully by rescuing `RecordNotUnique` and retrying
- First call wins for `auto_rsvp` setting (won't be overwritten on subsequent calls)
- Migration keeps oldest entry when cleaning duplicates (fairest for waiting list position)
- Migration uses `delete_all` instead of `destroy` for performance (avoids callbacks)
- Migration logs all deletions for audit trail
