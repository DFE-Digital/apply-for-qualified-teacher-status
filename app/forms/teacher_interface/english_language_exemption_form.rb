# frozen_string_literal: true

module TeacherInterface
  class EnglishLanguageExemptionForm < BaseForm
    attr_accessor :application_form, :exemption_field
    attribute :exempt, :boolean

    validates :application_form, presence: true
    validates :exemption_field, presence: true
    validates :exempt, inclusion: { in: [true, false] }

    def update_model
      application_form.update!(
        { "english_language_#{exemption_field}_exempt": exempt },
      )
    end

    def citizenship?
      exemption_field == "citizenship"
    end
  end
end
