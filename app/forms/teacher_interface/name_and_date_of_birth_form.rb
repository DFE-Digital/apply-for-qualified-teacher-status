class TeacherInterface::NameAndDateOfBirthForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form
  attribute :given_names, :string
  attribute :family_name, :string
  attribute :date_of_birth, :date

  validates :application_form, presence: true
  validates :date_of_birth,
            allow_blank: true,
            inclusion: 100.years.ago..18.years.ago

  def save
    return false unless valid?

    application_form.given_names = given_names
    application_form.family_name = family_name
    application_form.date_of_birth = date_of_birth
    application_form.save!
  end
end
