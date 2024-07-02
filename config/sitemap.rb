# frozen_string_literal: true

# Run `bundle exec rails sitemap:refresh` after making changes to this file.

SitemapGenerator::Sitemap.default_host =
  "https://apply-for-qts-in-england.education.gov.uk"
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do # rubocop:disable Rails/SaveBang
  add create_or_new_teacher_session_path, changefreq: :monthly
  add accessibility_path, changefreq: :monthly
  add cookies_path, changefreq: :monthly
  add privacy_path, changefreq: :monthly
end
