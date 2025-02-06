# frozen_string_literal: true

module TeacherInterface
  class NameAndDateOfBirthForm < BaseForm
    include ActiveRecord::AttributeAssignment
    include SanitizeDates

    attr_accessor :application_form
    attribute :given_names, :string
    attribute :family_name, :string
    attribute :date_of_birth

    validates :application_form, presence: true
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

    def update_model
      sanitize_dates!(date_of_birth)
      application_form.update!(given_names:, family_name:, date_of_birth:)
    end

    def date_of_birth_valid
      date = DateValidator.parse(date_of_birth)
      return if date.nil?

      if date > 18.years.ago
        errors.add(:date_of_birth, :too_young)
      elsif date < 100.years.ago
        errors.add(:date_of_birth, :too_old)
      end
    end

    private

    def requires_passport_as_identity_proof
      application_form&.requires_passport_as_identity_proof?
    end
  end
end
