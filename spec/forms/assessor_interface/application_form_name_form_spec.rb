# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormNameForm, type: :model do
  let(:application_form) { create(:application_form) }
  let(:user) { create(:staff) }

  let(:given_names) { "A new given name" }
  let(:family_name) { "A new family name" }

  subject(:form) do
    described_class.new(application_form:, user:, given_names:, family_name:)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:user) }
  end

  describe "#save" do
    subject(:save) { form.save }

    it "calls the UpdateApplicationFormName service" do
      expect(UpdateApplicationFormName).to receive(:call).with(
        application_form:,
        user:,
        given_names:,
        family_name:,
      )
      expect(save).to be true
    end
  end
end
