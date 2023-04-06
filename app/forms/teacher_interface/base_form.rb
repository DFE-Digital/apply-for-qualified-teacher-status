# frozen_string_literal: true

class TeacherInterface::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def save(validate:)
    return false if validate && !valid?

    ActiveRecord::Base.transaction do
      update_model
      update_application_form_status
    end

    true
  end

  def update_application_form_status
    if respond_to?(:application_form) && !application_form.nil?
      ApplicationFormSectionStatusUpdater.call(application_form:)
    end
  end
end
