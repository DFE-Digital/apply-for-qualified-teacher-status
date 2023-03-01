# frozen_string_literal: true

RSpec.shared_examples "an expirable" do
  describe "#expired_at" do
    let(:expired_at) { subject.expired_at }

    it "doesn't raise an error" do
      expect { expired_at }.to_not raise_error
    end
  end

  describe "#after_expired" do
    let(:after_expired) { subject.after_expired(user: "User") }

    it "doesn't raise an error" do
      expect { after_expired }.to_not raise_error
    end
  end
end
