class TeacherInterface::HasWorkHistoryForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form

  attribute :has_work_history, :boolean

  validates :application_form, presence: true

  def save
    return false unless valid?

    application_form.has_work_history = has_work_history
    application_form.save!
  end
end
