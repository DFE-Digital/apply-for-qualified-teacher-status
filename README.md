# Apply for qualified teacher status

A service that allows international teachers to apply for qualified teacher status (QTS) in England.

## Dependencies

- Ruby 3.x
- Node.js 16.x
- Yarn 1.22.x
- PostgreSQL 13.x

## How the application works

Apply for qualified teacher status is a monolithic Rails app built with the
GOVUK Design System and hosted on GOVUK PaaS.

We keep track of architecture decisions in [Architecture Decision Records
(ADRs)](/adr/).

We use `rladr` to generate the boilerplate for new records:

```bash
bin/bundle exec rladr new title
```

## Setup

Install dependencies using your preferred method, using `asdf` or `rbenv` or
`nvm`. Example with `asdf`:

```bash
# The first time
brew install asdf # Mac-specific
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn

# To install (or update, following a change to .tool-versions)
asdf install
```

Setup the project (re-run after `Gemfile` or `package.json` updates,
automatically restarts any running Rails server):

```bash
bin/setup
```

Run the application on `http://localhost:3000`:

```bash
bin/dev
```

### Linting

TODO: Linting

<!-- To run the linters: -->

<!-- ```bash -->
<!-- bin/lint -->
<!-- ``` -->

### Testing

TODO: Test script

<!-- To run the tests: -->

<!-- ```bash -->
<!-- bin/test -->
<!-- ``` -->

## Licence

[MIT Licence](LICENCE).
