# frozen_string_literal: true

class AssessorInterface::AssignAsTeachingQualificationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :qualification, :user
  validates :qualification, :user, presence: true

  def save
    return false if invalid?

    AssignNewTeachingQualification.call(
      current_teaching_qualification: application_form.teaching_qualification,
      new_teaching_qualification: qualification,
      user:,
    )

    true
  end

  delegate :application_form, to: :qualification
end
