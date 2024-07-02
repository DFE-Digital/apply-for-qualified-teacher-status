# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  available         :boolean
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
      expect(subject).to define_enum_for(:document_type).with_values(
        english_language_proficiency: "english_language_proficiency",
        identification: "identification",
        medium_of_instruction: "medium_of_instruction",
        name_change: "name_change",
        qualification_certificate: "qualification_certificate",
        qualification_document: "qualification_document",
        qualification_transcript: "qualification_transcript",
        signed_consent: "signed_consent",
        unsigned_consent: "unsigned_consent",
        written_statement: "written_statement",
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

  describe "#allow_multiple_uploads?" do
    subject(:allow_multiple_uploads?) { document.allow_multiple_uploads? }

    it { is_expected.to be(true) }

    context "with a single page document" do
      before { document.document_type = :signed_consent }

      it { is_expected.to be(false) }
    end
  end
end
