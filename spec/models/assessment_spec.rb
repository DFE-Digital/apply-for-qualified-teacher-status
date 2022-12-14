# frozen_string_literal: true

# == Schema Information
#
# Table name: assessments
#
#  id                                        :bigint           not null, primary key
#  age_range_max                             :integer
#  age_range_min                             :integer
#  age_range_note                            :text             default(""), not null
#  recommendation                            :string           default("unknown"), not null
#  recommended_at                            :date
#  started_at                                :datetime
#  subjects                                  :text             default([]), not null, is an Array
#  subjects_note                             :text             default(""), not null
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
  subject(:assessment) { create(:assessment) }

  describe "associations" do
    it { is_expected.to have_many(:sections) }
    it { is_expected.to have_many(:further_information_requests) }
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
      let!(:assessment_section) do
        create(:assessment_section, :passed, assessment:)
      end

      it { is_expected.to be true }
    end

    context "with a failed assessment" do
      let!(:assessment_section) do
        create(:assessment_section, :failed, assessment:)
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

      context "with a passed further information request" do
        before { create(:further_information_request, :passed, assessment:) }
        it { is_expected.to be true }
      end

      context "with a failed further information request" do
        before { create(:further_information_request, :failed, assessment:) }
        it { is_expected.to be false }
      end
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

    context "with a passed further information request" do
      before do
        create(:assessment_section, :personal_information, :failed, assessment:)
        create(:further_information_request, :passed, assessment:)
      end
      it { is_expected.to be false }
    end

    context "with a failed further information request" do
      before do
        create(:assessment_section, :personal_information, :failed, assessment:)
        create(:further_information_request, :failed, assessment:)
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
