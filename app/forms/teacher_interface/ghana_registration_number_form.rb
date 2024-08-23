# frozen_string_literal: true

module TeacherInterface
  class GhanaRegistrationNumberForm < BaseForm
    attr_accessor :application_form
    attribute :license_number_parts, array: true

    validates :application_form, :license_number_parts, presence: true

    validate :license_number_parts_valid

    def update_model
      application_form.update!(registration_number:)
    end

    private

    def license_number_parts_valid
      parts = license_number_parts.compact_blank

      if parts.length == 3 && parts[0].length == 2 && parts[1].length == 6 &&
           parts[2].length == 4
        return
      end

      if parts.empty?
        errors.add(:license_number_parts, :blank)
      else
        errors.add(:license_number_parts, :invalid)
      end
    end

    def registration_number
      license_number_parts.compact_blank.join("/")
    end
  end
end
