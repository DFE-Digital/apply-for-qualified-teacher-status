# frozen_string_literal: true

module TeacherInterface
  class RegistrationNumberForm < BaseForm
    attr_accessor :application_form
    attribute :registration_number, :string

    validates :application_form, presence: true
    validates :registration_number, string_length: true

    def update_model
      application_form.update!(
        registration_number: registration_number.presence || "",
      )
    end
  end
end
