# frozen_string_literal: true

class TRS::Client::V3::FindTeachers
  include ServicePattern
  include TRS::Client::Connection

  attr_reader :application_form, :reverse_name

  def initialize(application_form:, reverse_name: false)
    @application_form = application_form
    @reverse_name = reverse_name
  end

  def call
    path = "/v3/teachers"
    response =
      connection.get(
        path,
        TRS::FindTeachersParams.call(application_form:, reverse_name:),
      )
    if response.success?
      response.body["results"].map do |r|
        r.transform_keys { |key| key.underscore.to_sym }
      end
    else
      []
    end
  rescue Faraday::Error
    []
  end
end
