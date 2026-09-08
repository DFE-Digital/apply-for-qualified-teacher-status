# frozen_string_literal: true

class AssessorInterface::UnlinkOneLoginForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :teacher, :user
  attribute :confirm, :boolean

  validates :teacher, :user, presence: true
  validates :confirm, inclusion: [true, false]

  def save
    return false if invalid?

    if confirm
      ActiveRecord::Base.transaction do
        teacher.update!(gov_one_id: nil)

        TimelineEvent.create!(
          application_form: teacher.application_form,
          event_type: "applicant_one_login_unlinked",
          creator: user,
        )
      end
    end

    true
  end
end
