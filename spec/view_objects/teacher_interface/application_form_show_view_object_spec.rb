# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ApplicationFormShowViewObject do
  subject(:view_object) { described_class.new(current_teacher:) }

  let(:current_teacher) { create(:teacher, :confirmed) }

  describe "#application_form" do
    subject(:application_form) { view_object.application_form }

    it { is_expected.to be_nil }

    context "with an application form" do
      before { create(:application_form, teacher: current_teacher) }

      it { is_expected.to_not be_nil }
    end
  end

  describe "#assessment" do
    subject(:assessment) { view_object.assessment }

    it { is_expected.to be_nil }

    context "with an assessment form" do
      before do
        application_form = create(:application_form, teacher: current_teacher)
        create(:assessment, application_form:)
      end

      it { is_expected.to_not be_nil }
    end
  end

  describe "#further_information_request" do
    subject(:further_information_request) do
      view_object.further_information_request
    end

    it { is_expected.to be_nil }

    context "with an application form" do
      before do
        application_form = create(:application_form, teacher: current_teacher)
        assessment = create(:assessment, application_form:)
        create(:further_information_request, assessment:)
      end

      it { is_expected.to_not be_nil }
    end
  end

  describe "#declined_cannot_reapply?" do
    subject(:declined_cannot_reapply?) { view_object.declined_cannot_reapply? }

    it { is_expected.to be false }

    context "with failure reasons" do
      let(:application_form) do
        create(:application_form, teacher: current_teacher)
      end
      let(:assessment) { create(:assessment, application_form:) }

      before do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          selected_failure_reasons: {
            failure_reason => "A note.",
          },
          assessment:,
        )
      end

      context "with sanctions" do
        let(:failure_reason) { "authorisation_to_teach" }
        it { is_expected.to be true }
      end

      context "with already QTS" do
        let(:failure_reason) { "applicant_already_qts" }
        it { is_expected.to be true }
      end
    end
  end
end
