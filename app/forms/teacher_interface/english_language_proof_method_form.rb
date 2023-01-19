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

      if medium_of_instruction?
        application_form.update!(
          english_language_provider_id: nil,
          english_language_provider_other: false,
          english_language_provider_reference: "",
        )

        application_form
          .english_language_proficiency_document
          .uploads
          .destroy_all
      else
        application_form
          .english_language_medium_of_instruction_document
          .uploads
          .destroy_all
      end
    end

    def medium_of_instruction?
      proof_method == "medium_of_instruction"
    end
  end
end
