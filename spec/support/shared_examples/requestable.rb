# frozen_string_literal: true

RSpec.shared_examples "a requestable" do
  describe "associations" do
    it { is_expected.to belong_to(:assessment) }
  end

  describe "validations" do
    it { is_expected.to_not validate_presence_of(:requested_at) }
    it { is_expected.to_not validate_presence_of(:received_at) }
    it { is_expected.to_not validate_presence_of(:expired_at) }

    context "when reviewed" do
      before { subject.passed = [true, false].sample }

      it { is_expected.to validate_presence_of(:reviewed_at) }
    end
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

  [true, false].each do |passed|
    describe "#reviewed!(#{passed})" do
      let(:call) { subject.reviewed!(passed) }

      it "changes passed field" do
        expect { call }.to change(subject, :passed).from(nil).to(passed)
      end

      it "sets the reviewed at date" do
        freeze_time do
          expect { call }.to change(subject, :reviewed_at).from(nil).to(
            Time.zone.now,
          )
        end
      end
    end
  end

  describe "#status" do
    it "is accepted when passed is true" do
      subject.passed = true
      subject.reviewed_at = Time.zone.now
      expect(subject.status).to eq("accepted")
    end

    it "is rejected when passed is false" do
      subject.passed = false
      subject.reviewed_at = Time.zone.now
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

    it "is not started by default" do
      expect(subject.status).to eq("not_started")
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

  include_examples "an expirable"
end
