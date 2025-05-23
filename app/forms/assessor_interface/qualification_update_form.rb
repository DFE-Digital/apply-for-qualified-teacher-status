# frozen_string_literal: true

class AssessorInterface::QualificationUpdateForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :qualification, :user

  attribute :title, :string
  attribute :institution_name, :string

  attribute :certificate_date
  attribute :complete_date
  attribute :start_date

  attribute :teaching_qualification_part_of_degree, :boolean

  validates :qualification, :user, presence: true
  validates_with DateComparisonValidator,
                 earlier_field: :start_date,
                 later_field: :complete_date

  validates_with DateComparisonValidator,
                 earlier_field: :complete_date,
                 later_field: :certificate_date,
                 allow_equal: true

  validate :start_date_valid_for_existing_values
  validate :complete_date_valid_for_existing_values
  validate :certificate_date_valid_for_existing_values

  def save
    return false if invalid?

    new_title = title != qualification.title ? title : nil
    new_institution_name =
      (institution_name if institution_name != qualification.institution_name)
    new_certificate_date =
      (
        if parsed_certificate_date != qualification.certificate_date
          parsed_certificate_date
        end
      )
    new_complete_date =
      (
        if parsed_complete_date != qualification.complete_date
          parsed_complete_date
        end
      )
    new_start_date =
      parsed_start_date != qualification.start_date ? parsed_start_date : nil
    new_teaching_qualification_part_of_degree =
      if teaching_qualification_part_of_degree !=
           application_form.teaching_qualification_part_of_degree
        teaching_qualification_part_of_degree
      end

    UpdateTeachingQualification.call(
      qualification:,
      user:,
      title: new_title,
      institution_name: new_institution_name,
      certificate_date: new_certificate_date,
      complete_date: new_complete_date,
      start_date: new_start_date,
      teaching_qualification_part_of_degree:
        new_teaching_qualification_part_of_degree,
    )

    true
  rescue UpdateTeachingQualification::InvalidWorkHistoryDuration
    errors.add(:certificate_date, :work_history_under_9_months)

    false
  end

  private

  delegate :application_form, to: :qualification

  def parsed_start_date
    @parsed_start_date ||= DateValidator.parse(start_date)
  end

  def parsed_complete_date
    @parsed_complete_date ||= DateValidator.parse(complete_date)
  end

  def parsed_certificate_date
    @parsed_certificate_date ||= DateValidator.parse(certificate_date)
  end

  def start_date_valid_for_existing_values
    return if start_date[1].blank? && start_date[2].blank?

    if parsed_start_date.nil?
      errors.add(:start_date, :invalid)
    elsif parsed_complete_date.nil? &&
          qualification.complete_date <= parsed_start_date
      errors.add(:start_date, :after_existing_complete_date)
    end
  end

  def complete_date_valid_for_existing_values
    return if complete_date[1].blank? && complete_date[2].blank?

    if parsed_complete_date.nil?
      errors.add(:complete_date, :invalid)
    elsif parsed_start_date.nil? &&
          qualification.start_date >= parsed_complete_date
      errors.add(:complete_date, :before_existing_start_date)
    elsif parsed_certificate_date.nil? &&
          qualification.certificate_date < parsed_complete_date
      errors.add(:complete_date, :after_existing_certificate_date)
    end
  end

  def certificate_date_valid_for_existing_values
    return if certificate_date[1].blank? && certificate_date[2].blank?

    if parsed_certificate_date.nil?
      errors.add(:certificate_date, :invalid)
    elsif parsed_complete_date.nil? &&
          qualification.complete_date > parsed_certificate_date
      errors.add(:certificate_date, :before_existing_complete_date)
    end
  end
end
