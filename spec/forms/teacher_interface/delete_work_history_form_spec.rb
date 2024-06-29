# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::DeleteWorkHistoryForm, type: :model do
  subject(:form) { described_class.new(confirm:, work_history:) }

  describe "validations" do
    let(:confirm) { "" }
    let(:work_history) { nil }

    it { is_expected.to allow_values(true, false).for(:confirm) }

    context "when confirm is true" do
      let(:confirm) { "true" }

      it { is_expected.to validate_presence_of(:work_history) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let!(:work_history) { create(:work_history) }

    context "when confirm is true" do
      let(:confirm) { "true" }

      it "deletes the work history" do
        expect { save }.to change(WorkHistory, :count).by(-1)
      end
    end

    context "when confirm is false" do
      let(:confirm) { "false" }

      it "doesn't delete the work history" do
        expect { save }.not_to change(WorkHistory, :count)
      end
    end
  end
end
