# frozen_string_literal: true

# == Schema Information
#
# Table name: uploads
#
#  id                  :bigint           not null, primary key
#  filename            :string           not null
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

  enum :malware_scan_result,
       {
         clean: "clean",
         error: "error",
         pending: "pending",
         suspect: "suspect",
       },
       prefix: :malware_scan

  delegate :application_form, to: :document

  def original?
    !translation?
  end

  def url
    attachment.url(expires_in: 5.minutes)
  end

  def is_pdf?
    attachment.blob.content_type == "application/pdf"
  end

  alias_method :safe_to_link?, :malware_scan_clean?

  def unsafe_to_link?
    malware_scan_error? || malware_scan_suspect?
  end
end
