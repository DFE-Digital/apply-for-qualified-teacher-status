# 14. Moving to Solid Queue and Solid Cache

Date: 2026-07-28

## Status

Accepted

## Context

Redis currently serves two purposes in this application:

Background jobs - Sidekiq uses Redis as its queue and scheduler, with scheduled/cron jobs defined in config/schedule.yml via sidekiq-cron.

Caching - Rails.cache is configured as :redis_cache_store in production. RackAttack throttling is the only use case of it.

Rails 8 ships Solid Queue and Solid Cache as the default Active Job and cache backends which run on the Postgres we already operate, back up, and monitor.

Our goal is to remove the dependency on Redis and its cost, and to standardise on the framework-defaults rather than a per-environment Redis dependency. Other services within DfE have now successfully migrated to and run SolidQueue and SolidCache on the same primary DB, and we're looking to adopt the same approach.

## Decision

Migrate to SolidCache + SolidQueue and decommission Redis.

### Caching - SolidCache (delivered first)

https://github.com/rails/solid_cache

- Replace `:redis_cache_store` with `:solid_cache_store`.
- Keeping the cache in our primary database. A dedicated cache database is not justified as rack-attack is the only use case.

### Background jobs - SolidQueue (delivered second)

https://github.com/rails/solid_queue

- Replace Sidekiq and Sidekiq Cron with SolidQueue as the ActiveJob queue adaptor, replacing Sidekiq and `sidekiq-cron`.
- Run the queue in our primary database. Our volume justifies this decision. A dedicated queue database would re-introduce another cost and maintenance which is one the reasons we're moving away from a dedicated redis instance. Whenever justified, we will look to adjust the size of our database.
- Migrate recurring jobs from `config/schedule.yml` to `config/recurring.yml`.
- Add explicit retry rules per job, since Solid Queue has no built-in retry mechanism unlike Sidekiq.
- Replace SidekiqUI with [mission_control-jobs](https://github.com/rails/mission_control-jobs).

## Consequences

Positive:

- Redis and its cost are removed once both migrations complete, with no new database cost introduced.
- Job and cache state live in the primary DB which is then is backed-up and recoverable with application data.
- Aligns with the Rails 8 default and other services approach.

Negative and accepted costs:

- Queue and cache now writes and reads from the primary database alongside web requests. Accepted deliberately at current volume and will be closely monitored.
- The team cost of implementing the migration.
- The team loses the Sidekiq UI and must learn `mission_control-jobs`.
