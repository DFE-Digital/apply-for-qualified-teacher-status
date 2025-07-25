# frozen_string_literal: true

# == Schema Information
#
# Table name: assessments
#
#  id                                                         :bigint           not null, primary key
#  age_range_max                                              :integer
#  age_range_min                                              :integer
#  age_range_note                                             :text             default(""), not null
#  induction_required                                         :boolean
#  prioritisation_decision_at                                 :datetime
#  prioritised                                                :boolean
#  qualifications_assessor_note                               :text             default(""), not null
#  recommendation                                             :string           default("unknown"), not null
#  recommendation_assessor_note                               :text             default(""), not null
#  recommended_at                                             :datetime
#  references_verified                                        :boolean
#  scotland_full_registration                                 :boolean
#  started_at                                                 :datetime
#  subjects                                                   :text             default([]), not null, is an Array
#  subjects_note                                              :text             default(""), not null
#  unsigned_consent_document_generated                        :boolean          default(FALSE), not null
#  verification_started_at                                    :datetime
#  working_days_between_started_and_completed                 :integer
#  working_days_between_started_and_today                     :integer
#  working_days_between_started_and_verification_started      :integer
#  working_days_between_submitted_and_prioritisation_decision :integer
#  working_days_between_submitted_and_started                 :integer
#  working_days_between_submitted_and_verification_started    :integer
#  created_at                                                 :datetime         not null
#  updated_at                                                 :datetime         not null
#  application_form_id                                        :bigint           not null
#
# Indexes
#
#  index_assessments_on_application_form_id  (application_form_id)
#  index_assessments_on_prioritised          (prioritised)
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
      expect(subject).to define_enum_for(:recommendation).with_values(
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
      let(:application_form) { create(:application_form, :old_regulations) }

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
              create(:further_information_request, :review_passed, assessment:)
            end

            it { is_expected.to be true }
          end

          context "with a failed further information request" do
            before do
              create(:further_information_request, :review_failed, assessment:)
            end

            it { is_expected.to be false }
          end

          context "with multiple further information requests" do
            context "with a passed latest further information request" do
              before do
                create(
                  :further_information_request,
                  :review_failed,
                  assessment:,
                  requested_at: 2.days.ago,
                )
                create(
                  :further_information_request,
                  :review_passed,
                  assessment:,
                  requested_at: 1.day.ago,
                )
              end

              it { is_expected.to be true }
            end

            context "with a failed latest further information request" do
              before do
                create(
                  :further_information_request,
                  :review_failed,
                  assessment:,
                  requested_at: 2.days.ago,
                )
                create(
                  :further_information_request,
                  :review_failed,
                  assessment:,
                  requested_at: 1.day.ago,
                )
              end

              it { is_expected.to be false }
            end
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

          create(
            :received_reference_request,
            :verify_passed,
            assessment:,
            work_history:,
          )
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
            :received_reference_request,
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
          create(:further_information_request, :review_passed, assessment:)
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
          create(:further_information_request, :review_failed, assessment:)
        end

        it { is_expected.to be true }
      end

      context "with multiple further information requests" do
        context "with a passed latest further information request" do
          before do
            create(
              :further_information_request,
              :review_failed,
              assessment:,
              requested_at: 2.days.ago,
            )
            create(
              :further_information_request,
              :review_passed,
              assessment:,
              requested_at: 1.day.ago,
            )
          end

          it { is_expected.to be false }
        end

        context "with a failed latest further information request" do
          before do
            create(
              :further_information_request,
              :review_failed,
              assessment:,
              requested_at: 2.days.ago,
            )
            create(
              :further_information_request,
              :review_failed,
              assessment:,
              requested_at: 1.day.ago,
            )
          end

          it { is_expected.to be true }
        end
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
      let(:application_form) { create(:application_form, :old_regulations) }

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
              create(:further_information_request, :review_passed, assessment:)
            end

            it { is_expected.to be true }
          end

          context "with a failed further information request" do
            before do
              create(:further_information_request, :review_failed, assessment:)
            end

            it { is_expected.to be false }
          end

          context "with multiple further information requests" do
            context "with a passed latest further information request" do
              before do
                create(
                  :further_information_request,
                  :review_failed,
                  assessment:,
                  requested_at: 2.days.ago,
                )
                create(
                  :further_information_request,
                  :review_passed,
                  assessment:,
                  requested_at: 1.day.ago,
                )
              end

              it { is_expected.to be true }
            end

            context "with a failed latest further information request" do
              before do
                create(
                  :further_information_request,
                  :review_failed,
                  assessment:,
                  requested_at: 2.days.ago,
                )
                create(
                  :further_information_request,
                  :review_failed,
                  assessment:,
                  requested_at: 1.day.ago,
                )
              end

              it { is_expected.to be false }
            end
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
      let(:application_form) { create(:application_form, :old_regulations) }

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

  describe "#latest_further_information_request" do
    context "when assessment has no further information requests" do
      it "returns nil" do
        expect(assessment.latest_further_information_request).to be_nil
      end
    end

    context "when assessment has one further information requests" do
      let!(:further_information_request) do
        create :further_information_request, assessment:
      end

      it "returns the further information request" do
        expect(assessment.reload.latest_further_information_request).to eq(
          further_information_request,
        )
      end
    end

    context "when assessment has multiple further information requests" do
      let!(:latest_further_information_request) do
        create :further_information_request,
               assessment:,
               requested_at: 1.day.ago
      end

      before do
        create :further_information_request,
               assessment:,
               requested_at: 2.days.ago
      end

      it "returns the latest further information request" do
        expect(assessment.reload.latest_further_information_request).to eq(
          latest_further_information_request,
        )
      end
    end
  end

  describe "#prioritisation_checks_incomplete?" do
    subject(:prioritisation_checks_incomplete?) do
      assessment.prioritisation_checks_incomplete?
    end

    context "when assessment has no prioritisation work history checks" do
      it { is_expected.to be false }
    end

    context "when assessment has prioritisation work history checks" do
      before { create :prioritisation_work_history_check, assessment: }

      it { is_expected.to be true }

      context "with the prioritisation decision timestamp present" do
        before { assessment.update!(prioritisation_decision_at: Time.current) }

        it { is_expected.to be false }
      end
    end
  end

  describe "#can_update_prioritisation_decision?" do
    subject(:can_update_prioritisation_decision?) do
      assessment.can_update_prioritisation_decision?
    end

    context "when assessment does not have any prioritisation checks" do
      it { is_expected.to be false }
    end

    context "when assessment has prioritisation checks" do
      let(:prioritisation_work_history_check_one) do
        create(:prioritisation_work_history_check, assessment:)
      end

      let(:prioritisation_work_history_check_two) do
        create(:prioritisation_work_history_check, assessment:)
      end

      context "with work history checks all passing" do
        before do
          prioritisation_work_history_check_one.update!(passed: true)
          prioritisation_work_history_check_two.update!(passed: true)
        end

        it { is_expected.to be false }

        context "with reference requests waiting" do
          before do
            create(:prioritisation_reference_request, assessment:)
            create(:prioritisation_reference_request, assessment:)
          end

          it { is_expected.to be false }
        end

        context "with reference requests received" do
          let!(:prioritisation_reference_request_one) do
            create :prioritisation_reference_request, assessment:
          end

          let!(:prioritisation_reference_request_two) do
            create :prioritisation_reference_request, assessment:
          end

          it { is_expected.to be false }

          context "with one passing review" do
            before do
              prioritisation_reference_request_one.update!(review_passed: true)
            end

            it { is_expected.to be true }
          end

          context "with all passing review" do
            before do
              prioritisation_reference_request_one.update!(review_passed: true)
              prioritisation_reference_request_two.update!(review_passed: true)
            end

            it { is_expected.to be true }
          end

          context "with one passing review and one failing review" do
            before do
              prioritisation_reference_request_one.update!(review_passed: true)
              prioritisation_reference_request_two.update!(review_passed: false)
            end

            it { is_expected.to be true }
          end

          context "with one failing review" do
            before do
              prioritisation_reference_request_one.update!(review_passed: false)
            end

            it { is_expected.to be false }
          end

          context "with all failing review" do
            before do
              prioritisation_reference_request_one.update!(review_passed: false)
              prioritisation_reference_request_two.update!(review_passed: false)
            end

            it { is_expected.to be true }
          end
        end
      end

      context "with work history checks some failing and some passing" do
        before do
          prioritisation_work_history_check_one.update!(passed: true)
          prioritisation_work_history_check_two.update!(passed: false)
        end

        it { is_expected.to be false }
      end

      context "with work history checks all failing" do
        before do
          prioritisation_work_history_check_one.update!(passed: false)
          prioritisation_work_history_check_two.update!(passed: false)
        end

        it { is_expected.to be true }
      end
    end
  end

  describe "#can_prioritise?" do
    subject(:can_prioritise?) { assessment.can_prioritise? }

    context "when assessment has no prioritisation reference requests" do
      it { is_expected.to be false }
    end

    context "when assessment has prioritisation reference requests" do
      let!(:prioritisation_reference_request_one) do
        create :prioritisation_reference_request, assessment:
      end

      let!(:prioritisation_reference_request_two) do
        create :prioritisation_reference_request, assessment:
      end

      it { is_expected.to be false }

      context "with prioritisation reference requests some received" do
        let!(:prioritisation_reference_request_one) do
          create :received_prioritisation_reference_request, assessment:
        end

        context "with it passing review" do
          before do
            prioritisation_reference_request_one.update(review_passed: true)
          end

          it { is_expected.to be true }
        end

        context "with it failing review" do
          before do
            prioritisation_reference_request_one.update(review_passed: false)
          end

          it { is_expected.to be false }
        end
      end

      context "with prioritisation reference requests all received" do
        let!(:prioritisation_reference_request_one) do
          create :received_prioritisation_reference_request, assessment:
        end

        let!(:prioritisation_reference_request_two) do
          create :received_prioritisation_reference_request, assessment:
        end

        it { is_expected.to be false }

        context "with one passing review" do
          before do
            prioritisation_reference_request_one.update(review_passed: true)
          end

          it { is_expected.to be true }
        end

        context "with both passing review" do
          before do
            prioritisation_reference_request_one.update!(review_passed: true)
            prioritisation_reference_request_two.update!(review_passed: true)
          end

          it { is_expected.to be true }
        end

        context "with one passing review and one failing review" do
          before do
            prioritisation_reference_request_one.update!(review_passed: true)
            prioritisation_reference_request_two.update!(review_passed: false)
          end

          it { is_expected.to be true }
        end

        context "with both failing review" do
          before do
            prioritisation_reference_request_one.update!(review_passed: false)
            prioritisation_reference_request_two.update!(review_passed: false)
          end

          it { is_expected.to be false }
        end
      end
    end
  end
end
