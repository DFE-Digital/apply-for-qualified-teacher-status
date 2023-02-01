# frozen_string_literal: true

module TeacherInterface
  class WrittenStatementConfirmationForm < BaseForm
    attr_accessor :application_form
    attribute :written_statement_confirmation, :boolean

    validates :application_form, presence: true
    validates :written_statement_confirmation, presence: true

    private

    def update_model
      application_form.update!(written_statement_confirmation:)
    end
  end
end
