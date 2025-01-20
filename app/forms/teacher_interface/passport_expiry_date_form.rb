# frozen_string_literal: true

module TeacherInterface
  class PassportExpiryDateForm < BaseForm
    include ActiveRecord::AttributeAssignment

    attr_accessor :application_form
    attribute :passport_expiry_date

    validates :application_form, presence: true
    validates :passport_expiry_date, presence: true
    validate :passport_expiry_date_valid

    def update_model
      application_form.update!(passport_expiry_date:)
    end

    private

    def passport_expiry_date_valid
      date = DateValidator.parse(passport_expiry_date)

      if date.nil?
        errors.add(:passport_expiry_date, :invalid)
      elsif date < Date.current
        errors.add(:passport_expiry_date, :expired)
      end
    end
  end
end
