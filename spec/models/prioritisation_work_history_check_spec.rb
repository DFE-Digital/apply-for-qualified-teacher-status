# frozen_string_literal: true

# == Schema Information
#
# Table name: prioritisation_work_history_checks
#
#  id              :bigint           not null, primary key
#  checks          :string           default([]), is an Array
#  failure_reasons :string           default([]), is an Array
#  passed          :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  assessment_id   :bigint           not null
#  work_history_id :bigint           not null
#
# Indexes
#
#  index_prioritisation_work_history_checks_on_assessment_id    (assessment_id)
#  index_prioritisation_work_history_checks_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
require "rails_helper"

RSpec.describe PrioritisationWorkHistoryCheck, type: :model do
  subject(:prioritisation_work_history_check) do
    create(:prioritisation_work_history_check)
  end

  describe "#complete?" do
    subject(:complete?) { prioritisation_work_history_check.complete? }

    before { prioritisation_work_history_check.update!(passed:) }

    context "when passed is nil" do
      let(:passed) { nil }

      it { is_expected.to be false }
    end

    context "when passed is true" do
      let(:passed) { true }

      it { is_expected.to be true }
    end

    context "when passed is false" do
      let(:passed) { false }

      it { is_expected.to be true }
    end
  end

  describe "#incomplete?" do
    subject(:complete?) { prioritisation_work_history_check.incomplete? }

    before { prioritisation_work_history_check.update!(passed:) }

    context "when passed is nil" do
      let(:passed) { nil }

      it { is_expected.to be true }
    end

    context "when passed is true" do
      let(:passed) { true }

      it { is_expected.to be false }
    end

    context "when passed is false" do
      let(:passed) { false }

      it { is_expected.to be false }
    end
  end
end
