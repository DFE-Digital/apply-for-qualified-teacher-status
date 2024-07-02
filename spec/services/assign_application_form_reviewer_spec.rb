# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignApplicationFormReviewer do
  subject(:call) { described_class.call(application_form:, user:, reviewer:) }

  let!(:application_form) { create(:application_form, :submitted) }
  let(:user) { create(:staff) }
  let(:reviewer) { create(:staff) }

  describe "application form reviewer" do
    subject(:reviewer) { application_form.reviewer }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be(reviewer) }
    end
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :reviewer_assigned,
      creator: user,
      assignee: reviewer,
    )
  end
end
