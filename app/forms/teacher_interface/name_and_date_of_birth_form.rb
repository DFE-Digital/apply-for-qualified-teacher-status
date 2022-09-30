class TeacherInterface::NameAndDateOfBirthForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form
  attribute :given_names, :string
  attribute :family_name, :string
  attribute :date_of_birth, :date

  validates :application_form, presence: true
  validate :date_of_birth_valid

  validates :given_names, presence: true
  validates :family_name, presence: true

  def save
    return false unless valid?

    application_form.given_names = given_names
    application_form.family_name = family_name
    application_form.date_of_birth = date_of_birth
    application_form.save!
  end

  def date_of_birth_valid
    if !date_of_birth.is_a?(Date)
      errors.add(:date_of_birth, :invalid)
    elsif date_of_birth.year.digits.length != 4
      errors.add(:date_of_birth, :invalid)
    elsif date_of_birth > 18.years.ago
      errors.add(:date_of_birth, :too_young)
    elsif date_of_birth < 100.years.ago
      errors.add(:date_of_birth, :too_old)
    end
  end
end
