# Local setup

These steps run the application on your machine with a local database and fake data.

## 1. Install dependencies

You will need:

- Ruby: use the version in [`.ruby-version`](../../.ruby-version).
- Node.js and Yarn: use the versions in [package.json](../../package.json).
- PostgreSQL 17.
- libvips.

Use your preferred version manager for Ruby and Node.js. For example, on macOS with asdf:

```bash
brew install asdf
asdf plugin add ruby
asdf plugin add nodejs
asdf install ruby
asdf install nodejs
corepack enable
```

Install libvips with your operating system's package manager. On macOS:

```bash
brew install libvips
```

Chrome or Chromium is also needed for [system specs](README.md#tests).

Terraform, Azure CLI and kubectl are not needed for this local setup. See [infrastructure](../infrastructure.md) when working with deployed environments.

## 2. Start PostgreSQL

On macOS with Homebrew:

```bash
brew install postgresql@17
brew services start postgresql@17
```

## 3. Prepare the application

Clone the repository if you have not already.

From the repository root, run:

```bash
bin/setup
```

This installs Ruby and JavaScript dependencies, copies the sample configuration to `.env.local` if needed, prepares the database, clears local logs and temporary files, and requests a Rails restart. Re-run it after dependency updates.

Keep local environment files out of version control. If database setup fails, check that PostgreSQL is running and that any local `DATABASE_URL` override points to your local database.

## 4. Generate fake data and enable personas

Generate fake application forms and staff:

```bash
bundle exec rake fake_data:generate
```

The task skips generation if staff or teachers already exist. Do not reset a populated database just to repeat this step.

Open the Rails console:

```bash
bin/rails console
```

Enable the personas feature:

```ruby
FeatureFlags::FeatureFlag.activate(:personas)
```

Exit the console before starting the application.

## 5. Run the application

```bash
bin/dev
```

This starts the Rails server, Solid Queue worker and JavaScript/CSS watchers from [Procfile.dev](../../Procfile.dev). Keep the terminal open while using the application.

Open [localhost:3000](http://localhost:3000), then [the personas page](http://localhost:3000/personas). Select a teacher or staff persona to explore a journey.

Setup is complete when the processes stay running, pages load with styling, and you can enter a journey through personas. If a process exits, check its output before continuing.

Next, follow [tests and linting](README.md#tests-and-linting).

## Optional: analytics

BigQuery is not required for ordinary local development. Analytics is disabled by default in development; enable it only when your work requires it.

See [setting up analytics](../setting-up-analytics.md) and agree local access with the team before adding credentials or setting `BIGQUERY_DISABLE=false`.
