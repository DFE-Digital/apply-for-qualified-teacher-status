# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ConsentMethodForm, type: :model do
  let(:qualification_request) { create(:qualification_request) }
  let(:consent_method) { "unsigned" }

  subject(:form) do
    described_class.new(qualification_request:, consent_method:)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:qualification_request) }
    it { is_expected.to validate_presence_of(:consent_method) }
    it do
      is_expected.to validate_inclusion_of(:consent_method).in_array(
        %w[signed_ecctis signed_institution unsigned none],
      )
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    it "sets the consent method" do
      expect { save }.to change(qualification_request, :consent_method).to(
        "unsigned",
      )
    end
  end
end
