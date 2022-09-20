# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  document_type     :string           not null
#  documentable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  documentable_id   :bigint
#
# Indexes
#
#  index_documents_on_document_type  (document_type)
#  index_documents_on_documentable   (documentable_type,documentable_id)
#
require "rails_helper"

RSpec.describe Document, type: :model do
  subject(:document) { build(:document) }

  describe "validations" do
    it { is_expected.to be_valid }

    it do
      is_expected.to define_enum_for(:document_type).with_values(
        identification: "identification",
        name_change: "name_change",
        qualification_certificate: "qualification_certificate",
        qualification_transcript: "qualification_transcript",
        written_statement: "written_statement",
        further_information_request: "further_information_request"
      ).backed_by_column_of_type(:string)
    end
  end

  describe "#original_uploads" do
    subject(:original_uploads) { document.original_uploads }

    it { is_expected.to be_empty }

    context "with an original document" do
      let!(:upload) { create(:upload, document:) }

      it { is_expected.to eq([upload]) }
    end

    context "with a translated document" do
      before { create(:upload, :translation, document:) }

      it { is_expected.to be_empty }
    end
  end

  describe "#translated_uploads" do
    subject(:translated_uploads) { document.translated_uploads }

    it { is_expected.to be_empty }

    context "with an original document" do
      before { create(:upload, document:) }

      it { is_expected.to be_empty }
    end

    context "with a translated document" do
      let!(:upload) { create(:upload, :translation, document:) }

      it { is_expected.to eq([upload]) }
    end
  end

  describe "#translatable?" do
    subject(:translatable?) { document.translatable? }

    it { is_expected.to be(false) }

    context "with a translatable document" do
      before { document.document_type = :written_statement }

      it { is_expected.to be(true) }
    end
  end

  describe "#uploaded?" do
    subject(:uploaded?) { document.uploaded? }

    it { is_expected.to be(false) }

    context "with an upload" do
      before { create(:upload, document:) }

      it { is_expected.to be(true) }
    end
  end

  describe "#continue_url" do
    subject(:continue_url) { document.continue_url }

    context "with an identity document" do
      before { document.document_type = :identification }

      it { is_expected.to eq(%i[teacher_interface application_form]) }
    end

    context "with a name change document" do
      before { document.document_type = :name_change }

      it do
        is_expected.to eq(
          %i[check teacher_interface application_form personal_information]
        )
      end
    end

    context "with a qualification" do
      let(:qualification) { build(:qualification) }

      before { document.documentable = qualification }

      context "and a certificate document" do
        before { document.document_type = :qualification_certificate }

        it do
          is_expected.to eq(
            [
              :edit,
              :teacher_interface,
              :application_form,
              qualification.transcript_document
            ]
          )
        end
      end

      context "with a transcript document" do
        before { document.document_type = :qualification_transcript }

        it do
          is_expected.to eq(
            [
              :part_of_university_degree,
              :teacher_interface,
              :application_form,
              qualification
            ]
          )
        end
      end
    end
  end
end
