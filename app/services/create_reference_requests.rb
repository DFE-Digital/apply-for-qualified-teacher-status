# frozen_string_literal: true

class CreateReferenceRequests
  include ServicePattern

  def initialize(assessment:, user:, work_histories:)
    @assessment = assessment
    @user = user
    @work_histories = work_histories
  end

  def call
    reference_requests =
      ActiveRecord::Base.transaction do
        requests = create_reference_requests
        update_application_form_status
        requests
      end

    send_emails(reference_requests)

    reference_requests
  end

  private

  attr_reader :assessment, :user, :work_histories

  delegate :application_form, to: :assessment
  delegate :teacher, to: :application_form

  def create_reference_requests
    work_histories.map do |work_history|
      request = ReferenceRequest.create!(assessment:, work_history:)
      create_timeline_event(request)
      request
    end
  end

  def update_application_form_status
    ApplicationFormStatusUpdater.call(application_form:, user:)
  end

  def create_timeline_event(reference_request)
    TimelineEvent.create!(
      application_form:,
      creator: user,
      event_type: "requestable_requested",
      requestable: reference_request,
    )
  end

  def send_emails(reference_requests)
    reference_requests.each do |reference_request|
      RefereeMailer.with(reference_request:).reference_requested.deliver_later
    end

    TeacherMailer.with(teacher:).references_requested.deliver_later
  end
end
