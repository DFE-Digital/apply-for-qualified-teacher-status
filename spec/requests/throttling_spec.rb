require "rails_helper"

RSpec.describe "Throttling", rack_attack: true do
  before { FeatureFlag.activate(:service_open) }

  shared_examples "throttled" do |path|
    context path do
      subject(:cache_count) do
        Rack::Attack.cache.count("requests by IP address:127.0.0.1", 1.minute)
      end

      before { get path }

      it { is_expected.to eq(2) }
    end
  end

  %w[
    /eligibility
    /eligibility/degree
    /eligibility/countries
    /eligibility/region
    /eligibility/qualifications
    /eligibility/teach-children
    /eligibility/start
    /eligibility/eligible
    /eligibility/ineligible
    /eligibility/misconduct
    /support
  ].each { |path| include_examples "throttled", path }
end
