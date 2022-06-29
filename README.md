# Apply for qualified teacher status

A service that allows international teachers to apply for qualified teacher status (QTS) in England.

## Environments

| Name        | URL                                                                                                                    |
| ----------- | ---------------------------------------------------------------------------------------------------------------------- |
| Production  | [apply-for-qts-in-england.education.gov.uk](https://apply-for-qts-in-england.education.gov.uk)                         |
| Development | [apply-for-qts-in-england-dev.london.cloudapps.digital](https://apply-for-qts-in-england-dev.london.cloudapps.digital) |

## Dependencies

- Ruby 3.x
- Node.js 16.x
- Yarn 1.22.x
- PostgreSQL 13.x
- Redis 7.x
- Terraform 1.0.x

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

```sh
# The first time
brew install asdf # Mac-specific
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn
asdf plugin add terraform

# To install (or update, following a change to .tool-versions)
asdf install
```

You'll also need to install PostgreSQL 13.x. The way to do this is different on
each operating system, but on macOS you can try the following:

```bash
brew install postgresql@13
# Add to utilities to the path
echo 'export PATH="/opt/homebrew/opt/postgresql@13/bin:$PATH"' >> ~/.zshrc
```

Set up the `postgres` user if it doesn't exist:

```sh
createdb default
psql -d default
> CREATE ROLE postgres LOGIN SUPERUSER;
```

You'll also need to install Redis 6.x. The way to do this is different on
each operating system, but on macOS you can try the following:

```bash
brew install redis@6
brew services start redis
```

If installing Redis manually, you'll need to start it in a separate terminal:

```bash
redis-server
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

### BigQuery

Edit `.env.local` and add a BigQuery key if you want to use BigQuery locally.

Set `BIGQUERY_DISABLE` to `false` as it defaults to `true` in the development environment.

[Read more about setting up BigQuery](docs/set-up-analytics.md).

### Intellisense

[solargraph](https://github.com/castwide/solargraph) is bundled as part of the
development dependencies. You need to [set it up for your
editor](https://github.com/castwide/solargraph#using-solargraph), and then run
this command to index your local bundle (re-run if/when we install new
dependencies and you want completion):

```sh
bin/bundle exec yard gems
```

You'll also need to configure your editor's `solargraph` plugin to
`useBundler`:

```diff
+  "solargraph.useBundler": true,
```

### Linting

To run the linters:

```bash
bin/lint
```

### Testing

To run the tests:

```bash
bin/test
```

### Ops manual

[Ops manual](docs/ops-manual.md).

## Licence

[MIT Licence](LICENCE).
