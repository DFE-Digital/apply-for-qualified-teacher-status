# frozen_string_literal: true

class AssessorInterface::WorkHistoryContactForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :work_history, :user
  attribute :name, :string
  attribute :job, :string
  attribute :email, :string

  validates :work_history, :user, presence: true

  validates :email, valid_for_notify: true

  def save
    return false if invalid?

    new_name = name != work_history.contact_name ? name : nil
    new_job = job != work_history.contact_job ? job : nil
    new_email = email != work_history.contact_email ? email : nil

    UpdateWorkHistoryContact.call(
      work_history:,
      user:,
      name: new_name,
      job: new_job,
      email: new_email,
    )

    true
  end
end
