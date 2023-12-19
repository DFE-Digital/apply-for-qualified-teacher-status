# frozen_string_literal: true

module Emailable
  extend ActiveSupport::Concern

  included do
    validates :email,
              presence: true,
              uniqueness: {
                allow_blank: true,
                case_sensitive: false,
                if: :will_save_change_to_email?,
              },
              valid_for_notify: true
  end

  class_methods do
    def find_by_email(email)
      find_by("LOWER(email) = ?", email&.downcase)
    end

    def find_or_initialize_by_email(email)
      find_by_email(email) || new(email:)
    end
  end
end
