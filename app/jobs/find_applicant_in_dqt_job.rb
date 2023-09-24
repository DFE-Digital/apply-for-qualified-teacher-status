# frozen_string_literal: true

class FindApplicantInDQTJob < ApplicationJob
  def perform(application_form_id:)
    application_form = ApplicationForm.find(application_form_id)
    teachers = FindTeachersInDQT.call(application_form:, reverse_name: true)
    application_form.update!(dqt_match: { teachers: })
  end
end
