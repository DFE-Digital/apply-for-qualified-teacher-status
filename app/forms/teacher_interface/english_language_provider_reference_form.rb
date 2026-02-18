# frozen_string_literal: true

module TeacherInterface
  class EnglishLanguageProviderReferenceForm < BaseForm
    attr_accessor :application_form
    attribute :reference, :string

    validates :application_form, presence: true
    validates :reference, presence: true, max_string_length: true

    def update_model
      application_form.update!(
        english_language_provider_reference: reference,
        english_language_provider_other: false,
      )
    end
  end
end
