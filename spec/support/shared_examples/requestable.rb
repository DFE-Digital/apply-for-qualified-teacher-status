# frozen_string_literal: true

RSpec.shared_examples "a requestable" do
  it do
    is_expected.to define_enum_for(:state).with_values(
      requested: "requested",
      received: "received",
      expired: "expired",
    ).backed_by_column_of_type(:string)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:state) }

    it { is_expected.to_not validate_presence_of(:received_at) }

    context "when received" do
      before { subject.state = "received" }

      it { is_expected.to validate_presence_of(:received_at) }
    end
  end

  describe "#received!" do
    let(:call) { subject.received! }

    it "changes the state" do
      expect { call }.to change(subject, :received?).from(false).to(true)
    end

    it "sets the received at date" do
      freeze_time do
        expect { call }.to change(subject, :received_at).from(nil).to(
          Time.zone.now,
        )
      end
    end
  end
end
