# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    ActiveStorage::Current.url_options = { host: "localhost", port: 3000 }
  end
end
