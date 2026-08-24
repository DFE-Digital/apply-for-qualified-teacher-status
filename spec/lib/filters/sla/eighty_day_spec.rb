# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::SLA::EightyDay do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let(:scope) { ApplicationForm.all }
  let(:params) { {} }

  let!(:included) do
    create(
      :application_form,
      :submitted,
      working_days_between_submitted_and_today: 65,
    )
  end

  before do
    # Draft
    create(:application_form, :draft)

    # Completed
    create(
      :application_form,
      :awarded,
      :completed_stage,
      working_days_between_submitted_and_today: 65,
    )

    # Below the working day threshold
    create(
      :application_form,
      :submitted,
      working_days_between_submitted_and_today: 64,
    )
  end

  it { is_expected.to contain_exactly(included) }
end
