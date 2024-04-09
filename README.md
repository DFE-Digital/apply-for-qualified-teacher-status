# Apply for qualified teacher status

A service that allows international teachers to apply for qualified teacher status (QTS) in England.

## Environments

### Links

| Name           | URL                                                                                                            |
| -------------- | -------------------------------------------------------------------------------------------------------------- |
| Production     | [apply-for-qts-in-england.education.gov.uk](https://apply-for-qts-in-england.education.gov.uk)                 |
| Pre-production | [preprod.apply-for-qts-in-england.education.gov.uk](https://preprod.apply-for-qts-in-england.education.gov.uk) |
| Test           | [test.apply-for-qts-in-england.education.gov.uk](https://test.apply-for-qts-in-england.education.gov.uk)       |
| Development    | [dev.apply-for-qts-in-england.education.gov.uk](https://dev.apply-for-qts-in-england.education.gov.uk)         |

### Details and configuration

| Name           | Description                                   | Notify API key |
| -------------- | --------------------------------------------- | -------------- |
| Production     | Public site                                   | Live           |
| Pre-production | For internal use by DfE to test deploys       | Live           |
| Test           | For external use by 3rd parties to run audits | Live           |
| Development    | For internal use by DfE for testing           | Test           |

## Dependencies

- Ruby 3.x
- Node.js 16.x
- Yarn 1.22.x
- PostgreSQL 14.x
- Redis 7.x
- Terraform 1.5.x
- Kubectl 1.27.x

## How the application works

Apply for Qualified Teacher Status is a monolithic Rails app built with the GOV.UK Design System and hosted on Azure AKS.

We keep track of architecture decisions in [Architecture Decision Records (ADRs)](/adr/).

We use `rladr` to generate the boilerplate for new records:

```bash
bin/bundle exec rladr new title
```

## Setup

### Dependencies

Install dependencies using your preferred method, using `asdf` or `rbenv` or
`nvm`. Example with `asdf`:

```sh
# The first time
brew install asdf # Mac-specific
asdf plugin add ruby
asdf plugin add postgres # Unless you are managing postgres yourself
asdf plugin add nodejs
asdf plugin add yarn
asdf plugin add terraform
asdf plugin add azure-cli
asdf plugin add kubectl

# To install (or update, following a change to .tool-versions)
asdf install
```

#### VIPS

You’ll need to install `lipvips`. This varies on each operating system, but on macOS you can try this:

```bash
brew install libvips
```

#### PostgreSQL

You’ll need to install PostgreSQL. This can be installed via `asdf`, otherwise the way to do this is different on each operating system.

On macOS you can try the following:

```bash
brew install postgresql
```

If installed via `asdf`, start `postgres` database service if installed:

```sh
pg_ctl start
```

Set up the `postgres` user if it doesn't exist:

```sh
createdb default
psql -d default
> CREATE ROLE postgres LOGIN SUPERUSER;
```

#### Redis

You’ll need to install Redis. The way to do this is different on each operating system, but on macOS you can try the following:

```bash
brew install redis
brew services start redis
```

If installing Redis manually, you'll need to start it in a separate terminal:

```bash
redis-server
```

### Application

Setup the project (re-run after `Gemfile` or `package.json` updates, automatically restarts any running Rails server):

```bash
bin/setup
```

Generate fake application forms and staff. For development and non-production environments we have a script that generates useful fake data.

```bash
bundle exec rake fake_data:generate
```

To enable the 'personas' feature, from the rails console

```ruby
FeatureFlags::FeatureFlag.activate(:personas)
```

Navigate to /personas for persona based logins.

Run the application on `http://localhost:3000`:

```bash
bin/dev
```

### BigQuery

Edit `.env.local` and add a BigQuery key if you want to use BigQuery locally.

Set `BIGQUERY_DISABLE` to `false` as it defaults to `true` in the development environment.

[Read more about setting up BigQuery](docs/set-up-analytics.md).

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

## Licence

[MIT Licence](LICENCE).
