# Fix Duplicate Waiting List Entries

**Issue:** [#2479](https://github.com/codebar/planner/issues/2479)
**Date:** 2026-02-11

## Problem

Duplicate entries appear in workshop waiting lists. The same member shows up multiple times in the waiting list display, with each entry pointing to the same invitation and member. These duplicates are counted in the summary statistics.

## Root Cause

1. **No uniqueness constraint:** The `waiting_lists` table has no unique constraint on `invitation_id`
2. **Non-idempotent code:** `WaitingList.add()` blindly creates a new record without checking for existing entries
3. **Non-idempotent controller:** `WaitingListsController#create` calls `WaitingList.add()` on every POST, with no duplicate-submission protection

Duplicates occur through:
- Double-clicking the "Join the waiting list" button
- Browser back button + form resubmission
- Network retries
- Page refresh after submission

## Solution

### 1. Make `WaitingList.add()` Idempotent

Change from `create` to `find_or_create_by`:

**Before:**
```ruby
def self.add(invitation, auto_rsvp = true)
  create(invitation: invitation, auto_rsvp: auto_rsvp)
end
```

**After:**
```ruby
def self.add(invitation, auto_rsvp = true)
  find_or_create_by(invitation: invitation) do |waiting_list|
    waiting_list.auto_rsvp = auto_rsvp
  end
end
```

This approach:
- Returns existing record if one already exists
- Creates new record only if none exists
- Sets `auto_rsvp` only on creation (first call wins)
- Is fully idempotent

### 2. Add Database Constraint

Add unique index in migration:

```ruby
add_index :waiting_lists, :invitation_id, unique: true
```

Provides defense-in-depth - prevents duplicates even if code bypasses the model.

### 3. Clean Up Existing Duplicates

Migration must remove duplicates before adding constraint:

**Strategy:**
- Find invitation_ids with multiple waiting list entries
- Keep the oldest entry (earliest `created_at`)
- Delete newer duplicates

**Rationale for keeping oldest:**
- Preserves original join time (fairest for waiting list position)
- Maintains user's original `auto_rsvp` choice
- Respects chronological order

## Testing

### Model Tests
- Verify idempotency: calling `add()` twice returns same record
- Verify count: only one waiting list entry exists after multiple calls
- Verify `auto_rsvp` unchanged on subsequent calls

### Controller Tests
- Verify double-submission creates only one entry

### Migration Tests
- Verify duplicates are removed correctly
- Verify oldest entry is retained

## Edge Cases

### Race Conditions
Database unique constraint catches simultaneous inserts. `find_or_create_by` handles `ActiveRecord::RecordNotUnique` by retrying the find.

### Existing Invitation on Waiting List
When user already on waiting list tries to join again:
- `@invitation.save` updates invitation attributes (tutorial, note)
- `WaitingList.add()` returns existing entry (no-op)
- Result: Invitation updates, waiting list unchanged ✓

### Migration Rollback
Down migration removes unique index. Cannot restore deleted duplicates (acceptable - they were bugs).

## Files Changed

- `app/models/waiting_list.rb` - Make `add()` idempotent
- `db/migrate/YYYYMMDDHHMMSS_add_unique_index_to_waiting_lists.rb` - Migration
- `spec/models/waiting_list_spec.rb` - Add idempotency tests
- `spec/controllers/waiting_lists_controller_spec.rb` - Add double-submission test

## Impact

- Prevents future duplicates
- Fixes existing duplicates in production database
- No changes to UI or user experience
- No breaking changes to existing code
