# frozen_string_literal: true

class TeacherInterface::QualificationViewObject
  attr_reader :qualification

  def initialize(qualification:)
    @qualification = qualification
  end

  def qualifications_information
    region = qualification.application_form.region

    [
      region.qualifications_information,
      region.country.qualifications_information,
    ].compact_blank.join("\n\n")
  end
end
