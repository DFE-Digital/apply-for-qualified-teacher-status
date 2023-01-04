# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChangeApplicationFormState do
  let!(:application_form) { create(:application_form, :submitted) }
  let(:user) { create(:staff) }
  let(:new_state) { :awarded_pending_checks }

  subject(:call) { described_class.call(application_form:, user:, new_state:) }

  describe "application form status" do
    subject(:state) { application_form.state }

    it { is_expected.to eq("submitted") }

    context "after calling the service" do
      before { call }

      it { is_expected.to eq("awarded_pending_checks") }
    end
  end

  describe "record timeline event" do
    subject(:timeline_event) do
      TimelineEvent.find_by(
        application_form:,
        new_state: "awarded_pending_checks",
      )
    end

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(timeline_event.creator).to eq(user)
        expect(timeline_event.old_state).to eq("submitted")
        expect(timeline_event.new_state).to eq("awarded_pending_checks")
      end
    end
  end
end
