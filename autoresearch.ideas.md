# Test Performance Optimizations - IN PROGRESS

## Completed Experiments

### ✅ Chapter Fabricator Optimization (KEPT)
- **Change**: Removed `after_create` organiser creation from `:chapter` fabricator
- **Added**: `:chapter_with_organiser` for tests that need organiser
- **Impact**: 
  - Model specs: 17.83s → 13.51s (**24% faster**)
  - Full suite: Improvement masked by variance, but consistent benefit

### ✅ Workshop Fabricator Bug Fix (KEPT)
- **Change**: Fixed `transients[:coach_count || 10]` → `transients[:coach_count] || 10`
- **Impact**: Small additional improvement

### ✅ UNLOGGED Tables (KEPT)
- **File**: `lib/tasks/test_unlogged.rake`
- **Improvement**: ~3-4% faster test runs

## Attempted & Discarded

| Experiment | Result | Reason |
|------------|--------|--------|
| SQLite in-memory | Impossible | PG-specific schema |
| /dev/shm tmpfs | Not possible | macOS limitation |
| synchronous_commit=off | No measurable gain | High variance |

## Current State

### Model Specs (Fast Feedback)
```bash
bundle exec rspec spec/models/
# 372 examples, ~13.5s (was 17.8s)
# 24% improvement from chapter fabricator optimization
```

### Full Suite
```bash
make test
# 992 examples, ~85-95s (variance high)
# UNLOGGED tables + parallel (3 processes) + fabricator optimizations
```

## Pre-existing Failures (Not Caused by Changes)
- `spec/features/admin/meeting_spec.rb:51,65` - Tom Select UI issues
- `spec/features/coach_accepting_invitation_spec.rb` - Waiting list behavior
- `spec/features/admin/workshops_spec.rb:248` - CSV generation

## Files Changed
- `spec/fabricators/chapter_fabricator.rb` - Removed organiser creation from default
- `spec/fabricators/workshop_fabricator.rb` - Bug fix
- `spec/features/admin/chapters_spec.rb` - Use `:chapter_with_organiser`
- `spec/features/admin/managing_organisers_spec.rb` - Use `:chapter_with_organiser`
- `lib/tasks/test_unlogged.rake` - UNLOGGED tables
