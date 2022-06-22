# 2. Reuse existing architecture

Date: 2022-05-16

## Status

Accepted

## Context

Apply for qualified teacher status in England is a monolithic Rails application
and should use a similar architecture to other monoliths, like [Find a lost
TRN](https://github.com/DFE-Digital/find-a-lost-trn) or [Apply for Teacher Training](https://github.com/DFE-Digital/apply-for-teacher-training).

## Decision

We adopt the following ADRs wholesale and agree to follow their decisions:

### From "Find a lost TRN"

- [2. Use GOV.UK PaaS](https://github.com/DFE-Digital/find-a-lost-trn/blob/main/adr/00002-use-gov-paas.md)
- [3. Use a Ruby on Rails monolith](https://github.com/DFE-Digital/find-a-lost-trn/blob/main/adr/00003-use-rails.md)
- [4. Use Postgres](https://github.com/DFE-Digital/find-a-lost-trn/blob/main/adr/00004-use-postgres-state.md)
- [5. Use automated tooling to check for security vulnerabilities](https://github.com/DFE-Digital/find-a-lost-trn/blob/main/adr/00005-use-gemsurance-and-.md)
- [6. Use Sidekiq and Redis](https://github.com/DFE-Digital/find-a-lost-trn/blob/main/adr/00006-sidekiq-and-redis.md)
- [7. Use scheduled jobs with sidekiq_cron](https://github.com/DFE-Digital/find-a-lost-trn/blob/main/adr/00007-scheduled-jobs.md)

### From "Apply for Teacher Training"

- [2. Use Devise for authentication](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/adr/0002-use-devise-for-authentication.md)

## Consequences

- We don't have to justify the same decisions
- We can still make adjustments by creating new ADRs down the line
- Knowledge transfer between teams is simpler
- Sharing code and modules is simpler
