# frozen_string_literal: true

module TeacherInterface
  class EnglishLanguageProofMethodForm < BaseForm
    attr_accessor :application_form
    attribute :proof_method, :string

    validates :application_form, presence: true
    validates :proof_method,
              presence: true,
              inclusion: %w[medium_of_instruction provider]

    def update_model
      application_form.update!(english_language_proof_method: proof_method)
    end

    def medium_of_instruction?
      proof_method == "medium_of_instruction"
    end
  end
end
