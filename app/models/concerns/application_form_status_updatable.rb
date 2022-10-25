module ApplicationFormStatusUpdatable
  extend ActiveSupport::Concern

  included do
    after_save :update_application_form_status
    after_destroy :update_application_form_status
  end

  def update_application_form_status
    return unless application_form
    ApplicationFormStatusUpdater.call(application_form:)
    application_form.save!
  end
end
