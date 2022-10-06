# frozen_string_literal: true

module TeacherInterface
  class NameAndDateOfBirthForm < BaseForm
    include ActiveRecord::AttributeAssignment

    attr_accessor :application_form
    attribute :given_names, :string
    attribute :family_name, :string
    attribute :date_of_birth, :date

    validates :application_form, presence: true
    validates :given_names, presence: true
    validates :family_name, presence: true
    validates :date_of_birth, presence: true
    validate :date_of_birth_valid

    def update_model
      application_form.update!(given_names:, family_name:, date_of_birth:)
    end

    def date_of_birth_valid
      return unless date_of_birth.is_a?(Date)

      if date_of_birth.year.digits.length != 4
        errors.add(:date_of_birth, :blank)
      elsif date_of_birth > 18.years.ago
        errors.add(:date_of_birth, :too_young)
      elsif date_of_birth < 100.years.ago
        errors.add(:date_of_birth, :too_old)
      end
    end
  end
end
