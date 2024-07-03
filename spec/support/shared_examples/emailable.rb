# frozen_string_literal: true

RSpec.shared_examples "an emailable" do
  describe "#find_by_email" do
    it "accepts nil" do
      expect { described_class.find_by_email(nil) }.not_to raise_error
    end
  end
end
