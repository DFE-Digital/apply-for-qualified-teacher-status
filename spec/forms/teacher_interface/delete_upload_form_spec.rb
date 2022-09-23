require "rails_helper"

RSpec.describe TeacherInterface::DeleteUploadForm, type: :model do
  describe "validations" do
    subject(:form) { described_class.new(confirm:, upload:) }

    context "when the fields are blank" do
      let(:confirm) { "" }
      let(:upload) { "" }

      it { is_expected.to_not be_valid }
    end

    context "when confirm field is true but upload is blank" do
      let(:confirm) { true }
      let!(:upload) { "" }

      it { is_expected.to_not be_valid }
    end

    context "when the fields are true" do
      let(:confirm) { true }
      let!(:upload) { true }

      it { is_expected.to be_valid }
    end

    context "when the fields are false" do
      let(:confirm) { false }
      let!(:upload) { "" }

      it { is_expected.to be_valid }
    end

    context "file is successfully deleted when confirm is true" do
      let!(:upload) { create(:upload) }
      let(:confirm) { true }

      it "deletes the upload" do
        expect { form.save! }.to change { Upload.count }.by(-1)
      end
    end

    context "file is not successfully deleted" do
      let!(:upload) { create(:upload) }
      let(:confirm) { false }

      it "doesn't delete the upload" do
        expect { form.save! }.to change { Upload.count }.by(0)
      end
    end
  end
end
