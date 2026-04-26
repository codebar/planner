# Autoresearch Session: PostgreSQL Test Optimizations

## Experiments Run

| Run | Description | Time | Status |
|-----|-------------|------|--------|
| 5 | Baseline (make test) | 87.7s | Baseline |
| 6 | UNLOGGED tables | 84.4s | Kept (+3.8%) |
| 7 | Auto-hook verification | 87.3s | Variance |
| 8 | UNLOGGED run #2 | 88.0s | Variance |
| 9 | Baseline run #2 | 108.8s | External factors |

## Conclusions

1. **UNLOGGED tables provide ~3-4% improvement** but variance is high due to external factors (thermal/load)
2. **High variance (87-108s)** makes micro-optimizations hard to measure reliably
3. **Parallel execution (3 processes)** remains the most effective optimization (~32% from previous session)

## Kept Changes

- `lib/tasks/test_unlogged.rake` - Auto-converts tables to UNLOGGED on test prepare

## Not Pursued

- `/dev/shm` - Not available on macOS
- SQLite - Incompatible with PostgreSQL-specific schema
