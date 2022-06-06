require_relative "../../../../app/models/concerns/log_errors"

class UserForm
  include ActiveModel::Model
  include ErrorLog::LogErrors

  attr_accessor :name, :record

  validates :name, presence: true

  def save
    valid?

    record.save
  end
end
