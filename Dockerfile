# This template builds two images, to optimise caching:
# builder: builds gems and node modules
# production: runs the actual app

# Build builder image
FROM ruby:3.4.3-alpine3.21 as builder

WORKDIR /app

# Add the timezone (builder image) as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

# Upgrade ssl, crypto and curl libraries to latest version
RUN apk upgrade --no-cache openssl libssl3 libcrypto3 curl expat

# build-base: dependencies for bundle
# yarn: node package manager
# postgresql-dev: postgres driver and libraries
# git: dependencies for bundle
# vips-dev: dependencies for ruby-vips (image processing library)
# imagemagick-dev: dependencies for rmagick (image conversion library)
# poppler-utils: for analysing PDF files
RUN apk add --update --no-cache build-base yarn postgresql15-dev git vips-dev imagemagick-dev poppler-utils yaml-dev

# Install gems defined in Gemfile
COPY Gemfile Gemfile.lock ./

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
    GOVUK_NOTIFY_V2_API_KEY=required-to-run-but-not-used \
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
FROM ruby:3.4.3-alpine3.21 as production

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

# Upgrade ssl, crypto and curl libraries to latest version
RUN apk upgrade --no-cache openssl libssl3 libcrypto3 curl expat

# libpq: required to run postgres
# vips-dev: dependencies for ruby-vips (image processing library)
# libreoffice-writer: for converting word documents to PDF
# imagemagick-dev and imagemagick-pdf: for converting images to PDF
# poppler-utils: for analysing PDF files
RUN apk add --update --no-cache libpq vips-dev libreoffice-writer imagemagick-dev imagemagick-pdf poppler-utils

# Install fonts suitable for rendering DOCX and ODT files to PDF
# https://wiki.alpinelinux.org/wiki/Fonts#Installation
RUN apk add font-terminus font-bitstream-100dpi font-bitstream-75dpi font-bitstream-type1 font-noto font-noto-extra font-arabic-misc font-misc-cyrillic font-mutt-misc font-screen-cyrillic font-winitzki-cyrillic font-cronyx-cyrillic font-noto-arabic font-noto-armenian font-noto-cherokee font-noto-devanagari font-noto-ethiopic font-noto-georgian font-noto-hebrew font-noto-lao font-noto-malayalam font-noto-tamil font-noto-thaana font-noto-thai

# Copy files generated in the builder image
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && \
    bundle exec rails server -b 0.0.0.0
