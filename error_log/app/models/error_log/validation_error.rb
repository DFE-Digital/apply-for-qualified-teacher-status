module ErrorLog
  class ValidationError < ApplicationRecord
    belongs_to :record, polymorphic: true

    validates :form_object, presence: true
    validates :messages, presence: true
  end
end
