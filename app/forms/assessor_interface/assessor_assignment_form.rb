class AssessorInterface::AssessorAssignmentForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form
  attribute :assessor_id, :string
  attribute :assigning_user_id, :string

  validates :application_form, :assessor_id, :assigning_user_id, presence: true

  def save!
    return false unless valid?

    application_form.assessor_id = assessor_id
    application_form.save!
    create_timeline_event!
  end

  private

  def create_timeline_event!
    TimelineEvent.create!(
      application_form:,
      event_type: "assessor_assigned",
      creator_id: assigning_user_id,
      assignee_id: assessor_id
    )
  end
end
