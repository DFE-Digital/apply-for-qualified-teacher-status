# Architecture decision records

These records explain the context and reasoning behind technical decisions. For setup and current service guides, see the [documentation index](../docs/README.md).

## Decisions

1. [Record architecture decisions](00001-record-architecture-decisions.md)
2. [Reuse existing architecture](00002-reuse-existing-architecture.md)
3. [Model countries and regions](00003-model-countries-and-regions.md)
4. [Tracking usage](00004-tracking-usage.md)
5. [Sending emails](00005-sending-emails.md)
6. [Storing files](00006-storing-files.md)
7. [Application forms](00007-application-forms.md)
8. [View objects](00008-view-objects.md)
9. [Assessments](00009-assessments.md)
10. [GOV.UK One Login](00010-govuk-one-login.md)
11. [Prioritisation checks](00011-prioritisation-checks.md)
12. [Tracking email deliveries](00012-tracking-email-deliveries.md)
13. [PDF generation](00013-pdf-generation.md)
14. [Solid Queue and Solid Cache](00014-solid_cache_and_solid_queue.md)

## Adding a record

Use `rladr` to generate the boilerplate:

```bash
bin/bundle exec rladr new title
```
