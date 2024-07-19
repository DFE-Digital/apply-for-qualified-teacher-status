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
    validates :given_names, presence: true
    validates :family_name, presence: true
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
  end
end
