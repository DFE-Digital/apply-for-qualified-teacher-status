# frozen_string_literal: true

module AssessorInterface
  class PreliminaryCheckForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_accessor :assessment
    attribute :preliminary_check_complete, :boolean

    validates :preliminary_check_complete, inclusion: { in: [true, false] }

    delegate :application_form, to: :assessment

    def save
      return false unless valid?

      assessment.update!(preliminary_check_complete:)
      true
    end
  end
end
