# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessmentConfirmationForm, type: :model do
  it { is_expected.to allow_values(true, false).for(:confirmation) }
end
