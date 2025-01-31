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

    def expiry_date_in_the_past?
      date =
        if passport_expiry_date.is_a?(Date)
          passport_expiry_date
        else
          DateValidator.parse(passport_expiry_date)
        end

      date.present? && date < Date.current
    end

    private

    def passport_expiry_date_valid
      date = DateValidator.parse(passport_expiry_date)

      errors.add(:passport_expiry_date, :invalid) if date.nil?
    end
  end
end
