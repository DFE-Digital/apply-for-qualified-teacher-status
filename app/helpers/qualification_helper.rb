module QualificationHelper
  def qualification_title(qualification)
    qualification.title.presence || qualification.institution_name.presence ||
      qualification.institution_country_name.presence ||
      I18n.t(
        "application_form.qualifications.heading.title.#{qualification.locale_key}",
      )
  end
end
