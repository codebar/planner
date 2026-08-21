# Merge Duplicate Members

Temporary tool to detect and merge duplicate members created by the `/auth/codebar` GitHub sign-in flow (codebar/planner#2805).

## Background

When the codebar auth app was merged into planner on 2026-08-06, members with a GitHub account whose email differed from their `auth_services` record could not be matched automatically. The codebar auth flow created new accounts instead of linking to existing ones.

This tool finds those duplicates (by name, email, and auth UID heuristics) and merges their data into the original member.

## Prerequisites

A PostgreSQL dump of the production database, accessible as `codebar_production_dump`.

## Tasks

### Detect duplicates

```bash
make detect_duplicate_members
```

Dry run — lists all duplicate pairs found, with which detection strategies matched.

### Fix duplicates (dry run)

```bash
make fix_duplicate_members
```

Shows every step the merger would take, but wraps everything in a transaction that is rolled back. No data is modified.

### Fix duplicates (execute)

```bash
make fix_duplicate_members APPLY=1
```

Performs the merge for real inside a transaction.
A JSON log file is written to:

```
log/merge_duplicate_members/run_YYYYMMDDTHHMMSSZ.json
```

The path is printed after the run completes.

### Verify

```bash
make verify_duplicate_members
```

Re-detects duplicates and exits `0` when none remain, or `1` with the remaining pairs.

## Detection strategies

| Strategy | Description |
|----------|-------------|
| `name+surname` | Exact case-insensitive match on both fields |
| `email` | Exact case-insensitive match on email |
| `first-name+uid-surname` | First name matches; duplicate has no surname, but the codebar auth UID contains the original’s surname |
| `domain+local-part` | Non-generic domain; local parts overlap |

The tool also applies hard-coded manual overrides for edge cases the heuristics cannot detect.

## Safety properties

- **Dry run by default** — must pass `APPLY=1` to change data.
- **Idempotent** — re-running after a successful merge reports no duplicates.
- **Deactivates, not deletes** — duplicates are renamed to `duplicate.<id>.merged-into.<id>@codebar.io`, with all auth services and roles removed. Audit history is preserved in a `MemberNote`.
- **Logs every execution** — merge results written to a new per-run JSON file, even on failure.

## Running in production

```bash
heroku run rake member:duplicates:detect --app codebar-production
heroku run rake member:duplicates:fix APPLY=1 --app codebar-production
heroku run rake member:duplicates:verify --app codebar-production
```

## What to do if a false positive appears

Duplicate pairs can be added to the `MANUAL_OVERRIDES` array or excluded before execution. If in doubt, err on the side of not merging — the merge does not delete records, but it does permanently move associated data and deactivate the account.

---

*This is a temporary tool. Once all existing duplicates are resolved, it can be removed.*
