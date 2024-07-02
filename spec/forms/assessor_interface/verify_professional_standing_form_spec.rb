# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::VerifyProfessionalStandingForm,
               type: :model do
  subject(:form) { described_class.new(verify_professional_standing:) }

  let(:verify_professional_standing) { nil }

  describe "validations" do
    it do
      expect(subject).to allow_values(true, false).for(
        :verify_professional_standing,
      )
    end
  end
end
