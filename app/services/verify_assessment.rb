# frozen_string_literal: true

class VerifyAssessment
  include ServicePattern

  def initialize(
    assessment:,
    user:,
    professional_standing:,
    qualifications:,
    qualifications_assessor_note:,
    work_histories:
  )
    @assessment = assessment
    @user = user
    @professional_standing = professional_standing
    @qualifications = qualifications
    @qualifications_assessor_note = qualifications_assessor_note
    @work_histories = work_histories
  end

  def call
    raise AlreadyVerified if assessment.verify?

    reference_requests =
      ActiveRecord::Base.transaction do
        assessment.qualifications_assessor_note = qualifications_assessor_note
        assessment.verify!

        create_professional_standing_request
        create_qualification_requests
        reference_requests = create_reference_requests

        application_form.reload

        ApplicationFormStatusUpdater.call(application_form:, user:)

        reference_requests
      end

    if reference_requests.present?
      send_reference_request_emails(reference_requests)
    end

    reference_requests
  end

  class AlreadyVerified < StandardError
  end

  private

  attr_reader :assessment,
              :user,
              :professional_standing,
              :qualifications,
              :qualifications_assessor_note,
              :work_histories

  delegate :application_form, to: :assessment
  delegate :teaching_authority_provides_written_statement, to: :application_form

  def create_professional_standing_request
    if professional_standing && !teaching_authority_provides_written_statement
      ProfessionalStandingRequest.create!(assessment:)
    end
  end

  def create_qualification_requests
    qualifications.map do |qualification|
      QualificationRequest
        .create!(assessment:, qualification:)
        .tap { |requestable| RequestRequestable.call(requestable:, user:) }
    end
  end

  def create_reference_requests
    work_histories.map do |work_history|
      ReferenceRequest
        .create!(assessment:, work_history:)
        .tap { |requestable| RequestRequestable.call(requestable:, user:) }
    end
  end

  def send_reference_request_emails(reference_requests)
    reference_requests.each do |reference_request|
      RefereeMailer.with(reference_request:).reference_requested.deliver_later
    end

    TeacherMailer
      .with(application_form:, reference_requests:)
      .references_requested
      .deliver_later
  end
end
