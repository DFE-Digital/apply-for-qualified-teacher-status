class AssessorInterface::CompleteAssessmentForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form, :staff
  attribute :new_state, :string

  validates :application_form, :staff, :new_state, presence: true
  validates :new_state, inclusion: %w[awarded declined]

  def save!
    return false unless valid?

    ChangeApplicationFormState.call(application_form:, user: staff, new_state:)
  end
end
