# frozen_string_literal: true

class FindOrCreateTeacherFromGovOne
  include ServicePattern

  attr_reader :teacher

  def initialize(email:, gov_one_id:, eligibility_check_id:)
    @email = email
    @gov_one_id = gov_one_id
    @eligibility_check_id = eligibility_check_id
  end

  def call
    ActiveRecord::Base.transaction do
      find_or_create_teacher!

      create_application_form! if teacher_requires_application_form?
    end

    teacher
  rescue StandardError => e
    Sentry.capture_exception(e)

    nil
  end

  private

  attr_reader :email, :gov_one_id, :eligibility_check_id

  def find_or_create_teacher!
    @teacher =
      Teacher.find_by(gov_one_id:) || Teacher.find_by(email:) ||
        Teacher.create!(email:)

    teacher.update!(gov_one_id:) if teacher.gov_one_id.nil?
  end

  def create_application_form!
    if valid_eligibility_check?
      ApplicationFormFactory.call(teacher:, region: eligibility_check.region)
    end
  end

  def valid_eligibility_check?
    eligibility_check.present? && eligibility_check.region.present? &&
      eligibility_check.country.eligibility_enabled?
  end

  def eligibility_check
    @eligibility_check ||= EligibilityCheck.find_by(id: eligibility_check_id)
  end

  def teacher_requires_application_form?
    teacher.persisted? && teacher.application_form.nil?
  end
end