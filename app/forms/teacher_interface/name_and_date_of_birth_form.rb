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
            comparison: {
              less_than: Time.zone.today,
            },
            presence: true,
            inclusion: 100.years.ago..18.years.ago

  validates :given_names, presence: true
  validates :family_name, presence: true

  def save
    return false unless valid?

    application_form.given_names = given_names
    application_form.family_name = family_name
    application_form.date_of_birth = date_of_birth
    application_form.save!
  end
end
