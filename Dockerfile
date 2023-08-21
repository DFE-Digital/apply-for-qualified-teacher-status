# This template builds two images, to optimise caching:
# builder: builds gems and node modules
# production: runs the actual app

# Build builder image
FROM ruby:3.2.2-alpine as builder

WORKDIR /app

# Add the timezone (builder image) as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

# Upgrade ssl and crypto libraries to latest version
RUN apk upgrade openssl libssl3 libcrypto3

# build-base: dependencies for bundle
# yarn: node package manager
# postgresql-dev: postgres driver and libraries
# git: dependencies for bundle
# vips-dev: dependencies for ruby-vips (image processing library)
RUN apk add --no-cache build-base yarn postgresql14-dev git vips-dev

# Install gems defined in Gemfile
COPY .ruby-version Gemfile Gemfile.lock ./

# Install gems and remove gem cache
RUN bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle config set without 'development test' && \
    bundle install --retry=5 --jobs=4 && \
    rm -rf /usr/local/bundle/cache

# Install node packages defined in package.json
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --check-files

# Copy all files to /app (except what is defined in .dockerignore)
COPY . .

# Build app/assets/builds/application.{css,js}
RUN yarn build && yarn build:css

# Precompile assets
RUN RAILS_ENV=production \
    SECRET_KEY_BASE=required-to-run-but-not-used \
    GOVUK_NOTIFY_API_KEY=required-to-run-but-not-used \
    REDIS_URL=redis://required-to-run-but-not-used \
    bundle exec rails assets:precompile

# Cleanup to save space in the production image
RUN rm -rf node_modules log/* tmp/* /tmp && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf .env && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete

# Build runtime image
FROM ruby:3.2.2-alpine as production

# The application runs from /app
WORKDIR /app

# Set Rails environment to production
ENV RAILS_ENV=production

# Add the commit sha to the env
ARG SHA
ENV SHA=$SHA

# Add the timezone (prod image) as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

# libpq: required to run postgres
# vips-dev: dependencies for ruby-vips (image processing library)
RUN apk add --no-cache libpq vips-dev

# Upgrade ssl and crypto libraries to latest version
RUN apk upgrade openssl libssl3 libcrypto3

# Copy files generated in the builder image
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && \
    bundle exec rails server -b 0.0.0.0
