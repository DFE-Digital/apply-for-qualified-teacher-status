# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::VerifyProfessionalStandingForm,
               type: :model do
  let(:verify_professional_standing) { nil }

  subject(:form) { described_class.new(verify_professional_standing:) }

  describe "validations" do
    it do
      is_expected.to allow_values(true, false).for(
        :verify_professional_standing,
      )
    end
  end
end
