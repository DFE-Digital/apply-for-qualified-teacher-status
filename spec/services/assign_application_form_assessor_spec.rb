# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignApplicationFormAssessor do
  let!(:application_form) { create(:application_form, :submitted) }
  let(:user) { create(:staff) }
  let(:assessor) { create(:staff) }

  subject(:call) { described_class.call(application_form:, user:, assessor:) }

  describe "application form assessor" do
    subject(:assessor) { application_form.assessor }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be(assessor) }
    end
  end

  describe "record timeline event" do
    subject(:timeline_event) do
      TimelineEvent.assessor_assigned.find_by(application_form:)
    end

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(timeline_event.creator).to eq(user)
        expect(timeline_event.assignee).to eq(assessor)
      end
    end
  end
end
