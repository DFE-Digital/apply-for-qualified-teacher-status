# Developer guide

## Joining the project

Before your first change, confirm with the team that you have:

- The GitHub access needed to contribute to this repository.
- Access to the team's communication and work-tracking tools.
- Someone to help with setup and explain the review and release process.

Access to deployed environments and external services is separate from local setup. Ask the team for the approved access process when your work needs those services; do not copy credentials from another developer.

## Start locally

Follow [local setup](setup.md) to install dependencies, create fake data and run the application. Use the personas page to explore both teacher and staff journeys.

Once the application runs, these are useful starting points:

- [Architecture](../architecture/architecture.md): the service's main components.
- [Application forms](../application-forms.md): the assessment journey and domain terminology.
- [Countries and regions](../countries-and-regions.md): regional requirements.
- [Architecture decisions](../../adr/README.md): the reasons behind technical choices.

There are four interfaces: eligibility checks, teacher (application), assessor (assessments) and support (configuration). The [routes](../../config/routes.rb) show their entry points.

## Tests and linting

### Tests

Run a focused spec while developing:

```bash
bundle exec rspec spec/models/application_form_spec.rb
```

To run the tests excluding smoke tests:

```bash
bin/test
```

System specs use Cuprite and need Chrome or Chromium installed. Before running them, build the assets and prepare the local test database:

```bash
yarn build
yarn build:css
RAILS_ENV=test bin/rails db:test:prepare
```

Run the relevant system spec with `bundle exec rspec`, as with other specs. Use the existing page objects when adding journey tests.

### Linting

The lint script runs RuboCop with `--autocorrect-all`, Prettier with `--write`, and Brakeman:

```bash
bin/lint
```

This script **rewrites files** using RuboCop autocorrection and Prettier formatting. Review its diff before committing.

For the same check-only style commands used by CI:

```bash
bin/bundle exec rubocop
yarn prettier --check --ignore-unknown '**/*'
```

### Static security analysis

The automated deployment pipeline runs Brakeman on pull requests and pushes to `main`. CI shows a summary because this repository is public; run it locally to investigate a failure:

```bash
bin/bundle exec brakeman
```

If a warning is a false positive, use the interactive ignore process and provide a note explaining why it is safe:

```bash
bin/bundle exec brakeman -I
```

## Your first change

Follow the existing patterns in the relevant interface, use the [pull request template](../../.github/PULL_REQUEST_TEMPLATE.md), and run the checks covering your change. [AGENTS.md](../../AGENTS.md) records repository conventions, and the [root README](../../README.md#using-ai-tools) explains the requirements for AI-assisted work.

For deployment and service investigation, start with the existing [infrastructure](../infrastructure.md), [monitoring](../monitoring.md) and [logging](../logging.md) guides.
