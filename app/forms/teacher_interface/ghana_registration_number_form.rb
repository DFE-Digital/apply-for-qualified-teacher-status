# frozen_string_literal: true

module TeacherInterface
  class GhanaRegistrationNumberForm < BaseForm
    attr_accessor :application_form

    attribute :registration_number, :string
    attribute :license_number_part_one, :string
    attribute :license_number_part_two, :string
    attribute :license_number_part_three, :string

    validates :application_form, presence: true

    validate :license_number_parts_valid

    def initialize(attributes = {})
      super

      if attributes[:registration_number].present?
        license_number_parts = attributes[:registration_number].split("/")

        self.license_number_part_one = license_number_parts[0]
        self.license_number_part_two = license_number_parts[1]
        self.license_number_part_three = license_number_parts[2]
      end
    end

    def update_model
      application_form.update!(registration_number:)
    end

    def registration_number_validator
      @registration_number_validator ||=
        RegistrationNumberValidators::Ghana.new(registration_number:)
    end

    private

    def license_number_parts_valid
      return if registration_number_validator.valid?

      errors.add(:registration_number, :invalid)
    end

    def registration_number
      registration_number_parts = [
        license_number_part_one,
        license_number_part_two,
        license_number_part_three,
      ].map(&:strip)

      return nil if registration_number_parts.compact_blank.empty?

      registration_number_parts.join("/")
    end
  end
end
