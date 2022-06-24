require "rails_helper"

RSpec.describe FeatureFlag do
  let(:feature) { create(:feature, name: feature_name) }
  let(:feature_name) { :service_open }

  describe ".activate" do
    it "activates a feature" do
      expect { described_class.activate(feature_name) }.to change {
        described_class.active?(feature_name)
      }.from(false).to(true)
    end

    it "records the change in the database" do
      feature.update!(active: false)
      expect { described_class.activate(feature_name) }.to change {
        feature.reload.active
      }.from(false).to(true)
    end
  end

  describe ".deactivate" do
    it "deactivates a feature" do
      # To avoid flakey tests where activation/deactivation happens at the same time
      travel_to(5.minutes.ago) { described_class.activate(feature_name) }
      expect { described_class.deactivate(feature_name) }.to change {
        described_class.active?(feature_name)
      }.from(true).to(false)
    end

    it "records the change in the database" do
      feature.update!(active: true)
      expect { described_class.deactivate(feature_name) }.to change {
        feature.reload.active
      }.from(true).to(false)
    end
  end
end
