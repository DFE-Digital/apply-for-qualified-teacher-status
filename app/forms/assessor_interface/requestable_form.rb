# frozen_string_literal: true

class AssessorInterface::RequestableForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable
  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      requestable.reviewed!(passed)

      if requestable.is_a?(ReferenceRequest)
        UpdateAssessmentInductionRequired.call(assessment:)
      end
    end

    true
  end

  delegate :application_form, :assessment, to: :requestable
end
