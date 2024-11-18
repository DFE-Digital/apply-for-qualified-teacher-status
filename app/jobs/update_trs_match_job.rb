# frozen_string_literal: true

class UpdateTRSMatchJob < ApplicationJob
  def perform(application_form)
    unless application_form.submitted? && application_form.awarded_at.nil? &&
             application_form.declined_at.nil? &&
             application_form.withdrawn_at.nil?
      return
    end

    teachers = TRS::Client::FindTeachers.call(application_form:)

    if teachers.empty?
      teachers =
        TRS::Client::FindTeachers.call(application_form:, reverse_name: true)
    end

    application_form.update!(dqt_match: { teachers: })

    UpdateTRSMatchJob.set(wait: 24.hours).perform_later(application_form)
  end
end
