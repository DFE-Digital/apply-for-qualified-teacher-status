# == Schema Information
#
# Table name: uploads
#
#  id                  :bigint           not null, primary key
#  filename            :string           default(""), not null
#  malware_scan_result :string           default("pending"), not null
#  translation         :boolean          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  document_id         :bigint           not null
#
# Indexes
#
#  index_uploads_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
require "rails_helper"

RSpec.describe Upload, type: :model do
  subject(:upload) { build(:upload) }

  describe "validations" do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:attachment) }
  end

  describe "#original?" do
    subject(:original?) { upload.original? }

    it { is_expected.to be(true) }

    context "with a translation" do
      before { upload.translation = true }

      it { is_expected.to be(false) }
    end
  end

  describe "#name" do
    subject(:name) { upload.name }

    it { is_expected.to eq("upload.pdf") }

    context "when a malware scan is suspect" do
      before { upload.malware_scan_result = "suspect" }
      it { is_expected.to eq("File upload error") }
    end
  end

  describe "#url" do
    subject(:url) { upload.url }

    it do
      is_expected.to include("http://localhost:3000/rails/active_storage/disk/")
    end
    it { is_expected.to include("upload.pdf") }
  end
end
