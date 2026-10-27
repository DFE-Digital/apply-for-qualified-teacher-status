# Apply for qualified teacher status

A service that allows overseas trained teachers to apply for qualified teacher status (QTS) in England.

Apply for QTS is a monolithic Rails app built with the GOV.UK Design System and hosted on Azure AKS.

## Getting started

New to the project? Start with the [developer guide](docs/development/README.md), including [local setup](docs/development/setup.md) and [tests and linting](docs/development/README.md#tests-and-linting).

## Documentation

- [Documentation index](docs/README.md)
- [Architecture](docs/architecture/architecture.md)
- [Application lifecycle](docs/application-forms.md)
- [Architecture decision records](adr/README.md)
- [Infrastructure](docs/infrastructure.md)

## Environments

### Links

| Name        | URL                                                                                                      |
| ----------- | -------------------------------------------------------------------------------------------------------- |
| Production  | [apply-for-qts-in-england.education.gov.uk](https://apply-for-qts-in-england.education.gov.uk)           |
| Test        | [test.apply-for-qts-in-england.education.gov.uk](https://test.apply-for-qts-in-england.education.gov.uk) |
| Development | [dev.apply-for-qts-in-england.education.gov.uk](https://dev.apply-for-qts-in-england.education.gov.uk)   |

### Details and configuration

| Name        | Description                              | Notify API key |
| ----------- | ---------------------------------------- | -------------- |
| Production  | Public site                              | Live           |
| Test        | For internal use by DfE for testing      | Live           |
| Development | For internal use by dev team for testing | Test           |

## Using AI tools

If you use AI coding assistants (for example GitHub Copilot, Claude or ChatGPT) to help write code for this repository:

- Only use an organisation-approved Pro/Enterprise/Business tier account that has usage and prompt data excluded from model training
- Never paste secrets, credentials, API keys, `.env` contents or real personal data into a prompt, chat window or third-party AI tool
- Review and understand all AI-generated code before committing it; you remain responsible for its correctness and security
- Follow the conventions in [AGENTS.md](AGENTS.md), which coding agents are configured to read automatically
- Disclose AI assistance in every commit with a `Co-authored-by:` trailer, as described in `AGENTS.md`

## License

[MIT License](LICENSE).
