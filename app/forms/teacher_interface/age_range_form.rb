class TeacherInterface::AgeRangeForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form
  attribute :minimum, :integer
  attribute :maximum, :integer

  validates :application_form, presence: true
  validates :minimum,
            numericality: {
              only_integer: true,
              allow_nil: true,
              greater_than_or_equal_to: 0
            }
  validates :maximum,
            numericality: {
              only_integer: true,
              allow_nil: true,
              greater_than_or_equal_to: :minimum
            }

  def save
    return false unless valid?

    application_form.age_range_min = minimum
    application_form.age_range_max = maximum
    application_form.save!
  end
end
