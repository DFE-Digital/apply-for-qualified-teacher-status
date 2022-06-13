web: bin/rails db:migrate && bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: bundle exec sidekiq -C ./config/sidekiq.yml
