# frozen_string_literal: true

module TRS
  module V3
    class TRNRequestParams
      include ServicePattern

      def initialize(request_id:, application_form:)
        @request_id = request_id
        @application_form = application_form
        @teacher = application_form.teacher
      end

      def call
        {
          requestId: request_id,
          person: {
            firstName: application_form.given_names,
            middleName: nil,
            lastName: application_form.family_name,
            dateOfBirth: application_form.date_of_birth.iso8601,
            emailAddresses: [teacher.email],
          },
          identityVerified: true,
          oneLoginUserSubject: teacher.gov_one_id,
        }
      end

      private

      attr_reader :request_id, :application_form, :teacher
    end
  end
end
