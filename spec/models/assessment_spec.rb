# frozen_string_literal: true

# == Schema Information
#
# Table name: assessments
#
#  id                  :bigint           not null, primary key
#  age_range_max       :integer
#  age_range_min       :integer
#  recommendation      :string           default("unknown"), not null
#  subjects            :text             default([]), not null, is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  age_range_note_id   :bigint
#  application_form_id :bigint           not null
#  subjects_note_id    :bigint
#
# Indexes
#
#  index_assessments_on_age_range_note_id    (age_range_note_id)
#  index_assessments_on_application_form_id  (application_form_id)
#  index_assessments_on_subjects_note_id     (subjects_note_id)
#
# Foreign Keys
#
#  fk_rails_...  (age_range_note_id => notes.id)
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (subjects_note_id => notes.id)
#
require "rails_helper"

RSpec.describe Assessment, type: :model do
  subject(:assessment) { create(:assessment) }

  describe "associations" do
    it { is_expected.to have_many(:sections) }
    it { is_expected.to have_many(:further_information_requests) }
    it { is_expected.to belong_to(:age_range_note).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:recommendation) }

    it do
      is_expected.to define_enum_for(:recommendation).with_values(
        unknown: "unknown",
        award: "award",
        decline: "decline",
        request_further_information: "request_further_information",
      ).backed_by_column_of_type(:string)
    end
  end

  it "defaults to an unknown recommendation" do
    expect(assessment.unknown?).to be true
  end

  describe "#finished?" do
    subject(:finished?) { assessment.finished? }

    context "with an unknown recommendation" do
      before { assessment.unknown! }
      it { is_expected.to be false }
    end

    context "with an awarded recommendation" do
      before { assessment.award! }
      it { is_expected.to be true }
    end

    context "with an unknown recommendation" do
      before { assessment.decline! }
      it { is_expected.to be true }
    end

    context "with unfinished section assessments" do
      before { assessment.sections.create!(key: :personal_information) }
      it { is_expected.to be false }
    end
  end

  describe "#sections_finished?" do
    subject(:sections_finished?) { assessment.sections_finished? }

    let!(:assessment_section) do
      assessment.sections.create!(key: :personal_information)
    end

    context "with an unknown assessment" do
      it { is_expected.to be false }
    end

    context "with a passed assessment" do
      before { assessment_section.update!(passed: true) }
      it { is_expected.to be true }
    end

    context "with a failed assessment" do
      before do
        assessment_section.update!(
          passed: false,
          selected_failure_reasons: %w[failure_reason],
        )
      end
      it { is_expected.to be true }
    end
  end

  describe "#can_award?" do
    subject(:can_award?) { assessment.can_award? }

    context "with an unknown assessment" do
      before { create(:assessment_section, :personal_information, assessment:) }
      it { is_expected.to be false }
    end

    context "with a passed assessment" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
      end
      it { is_expected.to be true }
    end

    context "with a failed assessment" do
      before do
        create(:assessment_section, :personal_information, :failed, assessment:)
      end
      it { is_expected.to be false }
    end

    context "with a mixture of assessments" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
        create(:assessment_section, :qualifications, :failed, assessment:)
      end
      it { is_expected.to be false }
    end
  end

  describe "#can_decline?" do
    subject(:can_decline?) { assessment.can_decline? }

    context "with an unfinished assessment" do
      before { create(:assessment_section, :personal_information, assessment:) }

      it { is_expected.to be false }
    end

    context "with a passed assessment" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
      end
      it { is_expected.to be false }
    end

    context "with a failed assessment" do
      before do
        create(:assessment_section, :personal_information, :failed, assessment:)
      end
      it { is_expected.to be true }
    end

    context "with a mixture of assessments" do
      before do
        create(:assessment_section, :personal_information, :passed, assessment:)
        create(:assessment_section, :qualifications, :failed, assessment:)
      end
      it { is_expected.to be true }
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
          assessment:,
          selected_failure_reasons: {
            duplicate_application: "Notes.",
          },
        )
      end

      it { is_expected.to be false }
    end
  end

  describe "#available_recommendations" do
    subject(:available_recommendations) { assessment.available_recommendations }

    context "with an award-able assessment" do
      before { allow(assessment).to receive(:can_award?).and_return(true) }
      it { is_expected.to include("award") }
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
end
