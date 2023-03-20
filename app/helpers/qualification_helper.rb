# frozen_string_literal: true

module QualificationHelper
  def qualification_title(qualification)
    if qualification.title.present? && qualification.institution_name.present?
      return "#{qualification.title} (#{qualification.institution_name})"
    end

    qualification.title.presence || qualification.institution_name.presence ||
      qualification.institution_country_name.presence ||
      I18n.t(
        "application_form.qualifications.heading.title.#{qualification.locale_key}",
      )
  end
end
