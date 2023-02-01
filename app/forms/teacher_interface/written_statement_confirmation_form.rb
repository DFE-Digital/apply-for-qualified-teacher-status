# frozen_string_literal: true

module TeacherInterface
  class WrittenStatementConfirmationForm < BaseForm
    attr_accessor :application_form
    attribute :written_statement_confirmation, :boolean

    validates :application_form, presence: true
    validates :written_statement_confirmation, presence: true

    private

    def update_model
      if written_statement_confirmation
        application_form.update!(written_statement_confirmation: true)
      else
        application_form.update!(written_statement_confirmation: false)
      end
    end
  end
end
