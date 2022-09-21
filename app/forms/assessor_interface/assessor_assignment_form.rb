class AssessorInterface::AssessorAssignmentForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form, :staff
  attribute :assessor_id, :string

  validates :application_form, :staff, :assessor_id, presence: true

  def save!
    return false unless valid?

    AssignApplicationFormAssessor.call(
      application_form:,
      user: staff,
      assessor: Staff.find(assessor_id),
    )
  end
end
