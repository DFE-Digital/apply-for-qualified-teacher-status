# frozen_string_literal: true

RSpec.shared_examples "an expirable" do
  describe "#expires_at" do
    let(:expires_at) { subject.expires_at }

    it "doesn't raise an error" do
      expect { expires_at }.not_to raise_error
    end
  end

  describe "#after_expired" do
    let(:after_expired) { subject.after_expired(user: "User") }

    it "doesn't raise an error" do
      expect { after_expired }.not_to raise_error
    end
  end
end
