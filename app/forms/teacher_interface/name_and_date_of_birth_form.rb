# frozen_string_literal: true

module TeacherInterface
  class NameAndDateOfBirthForm < BaseForm
    include ActiveRecord::AttributeAssignment
    include SanitizeDates

    attr_accessor :application_form
    attribute :given_names, :string
    attribute :family_name, :string
    attribute :date_of_birth

    attribute :national_insurance_number, :string
    attribute :national_insurance_number_part_one, :string
    attribute :national_insurance_number_part_two, :string
    attribute :national_insurance_number_part_three, :string

    validates :application_form, presence: true
    validates :given_names, max_string_length: true
    validates :given_names,
              presence: {
                message: :blank_passport,
              },
              if: :requires_passport_as_identity_proof

    validates :given_names,
              presence: {
                message: :blank_id_documents,
              },
              unless: :requires_passport_as_identity_proof

    validates :family_name, max_string_length: true
    validates :family_name,
              presence: {
                message: :blank_passport,
              },
              if: :requires_passport_as_identity_proof

    validates :family_name,
              presence: {
                message: :blank_id_documents,
              },
              unless: :requires_passport_as_identity_proof

    validates :date_of_birth, date: true
    validate :date_of_birth_valid
    validate :national_insurance_number_parts_valid

    def initialize(attributes = {})
      super

      if attributes[:national_insurance_number].present?
        self.national_insurance_number_part_one =
          attributes[:national_insurance_number][0..1]
        self.national_insurance_number_part_two =
          attributes[:national_insurance_number][2..7]
        self.national_insurance_number_part_three =
          attributes[:national_insurance_number][8]
      end
    end

    def update_model
      sanitize_dates!(date_of_birth)
      application_form.update!(
        given_names:,
        family_name:,
        date_of_birth:,
        national_insurance_number:,
      )
    end

    def national_insurance_number_validator
      @national_insurance_number_validator ||=
        NationalInsuranceNumberValidator.new(
          national_insurance_number_part_one:,
          national_insurance_number_part_two:,
          national_insurance_number_part_three:,
        )
    end

    private

    def date_of_birth_valid
      date = DateValidator.parse(date_of_birth)
      return if date.nil?

      if date > 18.years.ago
        errors.add(:date_of_birth, :too_young)
      elsif date < 100.years.ago
        errors.add(:date_of_birth, :too_old)
      end
    end

    def national_insurance_number_parts_valid
      if national_insurance_number.blank? ||
           national_insurance_number_validator.valid?
        return
      end

      errors.add(:national_insurance_number, :invalid)
    end

    def national_insurance_number
      parts =
        [
          national_insurance_number_part_one,
          national_insurance_number_part_two,
          national_insurance_number_part_three,
        ].map { |part| part.to_s.gsub(/\s/, "") }

      return nil if parts.compact_blank.empty?

      parts.join
    end

    def requires_passport_as_identity_proof
      application_form&.requires_passport_as_identity_proof?
    end
  end
end
