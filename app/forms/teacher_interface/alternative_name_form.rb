# frozen_string_literal: true

module TeacherInterface
  class AlternativeNameForm < BaseForm
    attr_accessor :application_form
    attribute :has_alternative_name, :boolean
    attribute :alternative_given_names, :string
    attribute :alternative_family_name, :string

    validates :application_form, presence: true
    validates :has_alternative_name, inclusion: { in: [true, false] }
    validates :alternative_given_names,
              presence: true,
              if: :has_alternative_name
    validates :alternative_family_name,
              presence: true,
              if: :has_alternative_name

    def update_model
      application_form.update!(
        has_alternative_name:,
        alternative_given_names:,
        alternative_family_name:,
      )
    end
  end
end
