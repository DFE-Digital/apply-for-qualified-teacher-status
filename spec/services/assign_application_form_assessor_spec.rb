# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignApplicationFormAssessor do
  subject(:call) { described_class.call(application_form:, user:, assessor:) }

  let!(:application_form) { create(:application_form, :submitted) }
  let(:user) { create(:staff) }
  let(:assessor) { create(:staff) }

  describe "application form assessor" do
    subject(:assessor) { application_form.assessor }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be(assessor) }
    end
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :assessor_assigned,
      creator: user,
      assignee: assessor,
    )
  end
end
