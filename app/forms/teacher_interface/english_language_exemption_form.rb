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

      if exempt
        application_form.update!(
          english_language_proof_method: nil,
          english_language_provider_id: nil,
          english_language_provider_other: false,
          english_language_provider_reference: "",
        )

        application_form
          .english_language_medium_of_instruction_document
          .uploads
          .destroy_all

        application_form
          .english_language_proficiency_document
          .uploads
          .destroy_all

        application_form
          .english_for_speakers_of_other_languages_document
          .uploads
          .destroy_all
      end

      if exempt && citizenship?
        application_form.update!(english_language_qualification_exempt: nil)
      end
    end

    def citizenship?
      exemption_field == "citizenship"
    end
  end
end
