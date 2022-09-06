class AssessorInterface::ReviewerAssignmentForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form, :staff
  attribute :reviewer_id, :string

  validates :application_form, :staff, :reviewer_id, presence: true
  def save!
    return false unless valid?

    application_form.reviewer_id = reviewer_id
    application_form.save!
    create_timeline_event!
  end

  private

  def create_timeline_event!
    TimelineEvent.create!(
      application_form:,
      event_type: "reviewer_assigned",
      creator: staff,
      assignee_id: reviewer_id
    )
  end
end
