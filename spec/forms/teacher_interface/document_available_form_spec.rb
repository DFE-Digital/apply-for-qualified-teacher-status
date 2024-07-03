# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::DocumentAvailableForm, type: :model do
  subject(:form) { described_class.new(document:, available:) }

  let(:application_form) do
    create(:application_form, written_statement_optional: true)
  end
  let(:document) do
    create(:document, :written_statement, documentable: application_form)
  end

  describe "validations" do
    let(:available) { "" }

    it { is_expected.to validate_presence_of(:document) }
    it { is_expected.to allow_values(true, false).for(:available) }
  end

  describe "#save" do
    before { form.save(validate: true) }

    context "when available" do
      let(:available) { "true" }

      it "saves the document" do
        expect(document.available).to be(true)
        expect(document.completed?).to be(false)
      end
    end

    context "when unavailable" do
      let(:available) { "false" }

      it "saves the document" do
        expect(document.available).to be(false)
        expect(document.completed?).to be(true)
      end
    end
  end
end
