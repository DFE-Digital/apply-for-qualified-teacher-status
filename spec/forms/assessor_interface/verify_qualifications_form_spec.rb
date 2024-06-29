# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::VerifyQualificationsForm, type: :model do
  subject(:form) { described_class.new(verify_qualifications:) }

  let(:verify_qualifications) { nil }

  describe "validations" do
    it { is_expected.to allow_values(true, false).for(:verify_qualifications) }
  end
end
