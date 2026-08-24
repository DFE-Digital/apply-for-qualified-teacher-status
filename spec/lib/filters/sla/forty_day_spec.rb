# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::SLA::FortyDay do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let(:scope) { ApplicationForm.all }
  let(:params) { {} }

  let!(:pre_assessment) do
    create(
      :application_form,
      :submitted,
      :pre_assessment_stage,
      working_days_between_submitted_and_today: 35,
    )
  end

  let!(:not_started) do
    create(
      :application_form,
      :submitted,
      :not_started_stage,
      working_days_between_submitted_and_today: 35,
    )
  end

  let!(:assessment) do
    create(
      :application_form,
      :submitted,
      :assessment_stage,
      working_days_between_submitted_and_today: 35,
    )
  end

  before do
    # Verification stage
    create(
      :application_form,
      :submitted,
      :verification_stage,
      working_days_between_submitted_and_today: 35,
    )

    # Review stage
    create(
      :application_form,
      :submitted,
      :review_stage,
      working_days_between_submitted_and_today: 35,
    )

    # Completed stage
    create(
      :application_form,
      :awarded,
      working_days_between_submitted_and_today: 35,
    )

    # Below the working-day threshold
    create(
      :application_form,
      :submitted,
      :not_started_stage,
      working_days_between_submitted_and_today: 34,
    )
  end

  it { is_expected.to contain_exactly(pre_assessment, not_started, assessment) }
end
