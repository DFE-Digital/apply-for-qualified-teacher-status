# == Schema Information
#
# Table name: uploads
#
#  id                  :bigint           not null, primary key
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
class Upload < ApplicationRecord
  belongs_to :document

  has_one_attached :attachment, dependent: :purge_later
  validates :attachment, presence: true

  enum malware_scan_result: {
         clean: "clean",
         error: "error",
         pending: "pending",
         suspect: "suspect",
       }

  def original?
    !translation?
  end

  def name
    attachment.filename.to_s
  end

  def url
    attachment.url(expires_in: 5.minutes)
  end

  delegate :application_form, to: :document
end
