# frozen_string_literal: true

class DestroyApplicationFormJob < SolidQueueApplicationJob
  def perform(application_form)
    DestroyApplicationForm.call(application_form:)
  end
end
