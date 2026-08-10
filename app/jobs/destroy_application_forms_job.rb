# frozen_string_literal: true

class DestroyApplicationFormsJob < ApplicationJob
  def perform
    ApplicationForm.destroyable.find_each do |application_form|
      DestroyApplicationFormJob.perform_later(application_form)
    end
  end
end
