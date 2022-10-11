# frozen_string_literal: true

module TeacherInterface
  class SanctionConfirmationForm < BaseForm
    attribute :application_form
    attribute :confirmed_no_sanctions

    validates :confirmed_no_sanctions, presence: true

    private

    def update_model
      application_form.update!(confirmed_no_sanctions:)
    end
  end
end
