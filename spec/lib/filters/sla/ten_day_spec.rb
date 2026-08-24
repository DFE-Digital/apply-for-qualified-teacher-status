# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::SLA::TenDay do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let(:scope) { ApplicationForm.all }
  let(:params) { {} }

  # Assessment not started, not withdrawn, at the working-day threshold,
  # with prioritisation work history checks
  let!(:included) do
    create(
      :application_form,
      working_days_between_submitted_and_today: 8,
    ).tap do |application_form|
      assessment = create(:assessment, application_form:)

      create_list(:prioritisation_work_history_check, 2, assessment:)
    end
  end

  before do
    # Assessment already started
    create(
      :application_form,
      working_days_between_submitted_and_today: 8,
    ).tap do |application_form|
      assessment = create(:assessment, :started, application_form:)

      create(:prioritisation_work_history_check, assessment:)
    end

    # Withdrawn
    create(
      :application_form,
      :withdrawn,
      working_days_between_submitted_and_today: 8,
    ).tap do |application_form|
      assessment = create(:assessment, application_form:)

      create(:prioritisation_work_history_check, assessment:)
    end

    # Below the working-day threshold
    create(
      :application_form,
      working_days_between_submitted_and_today: 7,
    ).tap do |application_form|
      assessment = create(:assessment, application_form:)

      create(:prioritisation_work_history_check, assessment:)
    end

    # No prioritisation work history checks
    create(
      :application_form,
      working_days_between_submitted_and_today: 8,
    ).tap { |application_form| create(:assessment, application_form:) }
  end

  it { is_expected.to contain_exactly(included) }
end
