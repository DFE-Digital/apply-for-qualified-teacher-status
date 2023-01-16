# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::WrittenStatementConfirmationForm,
               type: :model do
  let(:application_form) { build(:application_form) }

  subject(:form) do
    described_class.new(application_form:, written_statement_confirmation:)
  end

  describe "validations" do
    let(:written_statement_confirmation) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:written_statement_confirmation) }
  end

  describe "#save" do
    let(:written_statement_confirmation) { "true" }

    before { form.save(validate: true) }

    it "updates the application form" do
      expect(application_form).to be_written_statement_confirmation
    end
  end
end
