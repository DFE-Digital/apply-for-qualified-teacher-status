class TeacherInterface::AgeRangeForm
  include ActiveModel::Model

  attr_accessor :application_form
  attr_reader :age_range_min, :age_range_max

  validates :application_form, presence: true
  validates :age_range_min,
            numericality: {
              only_integer: true,
              allow_nil: true,
              greater_than_or_equal_to: 0
            }
  validates :age_range_max,
            numericality: {
              only_integer: true,
              allow_nil: true,
              greater_than_or_equal_to: :age_range_min
            }

  def age_range_min=(value)
    @age_range_min = ActiveModel::Type::Integer.new.cast(value)
  end

  def age_range_max=(value)
    @age_range_max = ActiveModel::Type::Integer.new.cast(value)
  end

  def save
    return false unless valid?

    application_form.age_range_min = age_range_min
    application_form.age_range_max = age_range_max
    application_form.save!
  end
end
