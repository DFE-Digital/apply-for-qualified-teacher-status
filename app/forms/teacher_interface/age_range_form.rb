# frozen_string_literal: true

module TeacherInterface
  class AgeRangeForm < BaseForm
    attr_accessor :application_form
    attribute :minimum, :integer
    attribute :maximum, :integer

    validates :application_form, presence: true
    validates :minimum,
              presence: true,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 4,
                less_than_or_equal_to: 18,
                allow_nil: true,
              }
    validates :maximum,
              presence: true,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: :minimum,
                allow_nil: true,
              }

    def update_model
      application_form.update!(age_range_min: minimum, age_range_max: maximum)
    end
  end
end
