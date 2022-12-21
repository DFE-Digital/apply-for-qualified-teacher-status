# frozen_string_literal: true

module TeacherInterface
  class EnglishLanguageProviderForm < BaseForm
    attr_accessor :application_form
    attribute :provider_id, :string

    validates :application_form, presence: true
    validates :provider_id,
              presence: true,
              inclusion: {
                in: ->(_form) {
                  EnglishLanguageProvider.pluck(:id).map(&:to_s)
                },
              }

    def update_model
      application_form.update!(english_language_provider_id: provider_id)
    end
  end
end
