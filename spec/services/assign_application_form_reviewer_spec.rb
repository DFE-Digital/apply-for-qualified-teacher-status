# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignApplicationFormReviewer do
  let!(:application_form) { create(:application_form, :submitted) }
  let(:user) { create(:staff) }
  let(:reviewer) { create(:staff) }

  subject(:call) { described_class.call(application_form:, user:, reviewer:) }

  describe "application form reviewer" do
    subject(:reviewer) { application_form.reviewer }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be(reviewer) }
    end
  end

  describe "record timeline event" do
    subject(:timeline_event) do
      TimelineEvent.reviewer_assigned.find_by(application_form:)
    end

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(timeline_event.creator).to eq(user)
        expect(timeline_event.assignee).to eq(reviewer)
      end
    end
  end
end
