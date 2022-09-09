# frozen_string_literal: true

# == Schema Information
#
# Table name: assessments
#
#  id                  :bigint           not null, primary key
#  recommendation      :string           default("unknown"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
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
  subject(:assessment) { build(:assessment) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:recommendation) }

    it do
      is_expected.to define_enum_for(:recommendation).with_values(
        unknown: "unknown",
        award: "award",
        decline: "decline"
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
  end
end
