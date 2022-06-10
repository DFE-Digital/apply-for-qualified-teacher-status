class TeachChildrenForm
  include ActiveModel::Model

  attr_accessor :eligibility_check
  attr_reader :teach_children

  validates :eligibility_check, presence: true
  validates :teach_children, inclusion: { in: [true, false] }

  def teach_children=(value)
    @teach_children = ActiveModel::Type::Boolean.new.cast(value)
  end

  def save
    return false unless valid?

    eligibility_check.teach_children = teach_children
    eligibility_check.save!
  end

  def success_url
    Rails.application.routes.url_helpers.eligibility_interface_misconduct_path
  end
end
