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

Add after the existing `#add` test context (around line 28):

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

Run: `bundle exec rspec spec/models/waiting_list_spec.rb:32 spec/models/waiting_list_spec.rb:41`

Expected: 2 failures - "expected 1, got 2" and similar

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

If not found: Create file with basic structure

**Step 2: Write test for idempotent controller action**

If file doesn't exist, create with:

```ruby
require 'rails_helper'

RSpec.describe WaitingListsController, type: :controller do
  let(:workshop) { Fabricate(:workshop) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop) }

  describe 'POST #create' do
    it 'is idempotent when called multiple times' do
      post :create, params: { invitation_id: invitation.token }
      post :create, params: { invitation_id: invitation.token }

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

**Step 2: Write migration to clean duplicates**

Edit the generated migration file:

```ruby
class AddUniqueIndexToWaitingListsInvitationId < ActiveRecord::Migration[8.0]
  def up
    # Find and clean up duplicate waiting list entries
    duplicate_invitation_ids = WaitingList
      .group(:invitation_id)
      .having('COUNT(*) > 1')
      .pluck(:invitation_id)

    # For each duplicate set, keep the oldest and delete the rest
    duplicate_invitation_ids.each do |invitation_id|
      waiting_list_entries = WaitingList
        .where(invitation_id: invitation_id)
        .order(:created_at)

      # Keep first (oldest), destroy the rest
      waiting_list_entries[1..].each(&:destroy)
    end

    # Add unique constraint
    add_index :waiting_lists, :invitation_id, unique: true
  end

  def down
    remove_index :waiting_lists, :invitation_id
  end
end
```

**Step 3: Run migration**

Run: `bundle exec rake db:migrate`

Expected: Migration runs successfully

**Step 4: Verify schema updated**

Run: `grep -A 5 'create_table "waiting_lists"' db/schema.rb`

Expected: Shows `index ["invitation_id"], name: "index_waiting_lists_on_invitation_id", unique: true`

**Step 5: Commit migration**

```bash
git add db/migrate/*_add_unique_index_to_waiting_lists_invitation_id.rb db/schema.rb
git commit -m "feat: add unique constraint to waiting_lists.invitation_id

Migration cleans up existing duplicates (keeping oldest entry)
before adding unique index to prevent future duplicates.

Refs #2479"
```

---

## Task 5: Run Full Test Suite

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

---

## Task 6: Verify Linting

**Files:**
- None (verification only)

**Step 1: Run RuboCop on changed files**

Run: `bundle exec rubocop app/models/waiting_list.rb spec/models/waiting_list_spec.rb`

Expected: No offenses detected

**Step 2: Fix any linting issues if found**

If RuboCop reports issues, fix them and re-run.

**Step 3: Commit linting fixes if needed**

```bash
git add <files>
git commit -m "style: fix rubocop offenses"
```

---

## Task 7: Manual Verification (Optional)

**Files:**
- None (manual testing)

**Step 1: Start Rails console**

Run: `bundle exec rails console`

**Step 2: Test idempotency in console**

```ruby
workshop = Workshop.first || Fabricate(:workshop)
invitation = WorkshopInvitation.first || Fabricate(:workshop_invitation, workshop: workshop)

# Add to waiting list twice
wl1 = WaitingList.add(invitation)
wl2 = WaitingList.add(invitation)

# Verify same record
wl1.id == wl2.id  # => true
WaitingList.where(invitation: invitation).count  # => 1
```

Expected: Returns true and 1

**Step 3: Exit console**

Type: `exit`

---

## Testing Summary

After completing all tasks, you should have:

- ✅ Model tests verifying idempotency (2 new tests)
- ✅ Controller test verifying double-submission protection (1 new test)
- ✅ Migration that cleans duplicates and adds unique constraint
- ✅ All existing tests still passing
- ✅ RuboCop clean

## Next Steps

After implementation is complete:

1. Use `@superpowers:verification-before-completion` to verify all tests pass
2. Create pull request following project conventions
3. Reference issue #2479 in PR description

## Notes

- The unique constraint provides defense-in-depth at the database level
- `find_or_create_by` handles race conditions gracefully
- First call wins for `auto_rsvp` setting (won't be overwritten)
- Migration keeps oldest entry when cleaning duplicates (fairest for waiting list position)
