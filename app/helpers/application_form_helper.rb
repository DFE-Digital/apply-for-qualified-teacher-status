module ApplicationFormHelper
  def application_form_full_name(application_form)
    "#{application_form.given_names} #{application_form.family_name}"
  end

  def application_form_summary_rows(application_form)
    [
      [
        I18n.t("application_form.summary.country"),
        CountryName.from_country(application_form.region.country)
      ],
      [I18n.t("application_form.summary.region"), application_form.region.name],
      [
        I18n.t("application_form.summary.created_at"),
        application_form.created_at.strftime("%e %B %Y")
      ],
      [
        I18n.t("application_form.summary.days_remaining_sla"),
        "Not implemented"
      ],
      [I18n.t("application_form.summary.assignee"), "Not implemented"],
      [I18n.t("application_form.summary.reviewer"), "Not implemented"],
      [
        I18n.t("application_form.summary.status"),
        render(
          GovukComponent::TagComponent.new(
            text: "Not implemented",
            colour: "blue"
          )
        )
      ],
      [I18n.t("application_form.summary.notes"), "Not implemented"]
    ].map { |key, value| { key: { text: key }, value: { text: value } } }
  end
end
