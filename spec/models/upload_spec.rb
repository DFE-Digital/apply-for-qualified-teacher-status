# == Schema Information
#
# Table name: uploads
#
#  id          :bigint           not null, primary key
#  translation :boolean          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :bigint           not null
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
  end

  describe "#original?" do
    subject(:original?) { upload.original? }

    it { is_expected.to be(true) }

    context "with a translation" do
      before { upload.translation = true }

      it { is_expected.to be(false) }
    end
  end
end
