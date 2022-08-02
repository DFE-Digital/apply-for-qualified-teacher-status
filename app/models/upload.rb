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
class Upload < ApplicationRecord
  belongs_to :document
  has_one_attached :attachment
  validates :attachment,
            attached: true,
            content_type: %i[png jpg jpeg pdf doc docx],
            size: {
              less_than: 50.megabytes
            }

  def original?
    !translation?
  end
end
