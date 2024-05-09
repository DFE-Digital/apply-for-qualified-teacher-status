# frozen_string_literal: true

class UpdateDQTMatchJob < ApplicationJob
  def perform(application_form)
    teachers = DQT::Client::FindTeachers.call(application_form:)

    if teachers.empty?
      teachers =
        DQT::Client::FindTeachers.call(application_form:, reverse_name: true)
    end

    application_form.update!(dqt_match: { teachers: })
  end
end
