# frozen_string_literal: true

class FindApplicantInDQTJob < ApplicationJob
  def perform(application_form)
    teachers = FindTeachersInDQT.call(application_form:, reverse_name: true)
    application_form.update!(dqt_match: { teachers: })
  end
end
