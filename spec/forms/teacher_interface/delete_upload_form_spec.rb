# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::DeleteUploadForm, type: :model do
  subject(:form) { described_class.new(confirm:, upload:) }

  describe "validations" do
    let(:confirm) { nil }
    let(:upload) { nil }

    it { is_expected.to validate_presence_of(:upload) }
    it { is_expected.to allow_values(true, false).for(:confirm) }
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    # rubocop:disable RSpec/LetSetup
    let(:document) { create(:document) }
    let!(:upload) { create(:upload, :clean, document:) }
    # rubocop:enable RSpec/LetSetup

    context "when confirm is true" do
      let(:confirm) { "true" }

      it "deletes the upload" do
        expect { save }.to change(Upload, :count).by(-1)
      end

      it "marks the document as incomplete" do
        expect { save }.to change { document.reload.completed? }.from(true).to(
          false,
        )
      end

      context "with another upload" do
        before { create(:upload, :clean, document:) }

        it "doesn't mark the document as incomplete" do
          expect { save }.not_to change(document, :completed?).from(true)
        end
      end
    end

    context "when confirm is false" do
      let(:confirm) { "false" }

      it "doesn't delete the upload" do
        expect { save }.not_to change(Upload, :count)
      end
    end
  end
end
