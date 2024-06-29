# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::DeleteQualificationForm, type: :model do
  subject(:form) { described_class.new(confirm:, qualification:) }

  describe "validations" do
    let(:confirm) { "" }
    let(:qualification) { nil }

    it { is_expected.to allow_values(true, false).for(:confirm) }

    context "when confirm is true" do
      let(:confirm) { "true" }

      it { is_expected.to validate_presence_of(:qualification) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let!(:qualification) { create(:qualification) }

    context "when confirm is true" do
      let(:confirm) { "true" }

      it "deletes the qualification" do
        expect { save }.to change(Qualification, :count).by(-1)
      end
    end

    context "when confirm is false" do
      let(:confirm) { "false" }

      it "doesn't delete the qualification" do
        expect { save }.not_to change(Qualification, :count)
      end
    end
  end
end
