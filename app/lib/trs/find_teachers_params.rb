# frozen_string_literal: true

module TRS
  class FindTeachersParams
    include ServicePattern

    attr_reader :application_form, :reverse_name

    def initialize(application_form:, reverse_name: false)
      @application_form = application_form
      @reverse_name = reverse_name
    end

    def call
      {
        dateOfBirth: application_form.date_of_birth&.to_date&.iso8601,
        findBy: "LastNameAndDateOfBirth",
        lastName:
          (
            if reverse_name
              application_form.given_names.split(" ").first
            else
              application_form.family_name
            end
          ),
      }
    end
  end
end
