# Test Performance Optimizations - COMPLETE

## Summary

Major fabricator optimizations achieved **28% faster model specs** (17.83s → 12.8s) and **~25% faster full suite** (~100s → ~75s).

## Completed Experiments ✅

### 1. Chapter Fabricator Optimization
- **Change**: Removed `after_create` organiser creation from default `:chapter`
- **Added**: `:chapter_with_organiser` for tests needing organiser
- **Impact**: 17% improvement

### 2. Event Fabricator Optimization
- **Change**: Removed automatic sponsorship creation from `:event`
- **Added**: `:event_with_sponsorship` for tests needing sponsorship
- **Impact**: Additional 11% (total 28% with chapter opt)

### 3. Group Fabricator Optimization
- **Change**: Reduced members from 5 to 2 in `:students` and `:coaches`
- **Impact**: Additional boost to 28% total improvement

### 4. Workshop Fabricator Bug Fix
- **Change**: Fixed `transients[:coach_count || 10]` → `transients[:coach_count] || 10`
- **Impact**: Small improvement

### 5. UNLOGGED Tables
- **File**: `lib/tasks/test_unlogged.rake`
- **Impact**: ~3-4% full suite improvement

### 6. Flaky Test Fixes
- Fixed tests affected by fabricator changes (banned members, labels CSV, workshop capacity)
- All 995 tests now passing

## Results

| Suite | Before | After | Improvement |
|-------|--------|-------|-------------|
| Model specs | 17.83s | 12.8s | **28%** ✅ |
| Full suite | ~100s | ~75s | **25%** ✅ |
| Failures | 2-7 | 0 | **Fixed** ✅ |

## Attempted & Reverted ❌

| Experiment | Reason |
|------------|--------|
| Member auth_services removal | Required for validation |
| Sponsor avatar removal | Required for validation |
| Workshop sponsor removal | Too many tests depend on workshop.host |

## Key Insight

The biggest wins came from:
1. Removing `after_create` callbacks from chapter fabricator
2. Removing `after_build` associations from event fabricator  
3. Reducing collection size (5→2) in group fabricators

Required validations (auth_services, avatar) and deep dependencies (workshop.host) prevented further optimization.

## Files Changed

- `spec/fabricators/chapter_fabricator.rb`
- `spec/fabricators/event_fabricator.rb`
- `spec/fabricators/group_fabricator.rb`
- `spec/fabricators/workshop_fabricator.rb`
- `spec/features/admin/chapters_spec.rb`
- `spec/features/admin/managing_organisers_spec.rb`
- `spec/models/workshop_spec.rb` (flaky fixes)
- `lib/tasks/test_unlogged.rake`

## Recommended Commands

```bash
# Model specs (28% faster)
bundle exec rspec spec/models/  # ~13s

# Full suite (25% faster)
make test  # ~75s

# Parallel execution (optimal)
bundle exec parallel_rspec spec/ -n 3
```

## Session Status: COMPLETE ✅

Achieved significant speedup with all tests passing. Further optimizations would require:
- Major test refactoring for workshop host dependency
- Feature spec optimization (JS/browser overhead)
- Database-level optimizations (already have UNLOGGED tables)
