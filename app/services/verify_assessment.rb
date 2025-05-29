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
        update_assessment_verification_started_at

        create_professional_standing_request
        create_qualification_requests
        reference_requests = create_reference_requests

        application_form.reload

        ApplicationFormStatusUpdater.call(application_form:, user:)

        reference_requests
      end

    if reference_requests.present?
      send_references_requested_email(reference_requests)
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
  delegate :teaching_authority_provides_written_statement,
           :reduced_evidence_accepted,
           :needs_work_history,
           to: :application_form

  def create_professional_standing_request
    if professional_standing && !skip_professional_standing?
      ProfessionalStandingRequest.create!(assessment:)
    end
  end

  def create_qualification_requests
    qualifications.map do |qualification|
      QualificationRequest.create!(assessment:, qualification:)
    end
  end

  def create_reference_requests
    return if skip_references?

    work_histories.map do |work_history|
      ReferenceRequest
        .create!(assessment:, work_history:)
        .tap { |requestable| RequestRequestable.call(requestable:, user:) }
    end
  end

  def update_assessment_verification_started_at
    assessment.update!(verification_started_at: Time.zone.now) if assessment.verification_started_at.nil?
  end

  def send_references_requested_email(reference_requests)
    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :references_requested,
      reference_requests:,
    )
  end

  def skip_professional_standing?
    teaching_authority_provides_written_statement ||
      reduced_evidence_accepted || !needs_work_history
  end

  def skip_references?
    reduced_evidence_accepted || !needs_work_history
  end
end
