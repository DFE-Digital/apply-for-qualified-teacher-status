# frozen_string_literal: true

class UpdateQualificationCertificateDate
  include ServicePattern

  def initialize(qualification:, user:, certificate_date:)
    @qualification = qualification
    @user = user
    @certificate_date = certificate_date
  end

  def call
    old_certificate_date = qualification.certificate_date

    ActiveRecord::Base.transaction do
      qualification.update!(certificate_date:)
      UpdateAssessmentInductionRequired.call(assessment:) if assessment
      create_timeline_event(old_certificate_date:)
    end
  end

  private

  attr_reader :qualification, :user, :certificate_date

  delegate :application_form, to: :qualification
  delegate :assessment, to: :application_form

  def create_timeline_event(old_certificate_date:)
    CreateTimelineEvent.call(
      "information_changed",
      application_form:,
      user:,
      qualification:,
      column_name: "certificate_date",
      old_value: old_certificate_date.strftime("%B %Y").strip,
      new_value: certificate_date.strftime("%B %Y").strip,
    )
  end
end
