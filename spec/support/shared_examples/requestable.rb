# frozen_string_literal: true

RSpec.shared_examples "a requestable" do
  describe "associations" do
    it { is_expected.to belong_to(:assessment) }
  end

  describe "validations" do
    it { is_expected.to_not validate_presence_of(:requested_at) }
    it { is_expected.to_not validate_presence_of(:received_at) }
    it { is_expected.to_not validate_presence_of(:expired_at) }
  end

  describe "#requested!" do
    let(:call) { subject.requested! }

    it "sets the requested at date" do
      freeze_time do
        expect { call }.to change(subject, :requested_at).from(nil).to(
          Time.zone.now,
        )
      end
    end
  end

  describe "#received!" do
    let(:call) { subject.received! }

    it "sets the received at date" do
      freeze_time do
        expect { call }.to change(subject, :received_at).from(nil).to(
          Time.zone.now,
        )
      end
    end
  end

  describe "#expired!" do
    let(:call) { subject.expired! }

    it "sets the received at date" do
      freeze_time do
        expect { call }.to change(subject, :expired_at).from(nil).to(
          Time.zone.now,
        )
      end
    end
  end

  describe "#status" do
    it "is completed when review passed is true" do
      subject.review_passed = true
      expect(subject.status).to eq("completed")
    end

    it "is rejected when review passed is false" do
      subject.review_passed = false
      expect(subject.status).to eq("rejected")
    end

    it "is received when received at is set" do
      subject.received_at = Time.zone.now
      expect(subject.status).to eq("received")
    end

    it "is overdue when expired at is set" do
      subject.expired_at = Time.zone.now
      expect(subject.status).to eq("overdue")
    end

    it "is waiting on when requested at is set" do
      subject.requested_at = Time.zone.now
      expect(subject.status).to eq("waiting_on")
    end

    it "is cannot start by default" do
      expect(subject.status).to eq("cannot_start")
    end
  end

  describe "#review_status" do
    it "is accepted when passed is true" do
      subject.review_passed = true
      expect(subject.review_status).to eq("accepted")
    end

    it "is rejected when passed is false" do
      subject.review_passed = false
      expect(subject.review_status).to eq("rejected")
    end

    it "is not started if not reviewed" do
      expect(subject.review_status).to eq("not_started")
    end
  end

  describe "#verify_status" do
    it "is accepted when passed is true" do
      if subject.respond_to?(:verify_passed)
        subject.verify_passed = true
        expect(subject.verify_status).to eq("accepted")
      end
    end

    it "is rejected when passed is false" do
      if subject.respond_to?(:verify_passed)
        subject.verify_passed = false
        expect(subject.verify_status).to eq("rejected")
      end
    end

    it "is not started if not verified" do
      expect(subject.verify_status).to eq("not_started")
    end
  end

  describe "#after_requested" do
    let(:after_requested) { subject.after_requested(user: "User") }

    before { subject.requested! }

    it "doesn't raise an error" do
      expect { after_requested }.to_not raise_error
    end
  end

  describe "#after_received" do
    let(:after_received) { subject.after_received(user: "User") }

    it "doesn't raise an error" do
      expect { after_received }.to_not raise_error
    end
  end

  describe "#after_reviewed" do
    let(:after_reviewed) { subject.after_reviewed(user: "User") }

    it "doesn't raise an error" do
      expect { after_reviewed }.to_not raise_error
    end
  end

  describe "#after_verified" do
    let(:after_verified) { subject.after_verified(user: "User") }

    it "doesn't raise an error" do
      expect { after_verified }.to_not raise_error
    end
  end

  include_examples "an expirable"
end
