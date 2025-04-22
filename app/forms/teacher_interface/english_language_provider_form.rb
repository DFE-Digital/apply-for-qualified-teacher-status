# frozen_string_literal: true

require "ostruct"

module TeacherInterface
  class EnglishLanguageProviderForm < BaseForm
    attr_accessor :application_form
    attribute :provider_id, :string

    validates :application_form, presence: true
    validates :provider_id,
              presence: true,
              inclusion: {
                in: ->(form) { form.providers.map(&:id) },
              }

    def initialize(values)
      values[:provider_id] = "other" if values.delete(:provider_other)

      super(values)
    end

    def update_model
      if provider_id != application_form.english_language_provider_id
        application_form.update!(english_language_provider_reference: "")
      end

      application_form.update!(
        english_language_provider_id: provider_id,
        english_language_provider_other: false,
      )

      application_form.english_language_proficiency_document.uploads.destroy_all
    end

    def providers
      EnglishLanguageProvider
        .order(:created_at)
        .pluck(:id, :name)
        .map { |id, name| OpenStruct.new(id: id.to_s, name:) }
    end
  end
end
