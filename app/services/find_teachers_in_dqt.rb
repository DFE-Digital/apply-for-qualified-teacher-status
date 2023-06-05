# frozen_string_literal: true

class FindTeachersInDQT
  include ServicePattern

  attr_reader :application_form, :reverse_name

  def initialize(application_form:, reverse_name: false)
    @application_form = application_form
    @reverse_name = reverse_name
  end

  def call
    results = DQT::Client::FindTeachers.call(application_form:)
    if results.empty? && reverse_name
      results =
        DQT::Client::FindTeachers.call(application_form:, reverse_name: true)
    end
    results
  end
end
