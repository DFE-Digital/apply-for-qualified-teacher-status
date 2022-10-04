require "rails_helper"

RSpec.describe TeacherInterface::DeleteUploadForm, type: :model do
  subject(:form) { described_class.new(confirm:, upload:) }

  describe "validations" do
    let(:confirm) { "" }
    let(:upload) { nil }

    it { is_expected.to allow_values(true, false).for(:confirm) }

    context "when confirm is true" do
      let(:confirm) { "true" }
      it { is_expected.to validate_presence_of(:upload) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let!(:upload) { create(:upload) }

    context "when confirm is true" do
      let(:confirm) { "true" }

      it "deletes the upload" do
        expect { save }.to change { Upload.count }.by(-1)
      end
    end

    context "when confirm is false" do
      let(:confirm) { "false" }

      it "doesn't delete the upload" do
        expect { save }.to change { Upload.count }.by(0)
      end
    end
  end
end
