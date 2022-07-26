class TeacherInterface::AlternativeNameForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form

  attribute :has_alternative_name, :boolean
  attribute :alternative_given_names, :string
  attribute :alternative_family_name, :string

  validates :application_form, presence: true

  def save
    return false unless valid?

    application_form.has_alternative_name = has_alternative_name
    application_form.alternative_given_names = alternative_given_names
    application_form.alternative_family_name = alternative_family_name
    application_form.save!
  end
end
