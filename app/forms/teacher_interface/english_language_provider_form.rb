# frozen_string_literal: true

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
      if provider_id == "other"
        application_form.update!(
          english_language_provider_id: nil,
          english_language_provider_other: true,
        )
      else
        application_form.update!(
          english_language_provider_id: provider_id,
          english_language_provider_other: false,
        )
      end
    end

    OTHER_PROVIDER =
      OpenStruct.new(id: "other", name: "Other approved provider")

    def providers
      EnglishLanguageProvider
        .order(:created_at)
        .pluck(:id, :name)
        .map { |id, name| OpenStruct.new(id: id.to_s, name:) }
        .tap do |providers|
          if application_form&.reduced_evidence_accepted
            providers << OTHER_PROVIDER
          end
        end
    end

    def other?
      provider_id == "other"
    end
  end
end
