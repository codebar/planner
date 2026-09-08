# Squash Pre-2026 Migrations Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all 163 pre-2026 migration files with a single guarded baseline migration so that, going forward, the only individually-reviewed migrations are the 13 in strong_migrations' window (2026+), matching the practice Olle described in PR #2774.

**Architecture:** Delete the pre-2026 migration files and add one baseline migration at timestamp `20251230000000` whose `up` rebuilds the pre-2026 schema and is a **no-op** on already-migrated DBs (guarded by `table_exists?`). The 13 in-window 2026 migrations stay untouched. `db/schema.rb` remains the source of truth for fresh builds via `db:prepare`/`db:schema:load`; the baseline preserves the documented `rake db:migrate` bootstrap path and Heroku's `release: db:migrate`.

**Tech Stack:** Rails 8.1, ActiveRecord migrations, PostgreSQL, strong_migrations 2.8.

## Global Constraints

- `StrongMigrations.start_after = 20260101000000` — **unchanged**. Any migration with timestamp `<= 20260101000000` is not checked by strong_migrations (verified in `strong_migrations-2.8.0/lib/strong_migrations/checker.rb:149` and `strong_migrations.rb:83`). So the baseline `20251230000000` is never audited.
- Heroku `Procfile` runs `release: bundle exec rake db:migrate` on every deploy, staging AND production. Both DBs already carry all 176 schema-migration versions.
- Fresh dev bootstrap (AGENTS.md) is `rake db:create db:migrate db:seed` — `db:migrate` from an empty DB must succeed after the squash.
- CI tests boot via `bundle exec rake parallel:setup` (= `db:create` + `db:schema:load`) — already schema-based, immune to migration deletion, but must stay green.
- Keep **all 13** in-window (≥20260101000000) migrations. Do not attempt to keep only the 6 annotated ones: they interleave with the other 7 in-window migrations and are not a contiguous suffix, so they cannot be replayed against a baseline.
- Do not hand-write the baseline from the committed `db/schema.rb` at the cutoff — it is stale (last regenerated at `2025_08_23_151717`, missing 2025-11-20 indexes). Generate the baseline from a live migration run.
- Do not bypass the `table_exists?` guard — it is what makes Heroku's `release: db:migrate` a no-op on deployed DBs.
- Each task ends with a commit; never commit to `master`.

---

### Task 1: Generate the true pre-2026 schema snapshot

**Files:**
- Create: `tmp/schema_pre_2026.rb` (gitignored scratch snapshot; generated, not committed)

**Interfaces:**
- Produces: `tmp/schema_pre_2026.rb`, a live dump of the exact post-migrate state of the 163 pre-2026 migrations. Tasks 2–4 depend on this snapshot being exact — it is the source the baseline is generated from.

- [ ] **Step 1: Produce the snapshot**

1. Set aside the 13 kept migrations so only the 163 pre-2026 remain:
   ```bash
   mkdir -p tmp/kept_2026 && mv db/migrate/2026*.rb tmp/kept_2026/
   ```
2. Point at a scratch database and migrate from empty:
   ```bash
   DATABASE_URL=postgresql://localhost/codebar_squash_scratch bundle exec rails db:create db:migrate
   ```
   Expected: exactly the 163 pre-2026 migrations run; no strong_migrations block (all pre-2026 are below `start_after`).
3. Dump the resulting schema as the snapshot:
   ```bash
   DATABASE_URL=postgresql://localhost/codebar_squash_scratch bundle exec rails db:schema:dump
   cp db/schema.rb tmp/schema_pre_2026.rb
   ```
4. Restore the 13 and drop the scratch DB:
   ```bash
   mv tmp/kept_2026/2026*.rb db/migrate/ && git checkout db/schema.rb
   DATABASE_URL=postgresql://localhost/codebar_squash_scratch bundle exec rails db:drop
   ```

- [ ] **Step 2: Verify the snapshot**

```bash
grep -n "version:" tmp/schema_pre_2026.rb | head -1
# Expected: 2025_11_20_090000 (the last, 2025-11-20 migration) — NOT 2025_08_23
grep -c "add_foreign_key" tmp/schema_pre_2026.rb
grep -c "t.index\|add_index" tmp/schema_pre_2026.rb  # > 0, indexes present
```

- [ ] **Step 3: Commit**

```bash
git commit -am "chore(migrations): capture pre-2026 schema snapshot for squash"
```

---

## Task 2: Generate the guarded baseline migration

**Files:**
- Create: `db/migrate/20251230000000_squash_pre_2026_migrations.rb`
- Create: `scripts/generate_squash_migration.rb` (real, working generator this time)

**Interfaces:**
- Consumes: `tmp/schema_pre_2026.rb` (Task 1).
- Produces: `SquashPre2026Migrations.up` — a self-contained `up` that (a) returns early on any already-populated DB, and (b) otherwise rebuilds the pre-2026 schema. Task 3 deletes files; Task 4 verifies.

- [ ] **Step 1: Write the generator**

Create `scripts/generate_squash_migration.rb`:

```ruby
# frozen_string_literal: true

# Generates db/migrate/20251230000000_squash_pre_2026_migrations.rb from a
# live dump of the pre-2026 schema (tmp/schema_pre_2026.rb).
#
# Run from repo root:  ruby scripts/generate_squash_migration.rb

require "date"

SNAPSHOT = File.expand_path("tmp/schema_pre_2026.rb", Dir.pwd)
OUT      = File.expand_path("db/migrate/20251230000000_squash_pre_2026_migrations.rb", Dir.pwd)
VERSION  = 2025_11_20_090000 # last pre-2026 migration version

raise "no snapshot" unless File.exist?(SNAPSHOT)

# Pull just the body of the ActiveRecord::Schema[8.1].define(...) block.
text = File.read(SNAPSHOT)
body = text[/\bdefine\s*\([^)]*\)\s*do\s*\n(.*)\n\s*end\s*\z/m, 1] or raise "could not extract schema body"

migration = <<~RB
  # frozen_string_literal: true

  # ONE-TIME SQUASH of all pre-2026 migrations (163 files). Generated by
  # scripts/generate_squash_migration.rb from #{SNAPSHOT} (#{VERSION}).
  # db/schema.rb -- not the per-year migration files -- is the source of truth
  # for new databases. Guarded so existing deployments are unaffected by the
  # Heroku `release: db:migrate` step.
  class SquashPre2026Migrations < ActiveRecord::Migration[8.1]
    def up
      return if table_exists?(:members) # no-op on already-migrated databases

  #{body.lines.map { |l| '      ' + l }.join}
    end

    def down
      raise ActiveRecord::IrreversibleMigration
    end
  end
RB

File.write(OUT, migration)
puts "wrote #{OUT}"
```

- [ ] **Step 2: Run the generator**

```bash
ruby scripts/generate_squash_migration.rb
```

- [ ] **Step 3: Lint the generated file (essential auto-generated clean-up)**

```bash
bundle exec rubocop db/migrate/20251230000000_squash_pre_2026_migrations.rb -A
# fix any auto-fixable style so the file passes the repo's rubocop gate
bundle exec rubocop db/migrate/20251230000000_squash_pre_2026_migrations.rb # must be clean
```

- [ ] **Step 4: Commit**

```bash
git add db/migrate/20251230000000_squash_pre_2026_migrations.rb scripts/generate_squash_migration.rb
git commit -m "feat(migrations): add guarded baseline for pre-2026 schema"
```

---

## Task 3: Delete the 163 pre-2026 migrations

**Files:**
- Delete: every `db/migrate/*.rb` whose filename does NOT start with `2026` (163 files), plus `tmp/schema_pre_2026.rb`.

**Interfaces:**
- Consumes none directly; prerequisites Task 1 + Task 2 (baseline exists and guard confirmed to compile).

- [ ] **Step 1: Delete the files**

```bash
# Confirm exactly 163 non-2026 migration files will be removed:
{ ls db/migrate | grep -v '^2026' | grep -c '\.rb$'; }   # expect 163
{ ls db/migrate | grep '^2026'; }                          # expect the 13 kept
```

Then remove them:

```bash
git rm db/migrate/*.rb --ignore-unmatch \
  | while read -r path; do [[ "$(basename "$path")" == 2026* ]] || rm -f "$path"; done
```
*Prefer an explicit `git rm` of the 163 listed filenames; the glob/pipe is only a fallback. Reviewer must be able to see the keep-list (13) and the deleted-count (163).*

- [ ] **Step 2: Remove the now-surplus snapshot**

```bash
git rm tmp/schema_pre_2026.rb 2>/dev/null || true
```

- [ ] **Step 3: Confirm file counts and strong_migrations window**

```bash
ls db/migrate | grep -c '\.rb$'    # expect 14 (baseline + 13)
grep -n "start_after" config/initializers/strong_migrations.rb  # unchanged: 20260101000000
```

- [ ] **Step 4: Commit**

```bash
git commit -am "chore(migrations): drop 163 pre-2026 migration files in favour of the squashed baseline"
```

---

## Task 4: Verify fresh-build and existing-DB parity

**Files:**
- Read-only verification; no production code changes.

- [ ] **Step 1: Fresh DB replay = current schema (the core assertion)**

On a scratch DB, migrate from empty then dump, and require equality with HEAD `db/schema.rb`:

```bash
DATABASE_URL=postgresql://localhost/codebar_squash_verify bundle exec rails db:create db:migrate
DATABASE_URL=postgresql://localhost/codebar_squash_verify bundle exec rails db:schema:dump
git diff --exit-code db/schema.rb   # MUST be empty: baseline + 13 reproduces the committed schema exactly
```

If this diff shows anything other than zero, the square is wrong: the baseline body drifted from the true pre-2026 schema or a 2026 migration was folded/omitted. Fix by regenerating (Task 2) — never hand-edit.

- [ ] **Step 2: Existing-DB no-op (Heroku release path)**

Copy the produced baseline onto a DB that already carries all 176 schema-migration stamps (e.g. a local clone of prod schema state), then migrate:

```bash
DATABASE_URL=postgresql://localhost/codebar_squash_existing bundle exec rails db:migrate
# Expected: only the baseline applies and its `table_exists?(:members)` guard returns, no-op.
DATABASE_URL=postgresql://localhost/codebar_squash_existing bundle exec rails db:schema:dump
git diff -- db/schema.rb   # must remain empty
```

- [ ] **Step 3: strong_migrations window still enforced on fresh boot**

```bash
# on the fresh DB (Step 1) re-run migrate with strong_migrations active:
RAILS_ENV=test DATABASE_URL=postgresql://localhost/codebar_squash_verify bundle exec rails db:migrate:status
# expect: the 6 annotated 2026 migrations listed with their safety_assured blocks; baseline not flagged
```

- [ ] **Step 4: CI seeds and tests still boot**

```bash
bundle exec rake parallel:setup   # schema-based, must stay green
bundle exec parallel_rspec spec/ -n 3    # or `make test` — full suite green
```

- [ ] **Step 5: Commit (no code change if golden)**

```bash
git checkout -- db/schema.rb 2>/dev/null || true
git log --oneline -- db/migrate | head -30   # shows the baseline + 13 recent
```

---

## Task 5: PR split & docs

**Files:**
- Modify: `docs/AGENTS.md` (migration section) - optional.

- [ ] **Step 1: Add a one-paragraph note in AGENTS.md**

Precisely this wording:

```
## Migrations

Pre-2026 migrations were squashed into a single baseline migration
(`20251230000000_squash_pre_2026_migrations`) that rebuilds the pre-2026
schema and is a no-op on already-migrated databases. `db/schema.rb` is the
source of truth for new databases. New migrations are audited by
strong_migrations from 2026-01-01 onwards; the baseline predates that window
and is intentionally not audited.
```

- [ ] **Step 2: Commit**

```bash
git add docs/AGENTS.md
git commit -m "docs: note migration squash baseline"
```

---

## Risks / Costs

- **Fork divergence:** deleting upstream `codebar/planner` history means every future upstream `git pull`/merge conflicts on the 163 deleted files. Accepted by the author; mitigate by merging upstream with `-X theirs` on `db/migrate` or via a rebase-on-demand.
- **Fresh Heroku bootstrap** relies on the baseline (guarded) + schema:load; already-deployed prod/staging are untouched because the guard returns.
- **Lost `down` migrations** for the pre-2026 set — accepted (many were already irreversible).
- **Baseline drift** — mitigated by Task 4's diff-assertion; regenerate, never hand-edit.
- **Only the 6 annotated migrations are *not* kept; all 13 in-window are.** Kept so `db:migrate` bootstrap and the interleaved ordering stay replayable.

---

## Self-Review

- **Spec coverage:** squash ✓ (Tasks 1–3), strong_migrations window preserved ✓ (constraint + Task 3), Heroku parity ✓ (Task 4), dev bootstrap ✓ (Task 4), docs ✓ (Task 5).
- **Placeholder scan:** no TBD; generator (Task 2) is complete code; Task 1 is pure shell procedure. Clean.
- **Consistency:** version guard `table_exists?(:members)`; strong_migrations cutoff `20260101000000`; baseline `20251230000000` (< cutoff, so unaudited); 13 kept, 163 deleted; all used consistently across tasks.