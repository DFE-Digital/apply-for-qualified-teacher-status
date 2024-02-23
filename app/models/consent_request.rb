# frozen_string_literal: true

class ConsentRequest < ApplicationRecord
  ATTACHABLE_DOCUMENT_TYPES = %w[signed_consent unsigned_consent].freeze

  include Documentable
  include Requestable

  belongs_to :qualification

  scope :order_by_role,
        -> { joins(:qualification).order("qualifications.start_date": :desc) }
  scope :order_by_user,
        -> { joins(:qualification).order("qualifications.created_at": :asc) }

  def expires_after
    6.weeks
  end
end
