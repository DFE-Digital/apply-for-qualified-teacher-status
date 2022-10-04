# frozen_string_literal: true

class TeacherInterface::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def save(validate:)
    return false if validate && !valid?

    update_model
    true
  end
end
