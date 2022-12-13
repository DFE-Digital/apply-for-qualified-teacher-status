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

  describe "#notes_from_assessors" do
    subject(:notes_from_assessors) { view_object.notes_from_assessors }

    it { is_expected.to be_empty }

    context "with failure reasons" do
      let(:application_form) do
        create(:application_form, teacher: current_teacher)
      end
      let(:assessment) { create(:assessment, application_form:) }
      let(:assessment_section) do
        create(:assessment_section, :personal_information, :failed, assessment:)
      end
      let!(:failure_reasons) { assessment_section.selected_failure_reasons }

      it do
        is_expected.to eq(
          [
            {
              assessment_section_key: "personal_information",
              failure_reasons:
                failure_reasons.map do |failure_reason|
                  {
                    assessor_feedback: failure_reason.assessor_feedback,
                    is_decline: false,
                    key: failure_reason.key,
                  }
                end,
            },
          ],
        )
      end
    end
  end

  describe "#show_further_information_request_expired_content?" do
    let(:application_form) do
      create(:application_form, teacher: current_teacher)
    end
    let(:assessment) { create(:assessment, application_form:) }

    subject(:show_fi_expired) do
      view_object.show_further_information_request_expired_content?
    end

    context "when further_information_request is present" do
      context "and it has expired" do
        let!(:further_information_request) do
          create(:further_information_request, :expired, assessment:)
        end
        it { is_expected.to eq(true) }
      end

      context "and it hasn't expired" do
        let!(:further_information_request) do
          create(:further_information_request, assessment:)
        end
        it { is_expected.to eq(false) }
      end
    end

    context "when further_information_request is nil" do
      it { is_expected.to eq(false) }
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

      context "with sanctions" do
        let!(:assessment_section) do
          create(
            :assessment_section,
            :personal_information,
            :declines_with_sanctions,
            assessment:,
          )
        end

        it { is_expected.to be true }
      end

      context "with already QTS" do
        let!(:assessment_section) do
          create(
            :assessment_section,
            :personal_information,
            :declines_with_already_qts,
            assessment:,
          )
        end

        it { is_expected.to be true }
      end
    end
  end
end
