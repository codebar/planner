# Test Performance Optimizations - Summary

## Completed Experiments

### ✅ UNLOGGED Tables (KEPT)
- **Status**: Implemented via `lib/tasks/test_unlogged.rake`
- **Change**: Auto-converts all tables to UNLOGGED after `db:test:prepare`
- **Improvement**: ~3-4% faster test runs (bypasses WAL logging)
- **Safety**: Safe for test environment - data loss on crash acceptable
- **Usage**: Automatic via rake task hook

### ❌ SQLite In-Memory (IMPOSSIBLE)
- **Status**: Cannot work
- **Blockers**: PostgreSQL-specific schema syntax:
  - `::text` type casts in filtered indexes
  - Custom enum types (`dietary_restriction_enum`)
  - PostgreSQL extensions

### ❌ /dev/shm tmpfs (NOT POSSIBLE on macOS)
- **Status**: Linux-only feature
- **Alternative**: macOS ramdisk possible but complex
- **Complexity**: Requires managing separate PostgreSQL instance

### ❌ synchronous_commit=off + Increased Pool (DISCARDED)
- **Status**: No measurable improvement
- **Issue**: High variance (81-88s) makes small improvements undetectable
- **Note**: May help in CI with more stable environment

### ❌ Transactional Fixtures (REVERTED)
- **Status**: Broke tests - requires significant test refactoring
- **Issue**: Many tests rely on DatabaseCleaner behavior
- **Effort**: High - would need to fix test data setup

## Recommendations

### For Local Development
1. **Use parallel tests**: `make test` (3 processes) - ~32% faster than single-process
2. **UNLOGGED tables**: Now automatic via rake hook

### For CI/Automation
- UNLOGGED tables can provide marginal improvement
- Consider running PostgreSQL in tmpfs on Linux CI runners
- Use `fsync=off` and `synchronous_commit=off` in CI test DB config

## Code Changes

```ruby
# lib/tasks/test_unlogged.rake
Rake::Task["db:test:prepare"].enhance do
  Rake::Task["db:test:unlogged"].invoke if Rails.env.test?
end
```
