# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormEmailForm, type: :model do
  subject(:form) { described_class.new(application_form:, user:, email:) }

  let(:application_form) { create(:application_form) }
  let(:user) { create(:staff) }
  let(:email) { "new@example.com" }

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe "#save" do
    subject(:save) { form.save }

    it "calls the UpdateApplicationFormName service" do
      expect(UpdateTeacherEmail).to receive(:call).with(
        application_form:,
        user:,
        email:,
      )
      expect(save).to be true
    end
  end
end
