RSpec.configure do |config|
  config.around(:example, type: :system) do |example|
    ClimateControl.modify(BIGQUERY_DISABLE: "true") { example.run }
  end
end
