class TeacherInterface::RegistrationNumberForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form
  attribute :registration_number, :string

  validates :application_form, presence: true

  def save
    return false unless valid?

    application_form.registration_number = registration_number
    application_form.save!
  end
end
