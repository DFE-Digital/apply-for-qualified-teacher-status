# frozen_string_literal: true

class FindOrCreateTeacherFromOneLogin
  include ServicePattern

  attr_reader :teacher

  def initialize(email:, gov_one_id:, eligibility_check:)
    @email = email
    @gov_one_id = gov_one_id
    @eligibility_check = eligibility_check
  end

  def call
    return nil if gov_one_id.blank?

    ActiveRecord::Base.transaction do
      find_or_create_teacher!

      create_application_form! if teacher_requires_application_form?
    end

    teacher
  rescue StandardError => e
    Sentry.capture_exception(e)

    nil
  end

  class DifferentOneLoginUidError < StandardError
  end

  private

  attr_reader :email, :gov_one_id, :eligibility_check

  def find_or_create_teacher!
    @teacher = Teacher.find_by(gov_one_id:)

    if teacher.nil?
      @teacher = Teacher.find_by(email:) || Teacher.create!(email:)

      raise DifferentOneLoginUidError if teacher.gov_one_id.present?

      teacher.update!(gov_one_id:)
    end

    teacher.update!(gov_one_email: email)
  end

  def create_application_form!
    if valid_eligibility_check?
      ApplicationFormFactory.call(
        teacher:,
        region: eligibility_check.region,
        eligibility_check:,
      )
    end
  end

  def valid_eligibility_check?
    eligibility_check.present? && eligibility_check.region.present? &&
      eligibility_check.country.eligibility_enabled?
  end

  def teacher_requires_application_form?
    teacher.persisted? && teacher.application_form.nil?
  end
end
