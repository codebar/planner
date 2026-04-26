# Deferred Optimizations for Test Performance

## /dev/shm (tmpfs) for PostgreSQL
- **Status**: NOT POSSIBLE on macOS - no native tmpfs support like Linux /dev/shm
- **Alternative**: Could use `diskutil erasevolume HFS+ "RAMDisk" $(hdiutil attach -nomount ram://$((2*1024*1024)))` to create a ramdisk
- **Complexity**: High - requires managing PostgreSQL data directory, starting separate instance
- **Potential benefit**: 20-50% speedup (memory vs SSD)

## SQLite in-memory (previously tested)
- **Status**: IMPOSSIBLE - schema uses PostgreSQL-specific syntax:
  - `::text` type casts in filtered indexes
  - Custom enum types (`dietary_restriction_enum`)
  - PostgreSQL extensions

## UNLOGGED tables (in progress)
- Modifying all CREATE TABLE to CREATE UNLOGGED TABLE in schema.rb
- Bypasses WAL (Write-Ahead Logging) for faster writes
- Good for test databases that are recreated each run
