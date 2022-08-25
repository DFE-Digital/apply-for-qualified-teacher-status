module ApplicationFormHelper
  def application_form_full_name(application_form)
    "#{application_form.given_names} #{application_form.family_name}"
  end

  def application_form_summary_rows(
    application_form,
    include_name:,
    include_reference:,
    include_notes:
  )
    [
      (
        if include_name
          [
            I18n.t("application_form.summary.name"),
            application_form_full_name(application_form)
          ]
        end
      ),
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
      [
        I18n.t("application_form.summary.assessor"),
        "Not implemented",
        [{ href: "#" }]
      ],
      [
        I18n.t("application_form.summary.reviewer"),
        "Not implemented",
        [{ href: "#" }]
      ],
      (
        if include_reference
          [
            I18n.t("application_form.summary.reference"),
            application_form.reference
          ]
        end
      ),
      [
        I18n.t("application_form.summary.status"),
        render(
          GovukComponent::TagComponent.new(
            text: "Not implemented",
            colour: "blue"
          )
        )
      ],
      (
        if include_notes
          [I18n.t("application_form.summary.notes"), "Not implemented"]
        end
      )
    ].compact.map do |key, value, actions|
      { key: { text: key }, value: { text: value }, actions: actions || [] }
    end
  end
end
