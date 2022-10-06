# frozen_string_literal: true

module TeacherInterface
  class RegistrationNumberForm < BaseForm
    attr_accessor :application_form
    attribute :registration_number, :string

    validates :application_form, presence: true
    validates :registration_number, presence: true

    def update_model
      application_form.update!(registration_number:)
    end
  end
end
