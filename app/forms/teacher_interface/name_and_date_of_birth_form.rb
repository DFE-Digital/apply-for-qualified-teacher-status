class TeacherInterface::NameAndDateOfBirthForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form
  attribute :given_names, :string
  attribute :family_name, :string
  attribute :date_of_birth, :date

  validates :application_form, presence: true
  validate :validate_date_of_birth

  def save
    return false unless valid?

    application_form.given_names = given_names
    application_form.family_name = family_name
    application_form.date_of_birth = date_of_birth
    application_form.save!
  end

  private

  def validate_date_of_birth
    if date_of_birth.present? && date_of_birth >= 18.years.ago
      errors.add(
        :date_of_birth,
        I18n.t(
          "activemodel.errors.models.teacher_interface/name_and_date_of_birth_form.attributes.date_of_birth.inclusion"
        )
      )
    end
  end
end
