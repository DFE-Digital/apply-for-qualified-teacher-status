# Documentation

## Development

- [Developer guide](development/README.md): joining the project, finding your way around, tests and linting.
- [Local setup](development/setup.md): install dependencies, prepare the database and run the application.

## Understanding the service

- [Architecture](architecture/architecture.md)
- [Application forms](application-forms.md)
- [Countries and regions](countries-and-regions.md)
- [Authentication](authentication.md)
- [History and back links](history-and-back-links.md)
- [Architecture decision records](../adr/README.md)

## Operations

- [Infrastructure](infrastructure.md)
- [Monitoring](monitoring.md)
- [Logging](logging.md)
- [Setting up analytics](setting-up-analytics.md)
- [Assessment check and failure reason updates](assessment-checks-and-failure-reason-updates.md)
- [Application form fixes](application-fixes.md)

The [infrastructure validation workflow](../.github/workflows/validate-infrastructure.yml) runs daily at 07:00 UTC against production and uses the configured Teams webhook for notifications.
