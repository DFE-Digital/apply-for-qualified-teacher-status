# frozen_string_literal: true

class TeacherInterface::DocumentAvailableForm < TeacherInterface::BaseForm
  attr_accessor :document
  attribute :available, :boolean

  validates :document, presence: true
  validates :available, inclusion: { in: [true, false] }

  def update_model
    document.update!(available:)
  end

  delegate :application_form, to: :document
end
