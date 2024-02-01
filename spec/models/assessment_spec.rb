# frozen_string_literal: true

# == Schema Information
#
# Table name: assessments
#
#  id                                        :bigint           not null, primary key
#  age_range_max                             :integer
#  age_range_min                             :integer
#  age_range_note                            :text             default(""), not null
#  induction_required                        :boolean
#  qualifications_assessor_note              :text             default(""), not null
#  recommendation                            :string           default("unknown"), not null
#  recommendation_assessor_note              :text             default(""), not null
#  recommended_at                            :datetime
#  references_verified                       :boolean
#  scotland_full_registration                :boolean
#  started_at                                :datetime
#  subjects                                  :text             default([]), not null, is an Array
#  subjects_note                             :text             default(""), not null
#  unsigned_consent_document_generated       :boolean          default(FALSE), not null
#  working_days_since_started                :integer
#  working_days_started_to_recommendation    :integer
#  working_days_submission_to_recommendation :integer
#  working_days_submission_to_started        :integer
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  application_form_id                       :bigint           not null
#
# Indexes
#
#  index_assessments_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
require "rails_helper"

RSpec.describe Assessment, type: :model do
  subject(:assessment) { create(:assessment, application_form:) }

  let(:application_form) { create(:application_form) }

  describe "associations" do
    it { is_expected.to have_many(:sections) }
    it { is_expected.to have_one(:professional_standing_request).optional }
    it { is_expected.to have_many(:further_information_requests) }
    it { is_expected.to have_many(:qualification_requests) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:recommendation) }

    it do
      is_expected.to define_enum_for(:recommendation).with_values(
        award: "award",
        decline: "decline",
        request_further_information: "request_further_information",
        review: "review",
        unknown: "unknown",
        verify: "verify",
      ).backed_by_column_of_type(:string)
    end
  end

  it "defaults to an unknown recommendation" do
    expect(assessment.unknown?).to be true
  end

  describe "#can_award?" do
    subject(:can_award?) { assessment.can_award? }

    context "with an application under old regulations" do
      let(:application_form) { create(:application_form, :old_regs) }

      context "with an unknown assessment" do
        before do
          create(:assessment_section, :personal_information, assessment:)
        end
        it { is_expected.to be false }
      end

      context "with a passed assessment" do
        before do
          create(
            :assessment_section,
            :personal_information,
            :passed,
            assessment:,
          )
        end
        it { is_expected.to be true }
      end

      context "with a failed assessment" do
        before do
          create(
            :assessment_section,
            :personal_information,
            :failed,
            assessment:,
          )
        end
        it { is_expected.to be false }

        context "when further information was requested" do
          before { assessment.request_further_information! }

          context "with a passed further information request" do
            before do
              create(:further_information_request, :passed, assessment:)
            end
            it { is_expected.to be true }
          end

          context "with a failed further information request" do
            before do
              create(:further_information_request, :failed, assessment:)
            end
            it { is_expected.to be false }
          end
        end
      end

      context "with a mixture of assessments" do
        before do
          create(
            :assessment_section,
            :personal_information,
            :passed,
            assessment:,
          )
          create(:assessment_section, :qualifications, :failed, assessment:)
        end
        it { is_expected.to be false }
      end
    end

    context "with an application under new regulations" do
      let(:application_form) { create(:application_form) }

      it { is_expected.to be false }

      context "with enough verify passed reference requests" do
        before do
          assessment.update!(recommendation: "verify", induction_required: true)

          work_history =
            create(
              :work_history,
              application_form:,
              start_date: Date.new(2020, 1, 1),
              end_date: Date.new(2021, 12, 31),
              hours_per_week: 30,
            )

          create(:reference_request, :verify_passed, assessment:, work_history:)
        end

        it { is_expected.to be true }
      end

      context "with enough review passed reference requests" do
        before do
          assessment.update!(recommendation: "review", induction_required: true)

          work_history =
            create(
              :work_history,
              application_form:,
              start_date: Date.new(2020, 1, 1),
              end_date: Date.new(2021, 12, 31),
              hours_per_week: 30,
            )

          create(
            :reference_request,
            :verify_failed,
            :review_passed,
            assessment:,
            work_history:,
          )
        end

        it { is_expected.to be true }
      end

      context "with no reference requests" do
        before do
          assessment.update!(recommendation: "verify", induction_required: true)
        end

        it { is_expected.to be true }
      end
    end
  end

  describe "#can_decline?" do
    subject(:can_decline?) { assessment.can_decline? }

    context "with an unfinished section" do
      before { create(:assessment_section, :personal_information, assessment:) }

      it { is_expected.to be false }
    end

    context "with a passed section" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
      end
      it { is_expected.to be false }
    end

    context "with a failed section" do
      before do
        create(:assessment_section, :personal_information, :failed, assessment:)
      end
      it { is_expected.to be false }
    end

    context "with a failed section which declines the assessment" do
      before do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          :declines_assessment,
          assessment:,
        )
      end
      it { is_expected.to be true }
    end

    context "with a mixture of sections" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
        create(:assessment_section, :qualifications, :failed, assessment:)
      end
      it { is_expected.to be false }
    end

    context "with a mixture of sections which declines the assessment" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
        create(
          :assessment_section,
          :qualifications,
          :failed,
          :declines_assessment,
          assessment:,
        )
      end
      it { is_expected.to be true }
    end

    context "when further information was requested" do
      before { assessment.request_further_information! }

      context "with a passed further information request" do
        before do
          create(
            :assessment_section,
            :personal_information,
            :failed,
            assessment:,
          )
          create(:further_information_request, :passed, assessment:)
        end
        it { is_expected.to be false }
      end

      context "with a failed further information request" do
        before do
          create(
            :assessment_section,
            :personal_information,
            :failed,
            assessment:,
          )
          create(:further_information_request, :failed, assessment:)
        end
        it { is_expected.to be true }
      end
    end

    context "when awarded pending verification" do
      before { assessment.verify! }
      it { is_expected.to be false }
    end
  end

  describe "#can_request_further_information?" do
    subject(:can_request_further_information?) do
      assessment.can_request_further_information?
    end

    context "with a passed assessment" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
        create(:assessment_section, :qualifications, :passed, assessment:)
      end

      it { is_expected.to be false }
    end

    context "with a failed assessment" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
        create(:assessment_section, :qualifications, :failed, assessment:)
      end

      it { is_expected.to be true }
    end

    context "with a declined assessment" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
        create(
          :assessment_section,
          :qualifications,
          :failed,
          :declines_assessment,
          assessment:,
        )
      end
      it { is_expected.to be false }
    end

    context "with an existing further information request" do
      before { create(:further_information_request, assessment:) }
      it { is_expected.to be false }
    end
  end

  describe "#can_review?" do
    subject(:can_review?) { assessment.can_review? }

    context "with an application under new regulations" do
      let(:application_form) { create(:application_form) }

      context "with an unknown assessment" do
        before do
          create(:assessment_section, :personal_information, assessment:)
        end
        it { is_expected.to be false }
      end
    end

    context "with an application under old regulations" do
      let(:application_form) { create(:application_form, :old_regs) }
      it { is_expected.to be false }
    end
  end

  describe "#can_verify?" do
    subject(:can_verify?) { assessment.can_verify? }

    context "with an application under new regulations" do
      let(:application_form) { create(:application_form) }

      context "with an unknown assessment" do
        before do
          create(:assessment_section, :personal_information, assessment:)
        end
        it { is_expected.to be false }
      end

      context "with a passed assessment" do
        before do
          create(
            :assessment_section,
            :personal_information,
            :passed,
            assessment:,
          )
        end
        it { is_expected.to be true }
      end

      context "with a failed assessment" do
        before do
          create(
            :assessment_section,
            :personal_information,
            :failed,
            assessment:,
          )
        end
        it { is_expected.to be false }

        context "when further information was requested" do
          before { assessment.request_further_information! }

          context "with a passed further information request" do
            before do
              create(:further_information_request, :passed, assessment:)
            end
            it { is_expected.to be true }
          end

          context "with a failed further information request" do
            before do
              create(:further_information_request, :failed, assessment:)
            end
            it { is_expected.to be false }
          end
        end
      end

      context "with a mixture of assessments" do
        before do
          create(
            :assessment_section,
            :personal_information,
            :passed,
            assessment:,
          )
          create(:assessment_section, :qualifications, :failed, assessment:)
        end
        it { is_expected.to be false }
      end
    end

    context "with an application under old regulations" do
      let(:application_form) { create(:application_form, :old_regs) }
      it { is_expected.to be false }
    end
  end

  describe "#available_recommendations" do
    subject(:available_recommendations) { assessment.available_recommendations }

    context "with an award-able assessment" do
      before { allow(assessment).to receive(:can_award?).and_return(true) }
      it { is_expected.to include("award") }
    end

    context "with an award-able pending verification assessment" do
      before { allow(assessment).to receive(:can_verify?).and_return(true) }
      it { is_expected.to include("verify") }
    end

    context "with a decline-able assessment" do
      before { allow(assessment).to receive(:can_decline?).and_return(true) }
      it { is_expected.to include("decline") }
    end

    context "with can_request_further_information-able assessment" do
      before do
        allow(assessment).to receive(
          :can_request_further_information?,
        ).and_return(true)
      end
      it { is_expected.to include("request_further_information") }
    end
  end

  describe "#selected_failure_reasons_empty?" do
    subject(:selected_failure_reasons_empty?) do
      assessment.selected_failure_reasons_empty?
    end

    context "with no failure reasons" do
      it { is_expected.to be true }
    end

    context "with failure reasons" do
      before do
        create(:assessment_section, :declines_with_already_qts, assessment:)
      end
      it { is_expected.to be false }
    end
  end
end
