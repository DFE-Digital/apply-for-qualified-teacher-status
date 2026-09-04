# frozen_string_literal: true

class AssessorInterface::UnlinkOneLoginForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :teacher, :user
  attribute :confirm, :boolean

  validates :teacher, :user, presence: true
  validates :confirm, inclusion: [true, false]

  def save
    return false if invalid?

    teacher.update!(gov_one_id: nil) if confirm

    true
  end
end
